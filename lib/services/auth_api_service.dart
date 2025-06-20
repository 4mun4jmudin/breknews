// lib/services/auth_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart'; // Impor file konfigurasi

class AuthApiService {
  // Fungsi untuk login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      // Selalu decode JSON, terlepas dari status code
      final data = json.decode(response.body);

      // Periksa status code DAN isi respons
      if (response.statusCode == 200) {
        // Cek jika body berisi pesan sukses dari API Anda
        // Mungkin API Anda punya format seperti: { "success": true, "token": "..." }
        if (data['token'] != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', data['token']);
          return {'success': true, 'message': 'Login berhasil!'};
        }
      }

      // Jika statusCode bukan 200 atau tidak ada token, anggap gagal.
      // Coba ambil pesan error dari body.
      String errorMessage =
          data['body']?['message'] ??
          data['message'] ??
          'Terjadi kesalahan yang tidak diketahui.';
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print('Error di AuthApiService: $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // **PENTING**: Fungsi untuk Registrasi (Placeholder)
  // API Anda belum memiliki endpoint registrasi. Anda perlu membuatnya terlebih dahulu di backend.
  // Misalnya: POST /api/auth/register
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    // try {
    //   final response = await http.post(
    //     Uri.parse('${ApiConfig.baseUrl}/api/auth/register'), // Endpoint ini perlu dibuat di backend Anda
    //     headers: {'Content-Type': 'application/json'},
    //     body: json.encode({
    //       'username': username,
    //       'email': email,
    //       'password': password,
    //     }),
    //   );
    //
    //   if (response.statusCode == 201) { // 201 Created
    //     return {'success': true, 'message': 'Registrasi berhasil! Silakan login.'};
    //   } else {
    //     final errorData = json.decode(response.body);
    //     return {'success': false, 'message': errorData['message'] ?? 'Registrasi gagal.'};
    //   }
    // } catch (e) {
    //   return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    // }
    await Future.delayed(
      const Duration(seconds: 1),
    ); // Hapus ini setelah endpoint siap
    return {
      'success': false,
      'message': 'Fitur registrasi via API belum siap.',
    };
  }
}
