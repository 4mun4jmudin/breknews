import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/helper.dart' as helper;
import '../../routes/route_name.dart';
import '../utils/form_validaror.dart';
import '../../services/database_helper.dart';

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

  Future<void> _showSuccessDialogAndNavigate(
    BuildContext context,
    String message,
    String routeName,
  ) async {
    void navigateAction() {
      if (mounted) {
        context.goNamed(routeName);
      }
    }

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
            navigateAction();
          }
        });
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: helper.cWhite,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              helper.vsMedium,
              Icon(Icons.check_circle, color: helper.cSuccess, size: 60.0),
              helper.vsMedium,
              Text(
                message,
                textAlign: TextAlign.center,
                style: helper.subtitle1.copyWith(
                  color: helper.cBlack,
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
      ),
    );
  }

  Future<void> _attemptLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String email = _emailController.text.trim();
        String password = _passwordController.text;

        Map<String, dynamic> result = await DatabaseHelper.instance.loginUser(
          email,
          password,
        );

        if (!mounted) return;

        if (result['success']) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('currentUserId', result['userId']);
          await prefs.setString('currentUsername', result['username']);
          await prefs.setString('currentUserEmail', email);
          debugPrint(
            'Login sukses, userId: ${result['userId']}, username: ${result['username']} disimpan.',
          );

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
        debugPrint('Error di _attemptLogin: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      debugPrint('Form tidak valid.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? defaultFontFamily = helper.headline1.fontFamily;

    return Scaffold(
      backgroundColor: helper.cWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                helper.vsMedium,
                Text(
                  'Hallo',
                  style: TextStyle(
                    color: helper.cBlack,
                    fontSize: 32,
                    fontWeight: helper.bold,
                    fontFamily: defaultFontFamily,
                  ),
                ),
                Text(
                  'Again!',
                  style: TextStyle(
                    color: helper.cPrimary,
                    fontSize: 32,
                    fontWeight: helper.bold,
                    fontFamily: defaultFontFamily,
                  ),
                ),
                helper.vsTiny,
                Text(
                  'Welcome back you\'ve been missed',
                  style: helper.subtitle1.copyWith(color: helper.cTextBlue),
                ),
                helper.vsLarge,
                Row(
                  children: [
                    Text(
                      ' * ',
                      style: TextStyle(
                        color: helper.cError,
                        fontSize: helper.subtitle1.fontSize,
                      ),
                    ),
                    Text(
                      'Email',
                      style: helper.subtitle1.copyWith(color: helper.cTextBlue),
                    ),
                  ],
                ),
                helper.vsSuperTiny,
                TextFormField(
                  controller: _emailController,
                  validator: AppValidators.validateEmail,
                  style: helper.subtitle1.copyWith(color: helper.cTextBlue),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: helper.subtitle2.copyWith(color: helper.cLinear),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: helper.cTextBlue,
                    ),
                    filled: true,
                    fillColor: helper.cGrey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: helper.cPrimary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                helper.vsMedium,
                Row(
                  children: [
                    Text(
                      ' * ',
                      style: TextStyle(
                        color: helper.cError,
                        fontSize: helper.subtitle1.fontSize,
                      ),
                    ),
                    Text(
                      'Password',
                      style: helper.subtitle1.copyWith(color: helper.cTextBlue),
                    ),
                  ],
                ),
                helper.vsSuperTiny,
                TextFormField(
                  controller: _passwordController,
                  validator: AppValidators.validatePassword,
                  obscureText: !_isPasswordVisible,
                  style: helper.subtitle1.copyWith(color: helper.cTextBlue),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: helper.subtitle2.copyWith(color: helper.cLinear),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: helper.cTextBlue,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: helper.cTextBlue,
                      ),
                      onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                    ),
                    filled: true,
                    fillColor: helper.cGrey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: helper.cPrimary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      context.pushNamed(RouteName.forgotPassword);
                      debugPrint('Forgot Password? ditekan');
                    },
                    child: Text(
                      'Forgot Password?',
                      style: helper.subtitle2.copyWith(color: helper.cError),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _attemptLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: helper.cPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: helper.subtitle1.copyWith(
                        fontWeight: helper.semibold,
                        color: helper.cWhite,
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                helper.cWhite,
                              ),
                            ),
                          )
                        : const Text('Login'),
                  ),
                ),
                helper.vsMedium,
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Don’t have an account? ',
                      style: helper.subtitle2.copyWith(
                        color: helper.cTextBlue,
                        fontFamily: defaultFontFamily,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Sign Up',
                          style: helper.subtitle2.copyWith(
                            color: helper.cPrimary,
                            fontWeight: helper.bold,
                            fontFamily: defaultFontFamily,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => context.goNamed(RouteName.register),
                        ),
                      ],
                    ),
                  ),
                ),
                helper.vsMedium,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
