// lib/controllers/home_controller.dart

import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import '../services/news_api_service.dart';
import '../data/models/article_model.dart';
import '../services/database_helper.dart';

class HomeController with ChangeNotifier {
  final NewsApiService _newsApiService = NewsApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Article> _masterArticleList = [];

  List<Article> _articles = [];
  List<Article> get articles => _articles;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Set<String> _bookmarkedArticleUrls = {};

  List<String> _categories = ["All News"];
  List<String> get categories => _categories;

  String _selectedCategory = "All News";
  String get selectedCategory => _selectedCategory;

  bool _isSearchActive = false;
  bool get isSearchActive => _isSearchActive;

  String? _currentSearchQuery;
  String? get currentSearchQuery => _currentSearchQuery;

  HomeController() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    // Jalankan pengambilan data pendukung secara bersamaan
    await Future.wait([_loadBookmarkedStatus(), _fetchCategoriesFromApi()]);

    // Ambil semua berita dari API dan simpan ke daftar utama
    await _fetchAllArticles();

    _isLoading = false;
    notifyListeners();
  }

  /// Mengambil semua artikel dari API dan menyimpannya di _masterArticleList.
  Future<void> _fetchAllArticles() async {
    try {
      _masterArticleList = await _newsApiService.fetchTopHeadlines();
      // Saat pertama kali dimuat, daftar yang ditampilkan adalah semua berita.
      _articles = List.from(_masterArticleList);
    } catch (e) {
      _errorMessage = e.toString();
      _articles = [];
      _masterArticleList = [];
    }
  }

  /// #2: Fungsi filter utama yang bekerja di sisi klien (client-side).
  void onCategorySelected(String category) {
    _selectedCategory = category;
    _isSearchActive = false;
    _currentSearchQuery = null;

    // Jika "All News" dipilih, tampilkan semua berita dari daftar master.
    if (category.toLowerCase() == "all news") {
      _articles = List.from(_masterArticleList);
    } else {
      // Jika kategori lain dipilih, saring daftar master berdasarkan kategori.
      _articles = _masterArticleList.where((article) {
        return article.category?.toLowerCase() == category.toLowerCase();
      }).toList();
    }

    // Perbarui UI untuk menampilkan hasil filter.
    notifyListeners();
  }

  /// #3: Mengambil daftar kategori unik dari artikel di API.
  Future<void> _fetchCategoriesFromApi() async {
    try {
      // Ambil contoh artikel untuk diekstrak kategorinya
      final sampleArticles = await _newsApiService.fetchTopHeadlines();
      if (sampleArticles.isNotEmpty) {
        final categorySet = <String>{};
        for (var article in sampleArticles) {
          if (article.category != null && article.category!.isNotEmpty) {
            categorySet.add(article.category!);
          }
        }
        _categories = ["All News", ...categorySet.toList()..sort()];
      }
    } catch (e) {
      debugPrint("Gagal mengambil kategori dari API: $e");
      // Jika gagal, gunakan daftar statis sebagai cadangan.
      _categories = [
        "All News",
        "Business",
        "Technology",
        "Sports",
        "Entertainment",
        "Health",
        "Science",
      ];
    }
  }

  /// Fungsi untuk me-refresh semua data dari API.
  Future<void> refreshData() async {
    await _initialize();
  }

  /// Memuat status bookmark dari database lokal.
  Future<void> _loadBookmarkedStatus() async {
    try {
      final bookmarks = await _dbHelper.getAllBookmarks();
      _bookmarkedArticleUrls = bookmarks
          .map((article) => article.url!)
          .where((url) => url.isNotEmpty)
          .toSet();
    } catch (e) {
      debugPrint("Error memuat status bookmark: $e");
    }
  }

  /// Melakukan pencarian artikel.
  void searchArticles(String query) {
    if (query.trim().isEmpty) {
      // Jika query kosong, kembali tampilkan sesuai kategori yang terakhir dipilih
      onCategorySelected(_selectedCategory);
      return;
    }

    _isSearchActive = true;
    _currentSearchQuery = query;

    // Lakukan pencarian pada daftar master, bukan memanggil API
    _articles = _masterArticleList.where((article) {
      return article.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    notifyListeners();
  }

  /// Mengecek apakah sebuah artikel sudah di-bookmark.
  bool isArticleBookmarked(String? articleUrl) {
    if (articleUrl == null || articleUrl.isEmpty) return false;
    return _bookmarkedArticleUrls.contains(articleUrl);
  }

  /// Menambah atau menghapus artikel dari bookmark.
  Future<void> toggleBookmark(Article article) async {
    if (article.url == null || article.url!.isEmpty) return;

    final isCurrentlyBookmarked = isArticleBookmarked(article.url);
    if (isCurrentlyBookmarked) {
      _bookmarkedArticleUrls.remove(article.url);
      await _dbHelper.removeBookmark(article.url!);
    } else {
      _bookmarkedArticleUrls.add(article.url!);
      await _dbHelper.addBookmark(article);
    }
    notifyListeners();
  }
}
