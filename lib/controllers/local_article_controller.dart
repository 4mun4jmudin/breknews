// lib/controllers/local_article_controller.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/article_model.dart';
import '../services/news_api_service.dart';

class LocalArticleController with ChangeNotifier {
  final NewsApiService _newsApiService = NewsApiService();

  List<Article> _myArticles = [];
  List<Article> get myArticles => List.unmodifiable(_myArticles);

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  LocalArticleController() {
    fetchMyArticles();
  }

  Future<void> fetchMyArticles() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Dapatkan username pengguna yang sedang login dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? currentUsername = prefs.getString('currentUsername');

      if (currentUsername == null || currentUsername.isEmpty) {
        throw Exception(
          "Sesi pengguna tidak ditemukan. Silakan login kembali.",
        );
      }

      // 2. Ambil semua artikel dari API
      final List<Article> allArticles = await _newsApiService.fetchTopHeadlines(
        category: null,
      );

      // 3. Saring artikel berdasarkan nama author
      _myArticles = allArticles.where((article) {
        return article.author?.trim().toLowerCase() ==
            currentUsername.trim().toLowerCase();
      }).toList();
    } catch (e) {
      _errorMessage = "Gagal memuat artikel Anda: ${e.toString()}";
      _myArticles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> removeArticle(Article articleToRemove) async {
    if (articleToRemove.sourceId == null || articleToRemove.sourceId!.isEmpty) {
      return {'success': false, 'message': 'Artikel tidak memiliki ID.'};
    }

    final result = await _newsApiService.deleteArticle(
      articleToRemove.sourceId!,
    );

    if (result['success'] == true) {
      // Hapus dari daftar di UI jika berhasil
      _myArticles.removeWhere(
        (article) => article.sourceId == articleToRemove.sourceId,
      );
      notifyListeners();
    }
    return result;
  }

  // Fungsi untuk me-refresh data
  Future<void> refresh() async {
    await fetchMyArticles();
  }
}
