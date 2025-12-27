import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_khatabook/core/services/security_service.dart';

final backupServiceProvider = Provider((ref) => BackupService(ref));

class BackupService {
  final Ref _ref;
  BackupService(this._ref);

  Future<String> exportBackup() async {
    // 1. Get DB File Path
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, 'secure_ledger.sqlite'));

    if (!dbFile.existsSync()) throw Exception("No database to backup");

    // 2. Get Token
    final security = _ref.read(securityServiceProvider);
    final token = await security.getBackupToken();
    if (token == null) throw Exception("Unlock app first or set PIN");

    // 3. Read DB (Might need to handle locking if busy, but simpler with simple copy)
    final dbBytes = await dbFile.readAsBytes();

    // 4. Create Payload
    // Format: Version(1b) | TokenLen(2b) | TokenBytes | DBBytes
    final tokenBytes = utf8.encode(token);
    final buffer = BytesBuilder();
    buffer.addByte(1); // Version
    buffer.addByte((tokenBytes.length >> 8) & 0xFF);
    buffer.addByte(tokenBytes.length & 0xFF);
    buffer.add(tokenBytes);
    buffer.add(dbBytes);

    // 5. Save File
    final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'backup_$dateStr.enc';

    Directory? storage;
    if (Platform.isAndroid) {
      // Attempt to use accessible Documents folder
      final startDir = Directory(
        '/storage/emulated/0/Documents/KhatabookBackups',
      );
      if (!startDir.existsSync()) {
        try {
          await startDir.create(recursive: true);
          storage = startDir;
        } catch (e) {
          storage = await getApplicationDocumentsDirectory();
        }
      } else {
        storage = startDir;
      }
    } else {
      storage = await getApplicationDocumentsDirectory();
    }

    final file = File(p.join(storage!.path, fileName));
    await file.writeAsBytes(buffer.toBytes());

    await _pruneBackups(storage);

    return file.path;
  }

  Future<void> _pruneBackups(Directory dir) async {
    try {
      final files = dir
          .listSync()
          .where((e) => e.path.endsWith('.enc'))
          .toList();
      if (files.length > 30) {
        // Sort by mod time
        files.sort(
          (a, b) => a.statSync().modified.compareTo(b.statSync().modified),
        );
        // Delete oldest
        final toDelete = files.take(files.length - 30);
        for (var f in toDelete) {
          f.delete();
        }
      }
    } catch (_) {}
  }

  Future<void> restoreBackup(File file, String pin) async {
    final bytes = await file.readAsBytes();
    int offset = 0;

    if (bytes.length < 5) throw Exception("Invalid Backup File");

    int version = bytes[offset++];
    if (version != 1) throw Exception("Unknown version");

    int tokenLen = (bytes[offset++] << 8) | bytes[offset++];
    final tokenBytes = bytes.sublist(offset, offset + tokenLen);
    final token = utf8.decode(tokenBytes);
    offset += tokenLen;

    final dbBytes = bytes.sublist(offset);

    // Validate PIN
    final security = _ref.read(securityServiceProvider);
    try {
      final masterKey = security.decryptMasterKeyWithPin(token, pin);
      // Validation Success

      // Write DB
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbFolder.path, 'secure_ledger.sqlite'));

      if (dbFile.existsSync()) {
        try {
          dbFile.deleteSync();
        } catch (_) {}
      }
      await dbFile.writeAsBytes(dbBytes);

      // Restore Credentials
      // Since backup pin worked, we set it as current PIN
      await security.setPin(pin);

      // Note: App usually needs restart to reload DB connection properly if providers are singletons.
      // In our architecture, 'databaseProvider' is updated by 'AuthNotifier', so looking out/in might work.
    } catch (e) {
      throw Exception("Decryption failed. Wrong PIN?");
    }
  }
}
