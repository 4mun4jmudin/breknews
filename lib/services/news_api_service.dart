// lib/services/news_api_service.dart
import 'dart:convert';
// import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/article_model.dart';
import '../config/api_config.dart';

class NewsApiService {
  Future<Map<String, String>> _getHeaders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // --- FUNGSI INI DIPERBARUI DENGAN LOGIKA PARSING BARU ---
  Future<List<Article>> fetchTopHeadlines({String? category}) async {
    String url = '${ApiConfig.baseUrl}api/news';
    Map<String, String> queryParams = {'limit': '20'};

    if (category != null &&
        category.isNotEmpty &&
        category.toLowerCase() != 'all news') {
      queryParams['category'] = category;
    }

    String queryString = Uri(queryParameters: queryParams).query;
    if (queryString.isNotEmpty) {
      url += '?$queryString';
    }

    print('Requesting URL (Top Headlines): $url');

    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final dynamic jsonData = jsonDecode(response.body);
        List<dynamic>? articlesJson;

        // --- LOGIKA PARSING FLEKSIBEL DIMULAI DI SINI ---
        if (jsonData is Map<String, dynamic>) {
          // 1. Cek format ideal: { body: { data: [...] } }
          if (jsonData.containsKey('body') &&
              jsonData['body'] is Map &&
              jsonData['body'].containsKey('data') &&
              jsonData['body']['data'] is List) {
            articlesJson = jsonData['body']['data'] as List;
          }
          // 2. Cek format alternatif 1: { data: [...] }
          else if (jsonData.containsKey('data') && jsonData['data'] is List) {
            articlesJson = jsonData['data'] as List;
          }
          // 3. Cek format alternatif 2: { body: [...] }
          else if (jsonData.containsKey('body') && jsonData['body'] is List) {
            articlesJson = jsonData['body'] as List;
          }
        }
        // 4. Cek jika seluruh respons adalah sebuah list: [...]
        else if (jsonData is List) {
          articlesJson = jsonData;
        }
        // --- LOGIKA PARSING FLEKSIBEL SELESAI ---

        if (articlesJson != null) {
          // Jika daftar artikel ditemukan, proses seperti biasa
          return articlesJson
              .map((json) => Article.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          // Jika setelah semua pengecekan daftar artikel tidak ditemukan, baru lempar error.
          print("Format respons API tidak dikenali. Body: ${response.body}");
          throw Exception('Format respons API tidak sesuai.');
        }
      } else {
        throw Exception(
          'Gagal memuat berita: Server merespons dengan status code ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching top headlines: $e');
      // Kita lempar lagi error-nya agar bisa ditangkap oleh UI
      throw Exception('Gagal memuat berita: $e');
    }
  }

  // Fungsi di bawah ini tidak perlu diubah.
  Future<List<Article>> searchNews(String query) async {
    // ... (kode tetap sama)
    if (query.isEmpty) return [];

    final String encodedQuery = Uri.encodeComponent(query);
    String url = '${ApiConfig.baseUrl}api/news?search=$encodedQuery&limit=20';
    print('Requesting URL (Search): $url');

    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        if (jsonData.containsKey('body') &&
            jsonData['body'] is Map &&
            jsonData['body'].containsKey('data') &&
            jsonData['body']['data'] is List) {
          final List articlesJson = jsonData['body']['data'] as List;
          return articlesJson
              .map((json) => Article.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Format respons API tidak sesuai.');
        }
      } else {
        throw Exception(
          'Gagal mencari berita: Server merespons dengan status code ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error searching news: $e');
      throw Exception('Gagal mencari berita: $e');
    }
  }

  Future<Map<String, dynamic>> addArticle({
    required String title,
    required String content,
    required String category,
    required List<String> tags,
    String? imageUrl,
  }) async {
    try {
      final headers = await _getHeaders();
      var uri = Uri.parse('${ApiConfig.baseUrl}api/author/news');

      final body = json.encode({
        "title": title,
        "summary": content.length > 150 ? content.substring(0, 150) : content,
        "content": content,
        "featuredImageUrl": imageUrl ?? "",
        "category": category,
        "tags": tags,
        "isPublished": true,
      });

      var response = await http.post(uri, headers: headers, body: body);
      var responseBody = json.decode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          responseBody['body']['success'] == true) {
        // Jika sukses, parse data artikel dari respons
        final articleData = responseBody['body']['data'];
        final Article createdArticle = Article.fromJson(articleData);

        // Kembalikan objek artikel bersama dengan status sukses
        return {
          'success': true,
          'message': 'Artikel berhasil dipublikasikan!',
          'article': createdArticle, // <-- KEMBALIKAN OBJEK ARTIKEL
        };
      } else {
        String errorMessage =
            responseBody['body']?['message'] ??
            'Gagal memublikasikan artikel. Status: ${response.statusCode}';
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }
}
