import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3/open.dart';
import 'package:offline_khatabook/core/theme/app_theme.dart';
import 'package:offline_khatabook/core/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Override sqlite3 loading to use SQLCipher
  open.overrideFor(OperatingSystem.android, _openOnAndroid);

  runApp(const ProviderScope(child: MyApp()));
}

DynamicLibrary _openOnAndroid() {
  try {
    return DynamicLibrary.open('libsqlcipher.so');
  } catch (e) {
    // Fail-safe or retry? For encryption, we must load this specific lib.
    rethrow;
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Secure Ledger',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
