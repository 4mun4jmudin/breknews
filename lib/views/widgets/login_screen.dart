// lib/views/widgets/login_screen.dart
// ignore_for_file: deprecated_member_use, duplicate_ignore, use_build_context_synchronously

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/helper.dart' as helper;
import '../../routes/route_name.dart';
import '../utils/form_validaror.dart';
import '../../services/auth_api_service.dart';

// 1. Clipper diubah untuk kurva tunggal yang lebih halus dan modern
class TopImageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 80); // Mulai dari bawah
    // Membuat satu kurva melengkung yang elegan
    path.quadraticBezierTo(
      size.width / 2, // Titik kontrol di tengah
      size.height, // Puncak lengkungan di bawah
      size.width, // Titik akhir di kanan bawah
      size.height - 80,
    );
    path.lineTo(size.width, 0); // Garis ke kanan atas
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _attemptLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        String email = _emailController.text.trim();
        String password = _passwordController.text;
        final authService = AuthApiService();
        Map<String, dynamic> result = await authService.login(email, password);

        if (!mounted) return;
        if (result['success']) {
          await _showSuccessDialogAndNavigate(
            context,
            result['message'],
            RouteName.home,
          );
        } else {
          _showErrorSnackBar(result['message']);
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar(
            'Terjadi kesalahan saat login. Silakan coba lagi.',
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // 2. Input field diperbarui dengan prefixIcon
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    bool isPassword = false,
  }) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        helper.vsTiny,
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: isPassword && !_isPasswordVisible,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: theme.hintColor, size: 22),
            hintText: 'Enter your ${label.toLowerCase()}',
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: theme.hintColor,
                    ),
                    onPressed: () => setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    }),
                  )
                : null,
          ),
          keyboardType: isPassword
              ? TextInputType.visiblePassword
              : TextInputType.emailAddress,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          textInputAction: isPassword
              ? TextInputAction.done
              : TextInputAction.next,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipPath(
              clipper: TopImageClipper(),
              child: SizedBox(
                height: screenHeight * 0.35,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/iconlogin1.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: colorScheme.primary.withOpacity(0.1),
                    );
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 40.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Hello again!',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    Text(
                      'Welcome back, you’ve been missed!',
                      style: textTheme.titleMedium?.copyWith(
                        color: helper.cTextMedium,
                      ),
                    ),
                    helper.vsXLarge,
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      validator: AppValidators.validateEmail,
                    ),
                    helper.vsMedium,
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      validator: AppValidators.validatePassword,
                      isPassword: true,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            context.pushNamed(RouteName.forgotPassword),
                        child: Text(
                          'Forgot your password?',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    helper.vsMedium,
                    // 3. Tombol diperbarui dengan sudut membulat dan bayangan
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _attemptLogin,
                        style: ElevatedButton.styleFrom(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Login'),
                      ),
                    ),
                    helper.vsLarge,
                    Align(
                      alignment: Alignment.center,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'Don’t have an account? ',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onBackground.withOpacity(0.7),
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Sign up',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () =>
                                    context.goNamed(RouteName.register),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSuccessDialogAndNavigate(
    BuildContext context,
    String message,
    String routeName,
  ) async {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            if (Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
            }
            context.goNamed(routeName);
          }
        });
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Theme.of(context).cardColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              helper.vsMedium,
              Icon(
                Icons.check_circle_outline_rounded,
                color: helper.cSuccess,
                size: 60.0,
              ),
              helper.vsMedium,
              Text(
                message,
                textAlign: TextAlign.center,
                style: helper.subtitle1.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: helper.bold,
                ),
              ),
              helper.vsMedium,
            ],
          ),
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: helper.cWhite)),
        backgroundColor: helper.cError,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
