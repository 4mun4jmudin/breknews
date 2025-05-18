// lib/views/widgets/login_screen.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/helper.dart' as helper;
import '../../routes/route_name.dart';
import 'package:breaknews/views/utils/form_validaror.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _showSuccessDialogAndNavigate(
      BuildContext context, String message, String routeName) async {
    navigateAction() {
      context.goNamed(routeName);
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        Future.delayed(const Duration(seconds: 2), () {
          // ignore: use_build_context_synchronously
          if (Navigator.of(dialogContext).canPop()) {
            // ignore: use_build_context_synchronously
            Navigator.of(dialogContext).pop();
          }
          navigateAction();
        });
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          backgroundColor: helper.cWhite,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              helper.vsMedium,
              Icon(Icons.check_circle, color: helper.cSuccess, size: 60.0),
              helper.vsMedium,
              Text(message,
                  textAlign: TextAlign.center,
                  style: helper.subtitle1
                      .copyWith(color: helper.cBlack, fontWeight: helper.bold)),
              helper.vsMedium,
            ],
          ),
        );
      },
    );
  }

  void _attemptLogin() {
    if (_formKey.currentState!.validate()) {
      _showSuccessDialogAndNavigate(
          context, "Login Successful!", RouteName.home);
      debugPrint('Form valid, proses login...');
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
                      fontFamily: defaultFontFamily),
                ),
                Text('Again!',
                    style: TextStyle(
                        color: helper.cPrimary,
                        fontSize: 32,
                        fontWeight: helper.bold,
                        fontFamily: defaultFontFamily)),
                helper.vsTiny,
                Text('Welcome back you\'ve been missed',
                    style: helper.subtitle1.copyWith(color: helper.cTextBlue)),
                helper.vsLarge,
                // ---------------------email-------------------//
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
                    hintText: 'Email',
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
                // ---------------------password-------------------//
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
                    hintText: 'Password',
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {/* Logika Lupa Password */},
                    child: Text('Forgot Password?',
                        style: helper.subtitle2.copyWith(color: helper.cError)),
                  ),
                ),
                const SizedBox(
                  height: 300,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _attemptLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: helper.cPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: helper.subtitle1.copyWith(
                          fontWeight: helper.semibold, color: helper.cWhite),
                    ),
                    child: const Text('Login'),
                  ),
                ),
                helper.vsMedium,
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Don’t have an account? ',
                      style: helper.subtitle2.copyWith(
                          color: helper.cTextBlue,
                          fontFamily: defaultFontFamily),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Sign Up',
                          style: helper.subtitle2.copyWith(
                              color: helper.cPrimary,
                              fontWeight: helper.bold,
                              fontFamily: defaultFontFamily),
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
