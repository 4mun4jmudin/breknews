// lib/views/widgets/register_screen.dart
// ignore_for_file: deprecated_member_use, duplicate_ignore, use_build_context_synchronously

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/helper.dart' as helper;
import '../../routes/route_name.dart';
import '../utils/form_validaror.dart';
import '../../services/auth_api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- LOGIKA TIDAK BERUBAH ---
  // Fungsi-fungsi validasi, registrasi, dan dialog tetap sama.
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != _passwordController.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  Future<void> _attemptRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final authService = AuthApiService();
        Map<String, dynamic> result = await authService.register(
          _usernameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (!mounted) return;
        if (result['success']) {
          await _showSuccessDialogAndNavigate(
            context,
            result['message'],
            RouteName.login,
          );
        } else {
          _showErrorSnackBar(result['message']);
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar(
            'Terjadi kesalahan saat registrasi. Silakan coba lagi.',
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

  // --- UI WIDGET DIPERBARUI ---
  // Widget helper untuk text field, disesuaikan untuk kebutuhan registrasi.
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    bool isPassword = false,
    bool isConfirmPassword = false,
  }) {
    final ThemeData theme = Theme.of(context);

    // Tentukan visibilitas berdasarkan jenis password
    bool isVisible = isConfirmPassword
        ? _isConfirmPasswordVisible
        : _isPasswordVisible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            // ignore: deprecated_member_use
            color: theme.colorScheme.onBackground.withOpacity(0.8),
          ),
        ),
        helper.vsTiny,
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: isPassword && !isVisible,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Enter your ${label.toLowerCase()}',
            hintStyle: TextStyle(color: theme.hintColor.withOpacity(0.6)),
            filled: true,
            fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: theme.hintColor,
                    ),
                    onPressed: () {
                      setState(() {
                        if (isConfirmPassword) {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        } else {
                          _isPasswordVisible = !_isPasswordVisible;
                        }
                      });
                    },
                  )
                : null,
          ),
          keyboardType: isPassword
              ? TextInputType.visiblePassword
              : TextInputType.emailAddress,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          textInputAction: isConfirmPassword
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
            // Bagian Gambar Atas dengan Tepi Melengkung
            ClipPath(
              clipper:
                  TopImageClipper(), // Menggunakan clipper yang sama dari login
              child: SizedBox(
                height:
                    screenHeight *
                    0.30, // Sedikit lebih pendek untuk memberi ruang form
                width: double.infinity,
                child: Image.asset(
                  'assets/images/iconlogin1.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: colorScheme.primaryContainer);
                  },
                ),
              ),
            ),

            // Bagian Form Registrasi
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 40.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Create Account', // Judul halaman registrasi
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    helper.vsLarge,
                    _buildTextField(
                      controller: _usernameController,
                      label: 'Username',
                      validator: AppValidators.validateName,
                    ),
                    helper.vsMedium,
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      validator: AppValidators.validateEmail,
                    ),
                    helper.vsMedium,
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      validator: AppValidators.validatePassword,
                      isPassword: true,
                    ),
                    helper.vsMedium,
                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      validator: _validateConfirmPassword,
                      isPassword: true,
                      isConfirmPassword: true,
                    ),
                    helper.vsLarge,
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _attemptRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          textStyle: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
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
                            : const Text('Register'),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Align(
                      alignment: Alignment.center,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onBackground.withOpacity(0.7),
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Sign in',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () =>
                                    context.goNamed(RouteName.login),
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

  // Fungsi dialog dan snackbar tidak perlu diubah
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

// Class helper untuk membuat efek lengkung pada gambar atas (sama seperti di login)
class TopImageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 80);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 40);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
