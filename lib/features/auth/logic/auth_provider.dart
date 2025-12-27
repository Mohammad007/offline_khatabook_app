import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_khatabook/core/services/security_service.dart';
import 'package:offline_khatabook/data/local/db/app_database.dart';

// Database Provider
final databaseProvider = NotifierProvider<DatabaseNotifier, AppDatabase?>(
  DatabaseNotifier.new,
);

class DatabaseNotifier extends Notifier<AppDatabase?> {
  @override
  AppDatabase? build() => null;
  // ignore: use_setters_to_change_properties
  void setDb(AppDatabase db) => state = db;
  void clear() => state = null;
}

// Current User Mobile (Identity)
final currentUserProvider = NotifierProvider<CurrentUserNotifier, String?>(
  CurrentUserNotifier.new,
);

class CurrentUserNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setUser(String mobile) => state = mobile;
}

enum AuthStatus {
  loading,
  onboarding, // No PIN set
  locked, // PIN set, but not verified yet
  authenticated, // Database Open
}

final authStateProvider = NotifierProvider<AuthNotifier, AuthStatus>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthStatus> {
  @override
  AuthStatus build() {
    // Schedule check
    Future.microtask(() => _checkInitialState());
    return AuthStatus.loading;
  }

  Future<void> _checkInitialState() async {
    final security = ref.read(securityServiceProvider);
    final hasPin = await security.isPinSet();

    if (hasPin) {
      state = AuthStatus.locked;
    } else {
      state = AuthStatus.onboarding;
    }
  }

  Future<void> setPin(String pin) async {
    final security = ref.read(securityServiceProvider);
    await security.setPin(pin);
    // Initialize MasterKey
    final masterKey = await security.getOrCreateMasterKey();
    // Open DB
    ref.read(databaseProvider.notifier).setDb(AppDatabase(masterKey));
    state = AuthStatus.authenticated;
  }

  Future<bool> unlockWithPin(String pin) async {
    final security = ref.read(securityServiceProvider);
    final isValid = await security.verifyPin(pin);
    if (isValid) {
      final masterKey = await security.getMasterKey();
      if (masterKey != null) {
        ref.read(databaseProvider.notifier).setDb(AppDatabase(masterKey));
        state = AuthStatus.authenticated;
        return true;
      }
    }
    return false;
  }

  Future<bool> unlockWithBiometrics() async {
    final security = ref.read(securityServiceProvider);
    final authenticated = await security.authenticateBiometrics();
    if (authenticated) {
      final masterKey = await security.getMasterKey();
      if (masterKey != null) {
        ref.read(databaseProvider.notifier).setDb(AppDatabase(masterKey));
        state = AuthStatus.authenticated;
        return true;
      }
    }
    return false;
  }

  void lockApp() {
    ref.read(databaseProvider)?.close();
    ref.read(databaseProvider.notifier).clear();
    state = AuthStatus.locked;
  }
}
