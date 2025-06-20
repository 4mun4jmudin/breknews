import 'package:flutter/material.dart';
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

  // --- SESUAIKAN KATEGORI DENGAN API BARU ---
  // API baru Anda sepertinya tidak memiliki 'Headline' atau 'Top Stories' secara spesifik,
  // jadi kita gunakan kategori umum. 'All News' akan kita handle untuk mengambil semua.
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

  // Fitur sorting dari API lama kita hilangkan sementara karena API baru tidak menentukannya
  // di endpoint publik.
  // String _currentSortBy = 'publishedAt';
  // String get currentSortBy => _currentSortBy;
  // final Map<String, String> sortByOptionsDisplay = const { ... };

  HomeController() {
    fetchArticlesByCategory(_selectedCategory);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> _loadBookmarkedStatus() async {
    try {
      final bookmarks = await _dbHelper.getAllBookmarks();
      _bookmarkedArticleUrls = bookmarks
          .map((article) => article.url!)
          .where((url) => url.isNotEmpty)
          .toSet();
    } catch (e) {
      print("HomeController: Error loading bookmark statuses: $e");
    }
  }

  // --- GANTI NAMA FUNGSI & LOGIKANYA ---
  Future<void> fetchArticlesByCategory(String category) async {
    _selectedCategory = category;
    _isSearchActive = false;
    _currentSearchQuery = null;
    _setLoading(true);
    _setError(null);
    _articles = [];

    try {
      // Jika kategori adalah 'All News', kita tidak mengirim parameter kategori
      String? apiCategory = category.toLowerCase() == "all news"
          ? null
          : category;

      // Gunakan method fetchTopHeadlines yang sudah kita modifikasi
      _articles = await _newsApiService.fetchTopHeadlines(
        category: apiCategory,
      );
      await _loadBookmarkedStatus();
    } catch (e) {
      _setError(e.toString());
      _articles = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchArticles(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      fetchArticlesByCategory(categories.first);
      return;
    }

    _currentSearchQuery = trimmedQuery;
    _isSearchActive = true;
    _selectedCategory = ""; // Kosongkan kategori saat mencari
    _setLoading(true);
    _setError(null);
    _articles = [];

    try {
      // Gunakan method searchNews yang sudah kita modifikasi
      _articles = await _newsApiService.searchNews(trimmedQuery);
      await _loadBookmarkedStatus();
    } catch (e) {
      _setError(e.toString());
      _articles = [];
    } finally {
      _setLoading(false);
    }
  }

  // Fungsi sorting kita non-aktifkan
  // Future<void> setSortOrder(String newSortBy) async { ... }

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
    if (article.url == null || article.url!.isEmpty) {
      _setError("Artikel tidak memiliki URL yang valid untuk di-bookmark.");
      notifyListeners();
      return;
    }

    final bool currentlyBookmarked = isArticleBookmarked(article.url);
    bool successOperation;

    if (currentlyBookmarked) {
      _bookmarkedArticleUrls.remove(article.url!);
      successOperation = await _dbHelper.removeBookmark(article.url!);
      if (!successOperation) {
        _bookmarkedArticleUrls.add(article.url!);
        _setError("Gagal menghapus bookmark dari database.");
      }
    } else {
      _bookmarkedArticleUrls.add(article.url!);
      successOperation = await _dbHelper.addBookmark(article);
      if (!successOperation) {
        _bookmarkedArticleUrls.remove(article.url!);
        _setError("Gagal menambahkan bookmark ke database.");
      }
    }
    notifyListeners();
  }
}
