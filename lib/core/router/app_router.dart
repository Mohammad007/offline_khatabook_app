import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_khatabook/features/auth/logic/auth_provider.dart';
import 'package:offline_khatabook/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:offline_khatabook/features/auth/presentation/screens/lock_screen.dart';
import 'package:offline_khatabook/features/auth/presentation/screens/reset_pin_screen.dart';
import 'package:offline_khatabook/features/dashboard/presentation/home_screen.dart';
import 'package:offline_khatabook/features/dashboard/presentation/add_customer_screen.dart';
import 'package:offline_khatabook/features/ledger/presentation/screens/customer_detail_screen.dart';
import 'package:offline_khatabook/features/ledger/presentation/screens/add_transaction_screen.dart';
import 'package:offline_khatabook/features/settings/presentation/settings_screen.dart';
import 'package:offline_khatabook/features/settings/presentation/change_pin_screen.dart';
import 'package:offline_khatabook/features/reports/presentation/reports_screen.dart';
import 'package:offline_khatabook/features/reminders/presentation/reminders_screen.dart';
import 'package:offline_khatabook/features/categories/presentation/categories_screen.dart';
import 'package:offline_khatabook/features/notes/presentation/notes_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: AuthStateListenable(ref),
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      final loc = state.uri.toString();
      final isLoggingIn = loc == '/lock' || loc == '/onboarding';

      if (auth == AuthStatus.loading) return null;

      if (auth == AuthStatus.onboarding && loc != '/onboarding') {
        return '/onboarding';
      }

      if (auth == AuthStatus.locked && loc != '/lock' && loc != '/reset-pin') {
        return '/lock';
      }

      if (auth == AuthStatus.authenticated && isLoggingIn) return '/';

      return null;
    },
    routes: [
      // Main Routes
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),

      // Auth Routes
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/lock', builder: (context, state) => const LockScreen()),
      GoRoute(
        path: '/reset-pin',
        builder: (context, state) => const ResetPinScreen(),
      ),

      // Settings Routes
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/change-pin',
        builder: (context, state) => const ChangePinScreen(),
      ),

      // Customer Routes
      GoRoute(
        path: '/add-customer',
        builder: (context, state) => const AddCustomerScreen(),
      ),
      GoRoute(
        path: '/customer/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return CustomerDetailScreen(customerId: id);
        },
      ),

      // Transaction Routes
      GoRoute(
        path: '/transaction/add',
        builder: (context, state) {
          final customerId = int.parse(
            state.uri.queryParameters['customerId']!,
          );
          final isCredit = state.uri.queryParameters['isCredit'] == 'true';
          return AddTransactionScreen(
            customerId: customerId,
            isCredit: isCredit,
          );
        },
      ),

      // New Feature Routes
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/reminders',
        builder: (context, state) => const RemindersScreen(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(path: '/notes', builder: (context, state) => const NotesScreen()),
    ],
  );
});

class AuthStateListenable extends ValueNotifier<AuthStatus> {
  AuthStateListenable(Ref ref) : super(AuthStatus.loading) {
    ref.listen(authStateProvider, (_, next) => value = next);
  }
}
