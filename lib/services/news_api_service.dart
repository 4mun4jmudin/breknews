// lib/services/news_api_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/article_model.dart';
import '../config/api_config.dart';

class NewsApiService {
  // ... (Fungsi _getHeaders, fetchTopHeadlines, searchNews, dan addArticle tidak berubah)
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

  Future<List<Article>> fetchTopHeadlines({String? category}) async {
    String url = '${ApiConfig.baseUrl}api/news';
    Map<String, String> queryParams = {'limit': '50'};

    if (category != null &&
        category.isNotEmpty &&
        category.toLowerCase() != 'all news') {
      queryParams['category'] = category;
    }

    String queryString = Uri(queryParameters: queryParams).query;
    if (queryString.isNotEmpty) {
      url += '?$queryString';
    }

    debugPrint('Requesting URL (Top Headlines): $url');

    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final dynamic jsonData = jsonDecode(response.body);
        if (jsonData['body'] != null &&
            jsonData['body']['success'] == true &&
            jsonData['body']['data'] is List) {
          final List<dynamic> articlesJson = jsonData['body']['data'];
          return articlesJson
              .map((json) => Article.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          debugPrint(
            "Format respons API tidak sesuai atau success:false. Body: ${response.body}",
          );
          return [];
        }
      } else {
        throw Exception(
          'Gagal memuat berita: Server merespons dengan status code ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error di fetchTopHeadlines: $e');
      throw Exception('Gagal memuat berita: $e');
    }
  }

  Future<List<Article>> searchNews(String query) async {
    if (query.isEmpty) return [];

    final String encodedQuery = Uri.encodeComponent(query);
    String url = '${ApiConfig.baseUrl}api/news?search=$encodedQuery&limit=20';
    debugPrint('Requesting URL (Search): $url');

    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final dynamic jsonData = jsonDecode(response.body);
        if (jsonData['body'] != null &&
            jsonData['body']['success'] == true &&
            jsonData['body']['data'] is List) {
          final List<dynamic> articlesJson = jsonData['body']['data'];
          return articlesJson
              .map((json) => Article.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          debugPrint(
            "Respons pencarian tidak valid atau success:false. Body: ${response.body}",
          );
          return [];
        }
      } else {
        throw Exception(
          'Pencarian gagal: Server merespons dengan status code ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error di searchNews: $e');
      throw Exception('Gagal melakukan pencarian: $e');
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
        final articleData = responseBody['body']['data'];
        final Article createdArticle = Article.fromJson(articleData);
        return {
          'success': true,
          'message': 'Artikel berhasil dipublikasikan!',
          'article': createdArticle,
        };
      } else {
        return {'success': false, 'message': responseBody['body']?['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  // --- [DIPERBAIKI] FUNGSI UNTUK MENGUPDATE ARTIKEL ---
  Future<Map<String, dynamic>> updateArticle({
    required String id, // Menggunakan ID
    required String title,
    required String content,
    required String category,
    required List<String> tags,
    String? imageUrl,
  }) async {
    try {
      final headers = await _getHeaders();
      var uri = Uri.parse(
        '${ApiConfig.baseUrl}api/author/news/$id',
      ); // Endpoint diubah ke /id

      final body = json.encode({
        "title": title,
        "summary": content.length > 150 ? content.substring(0, 150) : content,
        "content": content,
        "featuredImageUrl": imageUrl,
        "category": category,
        "tags": tags,
        "isPublished": true, // Field ditambahkan sesuai dokumentasi
      });

      var response = await http.put(uri, headers: headers, body: body);
      var responseBody = json.decode(response.body);

      if (response.statusCode == 200 &&
          responseBody['body']?['success'] == true) {
        return {'success': true, 'message': 'Artikel berhasil diperbarui!'};
      } else {
        return {
          'success': false,
          'message':
              responseBody['body']?['message'] ?? 'Gagal memperbarui artikel.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  // --- [DIPERBAIKI] FUNGSI UNTUK MENGHAPUS ARTIKEL ---
  Future<Map<String, dynamic>> deleteArticle(String id) async {
    // Menggunakan ID
    try {
      final headers = await _getHeaders();
      var uri = Uri.parse(
        '${ApiConfig.baseUrl}api/author/news/$id',
      ); // Endpoint diubah ke /id

      var response = await http.delete(uri, headers: headers);

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        if (responseBody['body']?['success'] == true) {
          return {'success': true, 'message': 'Artikel berhasil dihapus!'};
        } else {
          return {
            'success': false,
            'message':
                responseBody['body']?['message'] ??
                'Gagal menghapus artikel dari server.',
          };
        }
      } else {
        return {
          'success': false,
          'message':
              'Gagal menghapus: Server merespons dengan status ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }
}
