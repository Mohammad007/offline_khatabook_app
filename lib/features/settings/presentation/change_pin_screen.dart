import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:gap/gap.dart';
import 'package:offline_khatabook/core/constants/app_colors.dart';
import 'package:offline_khatabook/core/services/security_service.dart';
import 'package:offline_khatabook/features/auth/logic/auth_provider.dart';

class ChangePinScreen extends ConsumerStatefulWidget {
  const ChangePinScreen({super.key});

  @override
  ConsumerState<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends ConsumerState<ChangePinScreen> {
  final TextEditingController _pinController = TextEditingController();
  int _step = 0; // 0 = Old PIN, 1 = New PIN
  bool _isError = false;

  void _onSubmit(String pin) async {
    if (_step == 0) {
      // Verify Old PIN
      final security = ref.read(securityServiceProvider);
      final isCorrect = await security.verifyPin(pin);
      if (isCorrect) {
        setState(() {
          _step = 1;
          _pinController.clear();
          _isError = false;
        });
      } else {
        setState(() {
          _isError = true;
          _pinController.clear();
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Incorrect Old PIN")));
        }
      }
    } else {
      // Set New PIN
      await ref.read(authStateProvider.notifier).setPin(pin);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("PIN Changed Successfully")),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change PIN")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Gap(40),
            Text(
              _step == 0 ? "Enter Current PIN" : "Enter New PIN",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Gap(10),
            if (_step == 0)
              const Text(
                "Verify it's you to continue",
                style: TextStyle(color: AppColors.textSecondary),
              ),
            if (_step == 1)
              const Text(
                "Set a secure 4-digit PIN",
                style: TextStyle(color: AppColors.textSecondary),
              ),

            const Gap(40),

            Pinput(
              controller: _pinController,
              length: 4,
              obscureText: true,
              onCompleted: _onSubmit,
              defaultPinTheme: PinTheme(
                width: 60,
                height: 60,
                textStyle: const TextStyle(
                  fontSize: 24,
                  color: AppColors.textPrimary,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _isError ? AppColors.error : AppColors.primary,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
