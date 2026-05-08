import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/login_provider.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/error_message_widget.dart';
import 'signup_page.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/navigation/auth_navigation_service.dart';
import '../../../navigation/presentation/widgets/bottom_navigation.dart';

class LoginPage extends ConsumerStatefulWidget {
  /// If set, after successful login the app will navigate to this path (e.g. combo:productID).
  final String? redirectPath;

  const LoginPage({super.key, this.redirectPath});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
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

  Future<void> _handleLogin() async {
    // Prevent double taps
    if (_isLoading) return;

    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (phone.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'Please fill all fields';
      });
      return;
    }

    setState(() {
      _error = null;
      _isLoading = true;
    });

    try {
      // Await API call and check for success
      await ref.read(loginProvider.notifier).login(phone, password);

      // Check if API call was successful by checking state
      final loginState = ref.read(loginProvider);

      if (!mounted) return;

      // Only navigate if login was successful
      if (loginState.isSuccess && loginState.error == null) {
        if (widget.redirectPath != null &&
            widget.redirectPath!.isNotEmpty &&
            AuthNavigationService.hasNavigateToPath) {
          AuthNavigationService.clearLoginNavigationFlag();
          AuthNavigationService.navigateToPath(widget.redirectPath!);
          // Stack is replaced by navigateToPath (Home + target route)
        } else if (context.mounted) {
          AuthNavigationService.clearLoginNavigationFlag();
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const BottomNavigationWidget(),
              ),
            );
          }
        }
      } else {
        // Show error from provider state
        setState(() {
          _error = _cleanErrorMessage(loginState.error ?? 'Login failed');
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
    final loginState = ref.watch(loginProvider);

    return PopScope(
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) {
          AuthNavigationService.clearLoginNavigationFlag();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: SizedBox(
                  height:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: LoginForm(
                          phoneController: _phoneController,
                          passwordController: _passwordController,
                          obscurePassword: _obscurePassword,
                          onTogglePassword: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          error: _error ?? loginState.error,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: TermsAndConditionsText(),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: SignInButton(
                          onPressed: (_isLoading || loginState.isLoading)
                              ? null
                              : _handleLogin,
                          isLoading: _isLoading || loginState.isLoading,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: HeaderSection(redirectPath: widget.redirectPath),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  final String? redirectPath;

  const HeaderSection({super.key, this.redirectPath});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: TextButton(
        onPressed: () {
          AuthNavigationService.clearLoginNavigationFlag();
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const BottomNavigationWidget(),
              ),
            );
          }
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text('Skip', style: AppTextStyles.skipButton),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final String? error;

  const LoginForm({
    super.key,
    required this.phoneController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sign In', style: AppTextStyles.headingLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            Text("Don't have an account? ", style: AppTextStyles.description),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupPage()),
                );
              },
              child: Text('Sign Up', style: AppTextStyles.link),
            ),
          ],
        ),
        const SizedBox(height: 40),
        AuthInputField(
          controller: phoneController,
          label: 'Phone',
          hintText: 'Enter your phone number',
          keyboardType: TextInputType.phone,
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

class SignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const SignInButton({
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
            : Text('SIGN IN', style: AppTextStyles.button),
      ),
    );
  }
}
