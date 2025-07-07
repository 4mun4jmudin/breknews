// lib/views/widgets/splas_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:breaknews/routes/route_name.dart';
import '../utils/helper.dart' as helper;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk mengecek sesi dan navigasi
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));

    // Pastikan widget masih ada di tree sebelum navigasi
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token != null && token.isNotEmpty) {
        print("Token sesi ditemukan. Mengarahkan ke halaman utama.");
        context.goNamed(RouteName.home);
      } else {
        print("Token sesi tidak ditemukan. Mengarahkan ke halaman perkenalan.");
        context.goNamed(RouteName.introduction);
      }
    } catch (e) {
      print("Terjadi error saat mengecek sesi: $e");
      context.goNamed(RouteName.introduction);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: helper.cWhite,
      body: Center(child: Image.asset('assets/images/icon.png', width: 300)),
    );
  }
}
