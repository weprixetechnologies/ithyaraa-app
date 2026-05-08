import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/signup_provider.dart';
import '../widgets/error_message_widget.dart';
import '../widgets/back_button_widget.dart';
import 'registration_success_page.dart';
import '../../../../core/theme/app_text_styles.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {
  final String name;
  final String phone;
  final String email;
  final String password;
  final String confirmPassword;
  final String? referCode;

  const OtpVerificationPage({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.referCode,
  });

  @override
  ConsumerState<OtpVerificationPage> createState() =>
      _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  /// Cleans error messages to be more user-friendly
  String _cleanErrorMessage(String error) {
    // Remove "Exception: " prefix if present
    if (error.startsWith('Exception: ')) {
      error = error.substring(11);
    }
    // Remove other common prefixes
    if (error.startsWith('Failed to ')) {
      error = error.substring(10);
    }
    return error.trim();
  }

  Future<void> _handleVerifyOtp() async {
    // Prevent double taps
    if (_isLoading) return;

    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      setState(() {
        _error = 'Please enter the OTP code';
      });
      return;
    }

    setState(() {
      _error = null;
      _isLoading = true;
    });

    try {
      // Step 1: Verify OTP - await and check success
      await ref.read(signupProvider.notifier).verifyOtp(widget.phone, otp);
      
      final signupStateAfterVerify = ref.read(signupProvider);
      
      if (!mounted) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Check if OTP verification was successful
      if (!signupStateAfterVerify.isOtpVerified || 
          signupStateAfterVerify.error != null) {
        setState(() {
          _error = _cleanErrorMessage(signupStateAfterVerify.error ?? 'OTP verification failed');
          _isLoading = false;
        });
        return;
      }

      // Step 2: Create user - await and check success
      await ref.read(signupProvider.notifier).createUser(
            name: widget.name,
            phone: widget.phone,
            email: widget.email,
            password: widget.password,
            confirmPassword: widget.confirmPassword,
            referCode: widget.referCode?.isNotEmpty == true
                ? widget.referCode
                : null,
          );

      // Check final state after createUser
      final signupStateAfterCreate = ref.read(signupProvider);
      
      if (!mounted) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Only navigate if user creation was successful
      if (signupStateAfterCreate.isUserCreated && 
          signupStateAfterCreate.error == null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const RegistrationSuccessPage(),
          ),
          (route) => route.isFirst,
        );
      } else {
        // Show error from provider state
        setState(() {
          _error = _cleanErrorMessage(signupStateAfterCreate.error ?? 'User creation failed');
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _cleanErrorMessage(e.toString());
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(signupProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const OtpHeader(),
                          const SizedBox(height: 40),
                          OtpForm(
                            otpController: _otpController,
                            onVerify: _handleVerifyOtp,
                            isLoading: _isLoading || signupState.isLoading,
                            error: _error ?? signupState.error,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 0,
              left: 16,
              child: const BackButtonWidget(),
            ),
          ],
        ),
      ),
    );
  }
}

class OtpHeader extends StatelessWidget {
  const OtpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verify OTP',
          style: AppTextStyles.headingLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the 6-digit code sent to your phone',
          style: AppTextStyles.description,
        ),
      ],
    );
  }
}

class OtpForm extends StatelessWidget {
  final TextEditingController otpController;
  final VoidCallback onVerify;
  final bool isLoading;
  final String? error;

  const OtpForm({
    super.key,
    required this.otpController,
    required this.onVerify,
    required this.isLoading,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _OtpTextField(controller: otpController),
        const SizedBox(height: 24),
        if (error != null) ...[
          ErrorMessageWidget(message: error!),
          const SizedBox(height: 16),
        ],
        VerifyOtpButton(
          onPressed: isLoading ? null : onVerify,
          isLoading: isLoading,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: isLoading
              ? null
              : () {
                  // Resend OTP logic can be added here if needed
                },
          child: Text(
            'Resend OTP',
            style: AppTextStyles.description,
          ),
        ),
      ],
    );
  }
}

class _OtpTextField extends StatelessWidget {
  final TextEditingController controller;

  const _OtpTextField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 6,
      textAlign: TextAlign.center,
      style: AppTextStyles.otpInput,
      decoration: InputDecoration(
        labelText: 'OTP',
        hintText: '------',
        labelStyle: AppTextStyles.label,
        hintStyle: AppTextStyles.otpInput.copyWith(
          color: Colors.grey.shade300,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        counterText: '',
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}

class VerifyOtpButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const VerifyOtpButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE91E63),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'VERIFY OTP',
                style: AppTextStyles.button,
              ),
      ),
    );
  }
}
