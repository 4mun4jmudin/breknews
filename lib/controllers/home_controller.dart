import 'package:flutter/material.dart';
import '../services/news_api_service.dart';
import '../data/models/article_model.dart';
import '../services/database_helper.dart';

class HomeController with ChangeNotifier {
  final NewsApiService _newsApiService = NewsApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Article> _unfilteredArticles = [];
  List<Article> _articles = [];
  List<Article> get articles => _articles;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Set<String> _bookmarkedArticleUrls = {};

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
      final fetchedArticles = await _newsApiService.fetchTopHeadlines(
        category: apiCategory,
      );

      _unfilteredArticles = fetchedArticles;
      _articles = fetchedArticles;
    } catch (e) {
      _setError(e.toString());
      _articles = [];
    } finally {
      await _loadBookmarkedStatus();
      _setLoading(false);
    }
  }

  // --- FUNGSI PENCARIAN DIPERBARUI TOTAL ---
  void searchArticles(String query) {
    final trimmedQuery = query.trim().toLowerCase();
    _currentSearchQuery = query;

    if (trimmedQuery.isEmpty) {
      _articles = List.from(_unfilteredArticles);
      _isSearchActive = false;
    } else {
      _isSearchActive = true;
      _articles = _unfilteredArticles.where((article) {
        final titleMatches = article.title.toLowerCase().contains(trimmedQuery);
        final contentMatches = (article.content ?? '').toLowerCase().contains(
          trimmedQuery,
        );
        final categoryMatches = (article.category ?? '').toLowerCase().contains(
          trimmedQuery,
        );

        return titleMatches || contentMatches || categoryMatches;
      }).toList();
    }

    notifyListeners();
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
    if (article.url == null || article.url!.isEmpty) {
      return;
    }
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
}
