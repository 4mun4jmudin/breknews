// lib/controllers/home_controller.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import '../services/news_api_service.dart';
import '../data/models/article_model.dart';
import '../services/database_helper.dart';

class HomeController with ChangeNotifier {
  final NewsApiService _newsApiService = NewsApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Article> _articles = [];
  List<Article> get articles => _articles;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Set<String> _bookmarkedArticleUrls = {};
  String? _currentUsername; // --- [BARU] Untuk menyimpan nama pengguna ---

  final List<String> categories = [
    "All News",
    "Business",
    "Technology",
    "Sports",
    "Entertainment",
    "Health",
    "Science",
  ];
  String _selectedCategory = "All News";
  String get selectedCategory => _selectedCategory;

  bool _isSearchActive = false;
  bool get isSearchActive => _isSearchActive;

  String? _currentSearchQuery;
  String? get currentSearchQuery => _currentSearchQuery;

  HomeController() {
    _initialize();
  }

  // --- [BARU] Fungsi inisialisasi ---
  Future<void> _initialize() async {
    await _getCurrentUser(); // Dapatkan data pengguna dulu
    await fetchArticlesByCategory(_selectedCategory); // Baru fetch berita
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // --- [BARU] Fungsi untuk mengambil username dari SharedPreferences ---
  Future<void> _getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUsername = prefs.getString('currentUsername');
    } catch (e) {
      debugPrint("HomeController: Gagal mendapatkan username: $e");
    }
  }

  Future<void> _loadBookmarkedStatus() async {
    try {
      final bookmarks = await _dbHelper.getAllBookmarks();
      _bookmarkedArticleUrls = bookmarks
          .map((article) => article.url!)
          .where((url) => url.isNotEmpty)
          .toSet();
    } catch (e) {
      debugPrint("HomeController: Error loading bookmark statuses: $e");
    }
  }

  Future<void> fetchArticlesByCategory(String category) async {
    _selectedCategory = category;
    _isSearchActive = false;
    _currentSearchQuery = null;
    _setLoading(true);
    _setError(null);
    notifyListeners();

    try {
      String? apiCategory = category.toLowerCase() == "all news"
          ? null
          : category;
      _articles = await _newsApiService.fetchTopHeadlines(
        category: apiCategory,
      );
    } catch (e) {
      _setError(e.toString());
      _articles = [];
    } finally {
      await _loadBookmarkedStatus();
      _setLoading(false);
    }
  }

  // Fungsi searchArticles tidak berubah
  void searchArticles(String query) {
    // ... implementasi pencarian
  }

  void onCategorySelected(String category) {
    if (_selectedCategory != category || _articles.isEmpty || _isSearchActive) {
      fetchArticlesByCategory(category);
    }
  }

  bool isArticleBookmarked(String? articleUrl) {
    if (articleUrl == null || articleUrl.isEmpty) return false;
    return _bookmarkedArticleUrls.contains(articleUrl);
  }

  Future<void> toggleBookmark(Article article) async {
    if (article.url == null || article.url!.isEmpty) return;
    final bool currentlyBookmarked = isArticleBookmarked(article.url);
    if (currentlyBookmarked) {
      _bookmarkedArticleUrls.remove(article.url!);
      await _dbHelper.removeBookmark(article.url!);
    } else {
      _bookmarkedArticleUrls.add(article.url!);
      await _dbHelper.addBookmark(article);
    }
    notifyListeners();
  }

  // --- [BARU] Fungsi untuk mengecek kepemilikan artikel ---
  bool isArticleOwned(Article article) {
    // Anggap artikel dimiliki jika nama author-nya sama dengan username yang login.
    // Pastikan perbandingan tidak case-sensitive dan menangani nilai null.
    if (_currentUsername == null || article.author == null) {
      return false;
    }
    return article.author!.trim().toLowerCase() ==
        _currentUsername!.trim().toLowerCase();
  }

  // --- [BARU] Fungsi untuk menghapus artikel dari API dan UI ---
  Future<Map<String, dynamic>> deleteArticle(Article article) async {
    if (article.sourceId == null) {
      return {
        'success': false,
        'message': 'Artikel tidak memiliki ID untuk dihapus.',
      };
    }

    // Panggil API untuk menghapus
    final result = await _newsApiService.deleteArticle(article.sourceId!);

    // Jika berhasil, hapus dari daftar di UI
    if (result['success'] == true) {
      _articles.removeWhere((a) => a.sourceId == article.sourceId);
      notifyListeners();
    }

    return result;
  }
}
