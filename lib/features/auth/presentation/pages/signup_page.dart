import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/signup_provider.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/error_message_widget.dart';
import 'otp_verification_page.dart';
import '../../../navigation/presentation/widgets/bottom_navigation.dart';
import '../../../../core/theme/app_text_styles.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _referCodeController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referCodeController.dispose();
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

  Future<void> _handleSignUp() async {
    // Prevent double taps
    if (_isLoading) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final referCode = _referCodeController.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'Please fill all required fields';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _error = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _error = null;
      _isLoading = true;
    });

    try {
      // Await API call and check for success
      await ref.read(signupProvider.notifier).sendOtp(phone);

      // Check if API call was successful by checking state
      final signupState = ref.read(signupProvider);

      if (!mounted) return;

      // Only navigate if OTP was sent successfully
      if (signupState.isOtpSent && signupState.error == null) {
        final referCodeValue = referCode.isEmpty ? null : referCode;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationPage(
              name: name,
              phone: phone,
              email: email,
              password: password,
              confirmPassword: confirmPassword,
              referCode: referCodeValue,
            ),
          ),
        );
      } else {
        // Show error from provider state
        setState(() {
          _error = _cleanErrorMessage(
            signupState.error ?? 'Failed to send OTP',
          );
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 12.0,
              right: 12.0,
              top: 5.0,
              bottom: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SignupHeader(),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: SignupForm(
                    nameController: _nameController,
                    phoneController: _phoneController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    referCodeController: _referCodeController,
                    obscurePassword: _obscurePassword,
                    obscureConfirmPassword: _obscureConfirmPassword,
                    onTogglePassword: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    onToggleConfirmPassword: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    error: _error ?? signupState.error,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: const TermsAndConditionsText(),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: SignUpButton(
                    onPressed: (_isLoading || signupState.isLoading)
                        ? null
                        : _handleSignUp,
                    isLoading: _isLoading || signupState.isLoading,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignupHeader extends StatelessWidget {
  const SignupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: TextButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const BottomNavigationWidget(),
            ),
          );
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        ),
        child: Text('Skip', style: AppTextStyles.skipButton),
      ),
    );
  }
}

class SignupForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController referCodeController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final String? error;

  const SignupForm({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.referCodeController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sign Up', style: AppTextStyles.headingLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('Already have an account? ', style: AppTextStyles.description),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Text(
                'Sign In',
                style: AppTextStyles.link.copyWith(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        AuthInputField(
          controller: nameController,
          label: 'Name',
          hintText: 'Enter your name',
        ),
        const SizedBox(height: 24),
        AuthInputField(
          controller: phoneController,
          label: 'Phone',
          hintText: 'Enter your phone number',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 24),
        AuthInputField(
          controller: emailController,
          label: 'Email',
          hintText: 'yourusername@xyz.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        AuthInputField(
          controller: passwordController,
          label: 'Enter password',
          hintText: 'Enter password',
          obscureText: obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: onTogglePassword,
          ),
        ),
        const SizedBox(height: 24),
        AuthInputField(
          controller: confirmPasswordController,
          label: 'Confirm Password',
          hintText: 'Confirm Password',
          obscureText: obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: onToggleConfirmPassword,
          ),
        ),
        const SizedBox(height: 24),
        AuthInputField(
          controller: referCodeController,
          label: 'Refer Code (Optional)',
          hintText: 'Enter refer code if any',
        ),
        if (error != null) ...[ErrorMessageWidget(message: error!)],
      ],
    );
  }
}

class TermsAndConditionsText extends StatelessWidget {
  const TermsAndConditionsText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.termsText,
        children: [
          const TextSpan(
            text:
                'By tapping sign up to create account, first you have to agree our ',
          ),
          TextSpan(
            text: 'Terms and Conditions.',
            style: AppTextStyles.termsLink.copyWith(
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}

class SignUpButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const SignUpButton({
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
            : Text('SIGN UP', style: AppTextStyles.button),
      ),
    );
  }
}
