// lib/services/news_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/article_model.dart';

class NewsApiService {
  static const String _baseUrl = 'http://45.149.187.204:3000';

  Future<List<Article>> fetchTopHeadlines({String? category}) async {
    String url = '$_baseUrl/api/news';
    Map<String, String> queryParams = {'limit': '20'};
    if (category != null &&
        category.isNotEmpty &&
        category.toLowerCase() != 'all news') {
      queryParams['category'] = category.toLowerCase();
    }

    String queryString = Uri(queryParameters: queryParams).query;
    url += '?$queryString';
    print('Requesting URL (Top Headlines): $url');

    try {
      final response = await http.get(Uri.parse(url));

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
          throw Exception(
            'Format respons API tidak sesuai: key "body" atau "data" tidak ditemukan.',
          );
        }
      } else {
        throw Exception(
          'Gagal memuat berita: Server merespons dengan status code ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching top headlines: $e');
      throw Exception('Gagal memuat berita: $e');
    }
  }

  Future<List<Article>> searchNews(String query) async {
    if (query.isEmpty) return [];

    final String encodedQuery = Uri.encodeComponent(query);
    String url = '$_baseUrl/news?search=$encodedQuery&limit=20';
    print('Requesting URL (Search): $url');

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        // --- PERUBAHAN UTAMA DI SINI JUGA ---
        if (jsonData.containsKey('body') &&
            jsonData['body'] is Map &&
            jsonData['body'].containsKey('data') &&
            jsonData['body']['data'] is List) {
          final List articlesJson = jsonData['body']['data'] as List;
          return articlesJson
              .map((json) => Article.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception(
            'Format respons API tidak sesuai: key "body" atau "data" tidak ditemukan.',
          );
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
}
