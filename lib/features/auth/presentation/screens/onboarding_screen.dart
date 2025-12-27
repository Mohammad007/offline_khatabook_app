import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:gap/gap.dart';
import 'package:offline_khatabook/core/constants/app_colors.dart';
import 'package:offline_khatabook/features/auth/logic/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  int _step = 0;
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
    if (_mobileController.text.length < 10) return;

    // Move to next page
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _step = 1);

    // Start countdown
    _startTimer();

    // Simulate Auto-Fill process
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

  void _setPin() {
    if (_pinController.text.length == 4) {
      ref.read(authStateProvider.notifier).setPin(_pinController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Gap(40),
              Text(
                _step == 0
                    ? "Welcome to Secure Ledger"
                    : _step == 1
                    ? "Verify Mobile"
                    : "Secure Your App",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Gap(10),
              Text(
                "Your offline, secure business companion.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Gap(40),
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
      children: [
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
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
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
          // onCompleted: (_) => _verifyOtp(),
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
      children: [
        const Text("Set a 4-digit PIN to secure your data."),
        const Gap(20),
        Pinput(
          controller: _pinController,
          length: 4,
          obscureText: true,
          onCompleted: (_) => _setPin(),
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
            onPressed: _setPin,
            child: const Text('Set PIN & Start'),
          ),
        ),
      ],
    );
  }
}
