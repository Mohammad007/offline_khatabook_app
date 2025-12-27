import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:gap/gap.dart';
import 'package:offline_khatabook/core/constants/app_colors.dart';
import 'package:offline_khatabook/features/auth/logic/auth_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authStateProvider.notifier).unlockWithBiometrics();
    });
  }

  void _unlock() async {
    final success = await ref
        .read(authStateProvider.notifier)
        .unlockWithPin(_pinController.text);
    if (!success) {
      setState(() {
        _isError = true;
        _pinController.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Incorrect PIN')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 80,
                color: AppColors.textInverse,
              ),
              const Gap(20),
              Text(
                "Secure Ledger Locked",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textInverse,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(40),
              Pinput(
                controller: _pinController,
                length: 4,
                obscureText: true,
                onCompleted: (_) => _unlock(),
                defaultPinTheme: PinTheme(
                  width: 60,
                  height: 60,
                  textStyle: const TextStyle(
                    fontSize: 24,
                    color: AppColors.textInverse,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isError ? AppColors.error : AppColors.textInverse,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const Gap(40),
              TextButton.icon(
                onPressed: () =>
                    ref.read(authStateProvider.notifier).unlockWithBiometrics(),
                icon: const Icon(Icons.fingerprint, color: AppColors.accent),
                label: const Text(
                  "Unlock with Biometrics",
                  style: TextStyle(color: AppColors.accent),
                ),
              ),
              const Gap(10),
              TextButton(
                onPressed: () => context.push('/reset-pin'),
                child: const Text(
                  "Forgot PIN? Reset via OTP",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
