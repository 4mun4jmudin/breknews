import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/helper.dart' as helper;
import '../../routes/route_name.dart';
import '../utils/form_validaror.dart';
import '../../services/database_helper.dart';

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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != _passwordController.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  Future<void> _showSuccessDialogAndNavigate(
      BuildContext context, String message, String routeName) async {
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          backgroundColor: helper.cPrimary,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              helper.vsMedium,
              Icon(Icons.check_circle, color: helper.cWhite, size: 60.0),
              helper.vsMedium,
              Text(
                message,
                textAlign: TextAlign.center,
                style: helper.subtitle1
                    .copyWith(color: helper.cWhite, fontWeight: helper.bold),
              ),
              helper.vsMedium,
            ],
          ),
        );
      },
    );
  }

  // ========================== Fungsi untuk menampilkan SnackBar error ==========================
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: helper.cWhite)),
        backgroundColor: helper.cError,
      ),
    );
  }

  // ========================== untuk memanggil DatabaseHelper ==========================
  Future<void> _attemptRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String username = _usernameController.text.trim();
        String email = _emailController.text.trim();
        String password = _passwordController.text;
        Map<String, dynamic> result = await DatabaseHelper.instance
            .registerUser(username, email, password);

        if (!mounted) return;

        if (result['success']) {
          await _showSuccessDialogAndNavigate(
              context, result['message'], RouteName.login);
        } else {
          _showErrorSnackBar(result['message']);
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar(
              'Terjadi kesalahan saat registrasi. Silakan coba lagi.');
        }
        debugPrint('Error di _attemptRegister: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      debugPrint('Form tidak valid, silakan periksa input Anda.');
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
                  'Hello',
                  style: TextStyle(
                      color: helper.cPrimary,
                      fontSize: 32,
                      fontWeight: helper.bold,
                      fontFamily: defaultFontFamily),
                ),
                helper.vsTiny,
                Text(
                  'Signup to get started.',
                  style: helper.subtitle1.copyWith(color: helper.cTextBlue),
                ),

                helper.vsLarge,

                Row(children: [
                  Text(' * ',
                      style: TextStyle(
                          color: helper.cError,
                          fontSize: helper.subtitle1.fontSize)),
                  Text('Username',
                      style: helper.subtitle1.copyWith(color: helper.cTextBlue))
                ]),
                helper.vsSuperTiny,
                TextFormField(
                  controller: _usernameController,
                  validator: AppValidators.validateName,
                  style: helper.subtitle1.copyWith(color: helper.cTextBlue),
                  decoration: InputDecoration(
                    hintText: 'Enter your username',
                    hintStyle: helper.subtitle2.copyWith(color: helper.cLinear),
                    prefixIcon:
                        Icon(Icons.person_outline, color: helper.cTextBlue),
                    filled: true,
                    fillColor: helper.cGrey,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: helper.cPrimary, width: 1.5)),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                helper.vsMedium,

                // ========================== Field Email ==========================
                Row(children: [
                  Text(' * ',
                      style: TextStyle(
                          color: helper.cError,
                          fontSize: helper.subtitle1.fontSize)),
                  Text('Email',
                      style: helper.subtitle1.copyWith(color: helper.cTextBlue))
                ]),
                helper.vsSuperTiny,
                TextFormField(
                  controller: _emailController,
                  validator: AppValidators.validateEmail,
                  style: helper.subtitle1.copyWith(color: helper.cTextBlue),
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: helper.subtitle2.copyWith(color: helper.cLinear),
                    prefixIcon:
                        Icon(Icons.email_outlined, color: helper.cTextBlue),
                    filled: true,
                    fillColor: helper.cGrey,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: helper.cPrimary, width: 1.5)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                helper.vsMedium,

                // ========================== Field Password ==========================
                Row(children: [
                  Text(' * ',
                      style: TextStyle(
                          color: helper.cError,
                          fontSize: helper.subtitle1.fontSize)),
                  Text('Password',
                      style: helper.subtitle1.copyWith(color: helper.cTextBlue))
                ]),
                helper.vsSuperTiny,
                TextFormField(
                  controller: _passwordController,
                  validator: AppValidators.validatePassword,
                  obscureText: !_isPasswordVisible,
                  style: helper.subtitle1.copyWith(color: helper.cTextBlue),
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: helper.subtitle2.copyWith(color: helper.cLinear),
                    prefixIcon:
                        Icon(Icons.lock_outline, color: helper.cTextBlue),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: helper.cTextBlue),
                      onPressed: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible),
                    ),
                    filled: true,
                    fillColor: helper.cGrey,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: helper.cPrimary, width: 1.5)),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                helper.vsMedium,

                // ========================== Field Confirm Password ==========================
                Row(children: [
                  Text(' * ',
                      style: TextStyle(
                          color: helper.cError,
                          fontSize: helper.subtitle1.fontSize)),
                  Text('Confirm Password',
                      style: helper.subtitle1.copyWith(color: helper.cTextBlue))
                ]),
                helper.vsSuperTiny,
                TextFormField(
                  controller: _confirmPasswordController,
                  validator: _validateConfirmPassword,
                  obscureText: !_isConfirmPasswordVisible,
                  style: helper.subtitle1.copyWith(color: helper.cTextBlue),
                  decoration: InputDecoration(
                    hintText: 'Confirm your password',
                    hintStyle: helper.subtitle2.copyWith(color: helper.cLinear),
                    prefixIcon:
                        Icon(Icons.lock_outline, color: helper.cTextBlue),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: helper.cTextBlue),
                      onPressed: () => setState(() =>
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible),
                    ),
                    filled: true,
                    fillColor: helper.cGrey,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: helper.cPrimary, width: 1.5)),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                helper.vsLarge,

                // ========================== Tombol Register ==========================
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _attemptRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: helper.cPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: helper.subtitle1.copyWith(
                          fontWeight: helper.semibold, color: helper.cWhite),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(helper.cWhite),
                            ),
                          )
                        : const Text('Register'),
                  ),
                ),
                helper.vsMedium,
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: helper.subtitle2.copyWith(
                          color: helper.cTextBlue,
                          fontFamily: defaultFontFamily),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Sign In',
                          style: helper.subtitle2.copyWith(
                              color: helper.cPrimary,
                              fontWeight: helper.bold,
                              fontFamily: defaultFontFamily),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => context.goNamed(RouteName.login),
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
