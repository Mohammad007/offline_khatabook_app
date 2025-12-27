import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_khatabook/core/services/secure_storage_service.dart';

final securityServiceProvider = Provider(
  (ref) => SecurityService(ref.read(secureStorageProvider)),
);

class SecurityService {
  final SecureStorageService _storage;
  final _localAuth = LocalAuthentication();

  SecurityService(this._storage);

  static const _pinHashKey = 'pin_hash';
  static const _masterKeyKey = 'master_key';
  static const _backupTokenKey = 'backup_token';

  Future<String> getOrCreateMasterKey() async {
    String? key = await _storage.read(_masterKeyKey);
    if (key == null) {
      key = _generateRandomKey();
      await _storage.write(_masterKeyKey, key);
    }
    return key;
  }

  Future<String?> getMasterKey() async {
    return await _storage.read(_masterKeyKey);
  }

  String _generateRandomKey() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  Future<void> setPin(String pin) async {
    var bytes = utf8.encode(pin);
    var digest = sha256.convert(bytes);
    await _storage.write(_pinHashKey, digest.toString());

    // Update Backup Token
    final mk = await getOrCreateMasterKey();
    final token = encryptMasterKeyWithPin(mk, pin);
    await _storage.write(_backupTokenKey, token);
  }

  Future<bool> verifyPin(String pin) async {
    String? stored = await _storage.read(_pinHashKey);
    if (stored == null) return false;
    var bytes = utf8.encode(pin);
    var digest = sha256.convert(bytes);
    bool isValid = digest.toString() == stored;

    if (isValid) {
      final mk = await getOrCreateMasterKey();
      final token = encryptMasterKeyWithPin(mk, pin);
      await _storage.write(_backupTokenKey, token);
    }
    return isValid;
  }

  Future<bool> isPinSet() async {
    return await _storage.contains(_pinHashKey);
  }

  Future<String?> getBackupToken() async {
    return await _storage.read(_backupTokenKey);
  }

  Future<bool> authenticateBiometrics() async {
    bool canCheck = await _localAuth.canCheckBiometrics;
    if (!canCheck) return false;
    try {
      // Trying legacy parameters to resolve "No named parameter options" error
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Secure Ledger',
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Authenticate to secure your ledger',
            cancelButton: 'Cancel',
          ),
          IOSAuthMessages(cancelButton: 'Cancel'),
        ],
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (_) {
      // If legacy params fail (e.g. newer version stricter), we might catch it here,
      // but compile error would happen before runtime.
      return false;
    }
  }

  String encryptMasterKeyWithPin(String masterKey, String pin) {
    final salt = _generateRandomBytes(16);
    final kek = _deriveKeyFromPin(pin, salt);
    final key = enc.Key(kek);

    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key));
    final encrypted = encrypter.encrypt(masterKey, iv: iv);

    return '${base64.encode(salt)}:${iv.base64}:${encrypted.base64}';
  }

  String decryptMasterKeyWithPin(String bundle, String pin) {
    try {
      final parts = bundle.split(':');
      if (parts.length != 3) throw Exception('Invalid Key Bundle');

      final salt = base64.decode(parts[0]);
      final iv = enc.IV.fromBase64(parts[1]);
      final encryptedData = enc.Encrypted.fromBase64(parts[2]);

      final kek = _deriveKeyFromPin(pin, salt);
      final key = enc.Key(kek);

      final encrypter = enc.Encrypter(enc.AES(key));
      return encrypter.decrypt(encryptedData, iv: iv);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  Uint8List _deriveKeyFromPin(String pin, Uint8List salt) {
    var hmac = Hmac(sha256, utf8.encode(pin));
    var digest = hmac.convert(salt);
    for (int i = 0; i < 1000; i++) {
      digest = hmac.convert(digest.bytes);
    }
    return Uint8List.fromList(digest.bytes);
  }

  Uint8List _generateRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (i) => random.nextInt(256)),
    );
  }
}
