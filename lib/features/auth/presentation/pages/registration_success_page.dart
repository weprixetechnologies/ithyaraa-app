import 'dart:async';
import 'package:flutter/material.dart';
import 'login_page.dart';
import '../../../../core/theme/app_text_styles.dart';

class RegistrationSuccessPage extends StatefulWidget {
  const RegistrationSuccessPage({super.key});

  @override
  State<RegistrationSuccessPage> createState() =>
      _RegistrationSuccessPageState();
}

class _RegistrationSuccessPageState extends State<RegistrationSuccessPage> {
  int _countdown = 2;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _countdown--;
        });

        if (_countdown <= 0) {
          timer.cancel();
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
              (route) => route.isFirst,
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SuccessMessage(),
                const SizedBox(height: 40),
                CountdownText(countdown: _countdown),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SuccessMessage extends StatelessWidget {
  const SuccessMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFE91E63).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            size: 50,
            color: Color(0xFFE91E63),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Registration Successful',
          style: AppTextStyles.headingMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Redirecting to login in 2 seconds',
          style: AppTextStyles.description,
        ),
      ],
    );
  }
}

class CountdownText extends StatelessWidget {
  final int countdown;

  const CountdownText({super.key, required this.countdown});

  @override
  Widget build(BuildContext context) {
    if (countdown <= 0) return const SizedBox.shrink();

    return Text(
      'Redirecting in $countdown...',
      style: AppTextStyles.bodyLarge.copyWith(
        color: Colors.grey.shade600,
      ),
    );
  }
}
