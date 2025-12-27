import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:gap/gap.dart';
import 'package:offline_khatabook/core/constants/app_colors.dart';
import 'package:offline_khatabook/features/auth/logic/auth_provider.dart';

class ResetPinScreen extends ConsumerStatefulWidget {
  const ResetPinScreen({super.key});

  @override
  ConsumerState<ResetPinScreen> createState() => _ResetPinScreenState();
}

class _ResetPinScreenState extends ConsumerState<ResetPinScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  int _step = 0; // 0: Mobile, 1: OTP, 2: New PIN
  Timer? _timer;
  int _secondsRemaining = 30;
  bool _isAutoFilling = false;

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _mobileController.dispose();
    _otpController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _secondsRemaining = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  void _sendOtp() {
    if (_mobileController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid mobile number')),
      );
      return;
    }

    // Move to next page immediately
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _step = 1);

    // Start countdown
    _startTimer();

    // Determine a random delay between 2 to 5 seconds for simulated SMS simulation
    // Since request said "under 30 sec", we make it quick to be user friendly.
    setState(() => _isAutoFilling = true);

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      setState(() => _isAutoFilling = false);
      const simulatedOtp = '123456';

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP Received: $simulatedOtp')),
      );

      _otpController.setText(simulatedOtp);

      // Auto verify after short visual delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _verifyOtp();
      });
    });
  }

  void _verifyOtp() {
    if (_otpController.text == '123456') {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _step = 2);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid OTP')));
    }
  }

  void _setNewPin() async {
    if (_pinController.text.length == 4) {
      await ref.read(authStateProvider.notifier).setPin(_pinController.text);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('PIN Reset Successful')));
        // If we are locked, this will auto-login via auth state listener
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset PIN")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Gap(20),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildMobileStep(),
                    _buildOtpStep(),
                    _buildPinStep(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Enter your registered mobile number to receive an OTP.",
          textAlign: TextAlign.center,
        ),
        const Gap(20),
        TextField(
          controller: _mobileController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: const InputDecoration(
            labelText: 'Mobile Number',
            prefixText: '+91 ',
            counterText: "",
          ),
        ),
        const Gap(20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _sendOtp,
            child: const Text('Send OTP'),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Enter the OTP sent to your mobile"),
        if (_isAutoFilling) ...[
          const Gap(10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              Gap(8),
              Text(
                "Auto-detecting OTP...",
                style: TextStyle(color: AppColors.primary, fontSize: 12),
              ),
            ],
          ),
        ],
        const Gap(20),
        Pinput(
          controller: _otpController,
          length: 6,
          // onCompleted: (_) => _verifyOtp(), // Auto-verify handles this
          defaultPinTheme: PinTheme(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryLight),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const Gap(20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _verifyOtp,
            child: const Text('Verify OTP'),
          ),
        ),
        const Gap(20),
        Text(
          _secondsRemaining > 0
              ? "Resend OTP in $_secondsRemaining s"
              : "Resend OTP",
          style: TextStyle(
            color: _secondsRemaining > 0 ? Colors.grey : AppColors.primary,
            fontWeight: _secondsRemaining > 0
                ? FontWeight.normal
                : FontWeight.bold,
          ),
        ),
        if (_secondsRemaining == 0)
          TextButton(onPressed: _sendOtp, child: const Text("Resend")),
      ],
    );
  }

  Widget _buildPinStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Set your new 4-digit PIN"),
        const Gap(20),
        Pinput(
          controller: _pinController,
          length: 4,
          obscureText: true,
          onCompleted: (_) => _setNewPin(),
          defaultPinTheme: PinTheme(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const Gap(20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _setNewPin,
            child: const Text('Set New PIN'),
          ),
        ),
      ],
    );
  }
}
