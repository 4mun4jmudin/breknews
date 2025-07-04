// lib/controllers/local_article_controller.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart'; // Import path_provider
import 'package:path/path.dart' as p; // Import path package with an alias
import '../data/models/article_model.dart';

const String _localArticlesKey = 'local_articles_data';

class LocalArticleController with ChangeNotifier {
  List<Article> _localArticlesList = [];
  bool _isLoadingInitialData = true;
  List<Article> get localArticles => List.unmodifiable(_localArticlesList);
  bool get isLoadingInitialData => _isLoadingInitialData;

  LocalArticleController() {
    _loadArticlesFromPrefs();
  }

  Future<String?> _copyImageToAppDirectory(File originalImageFile) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String fileName = p.basename(originalImageFile.path);
      final String newFilePath = p.join(
        appDocDir.path,
        'local_article_images',
        fileName,
      );

      final Directory imageDir = Directory(
        p.join(appDocDir.path, 'local_article_images'),
      );
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      final File newImageFile = await originalImageFile.copy(newFilePath);
      debugPrint('Image copied to: ${newImageFile.path}');
      return newImageFile.path;
    } catch (e) {
      debugPrint('Error copying image: $e');
      return null;
    }
  }

  Future<void> _saveArticlesToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> dataToSave = {
        "status": "ok",
        "totalResults": _localArticlesList.length,
        "articles": _localArticlesList
            .map((article) => article.toJson())
            .toList(),
      };
      String jsonString = jsonEncode(dataToSave);
      await prefs.setString(_localArticlesKey, jsonString);
      debugPrint('Local articles saved to SharedPreferences.');
    } catch (e) {
      debugPrint('Error saving local articles to SharedPreferences: $e');
    }
  }

  Future<void> _loadArticlesFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString(_localArticlesKey);
      if (jsonString != null) {
        Map<String, dynamic> storedData = jsonDecode(jsonString);
        if (storedData['status'] == 'ok' && storedData['articles'] != null) {
          List<dynamic> articlesJson = storedData['articles'];
          _localArticlesList = articlesJson
              .map((json) => Article.fromJson(json as Map<String, dynamic>))
              .toList();
          debugPrint(
            'Local articles loaded from SharedPreferences: ${_localArticlesList.length} articles.',
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading local articles from SharedPreferences: $e');
      _localArticlesList = [];
    } finally {
      _isLoadingInitialData = false;
      notifyListeners();
    }
  }

  Future<void> addLocalArticle({
    required String title,
    required String content,
    String? authorInput,
    File? imageFile,
  }) async {
    String? finalImagePath;
    if (imageFile != null) {
      finalImagePath = await _copyImageToAppDirectory(imageFile);
    }

    final newArticle = Article(
      title: title,
      content: content,
      author: authorInput,
      sourceId: "local_source",
      sourceName: authorInput ?? "Local Entry",
      publishedAt: DateTime.now(),
      urlToImage: finalImagePath,
      description: content.length > 150
          ? '${content.substring(0, 147)}...'
          : content,
      url: null,
    );

    _localArticlesList.insert(0, newArticle);
    await _saveArticlesToPrefs();
    notifyListeners();
    debugPrint('Local article added and saved: ${newArticle.title}');
    debugPrint('Image path saved: ${newArticle.urlToImage}');
    debugPrint('Total local articles: ${_localArticlesList.length}');
  }

  Future<void> removeLocalArticle(Article articleToRemove) async {
    if (articleToRemove.urlToImage != null &&
        articleToRemove.urlToImage!.isNotEmpty) {
      try {
        final imageFile = File(articleToRemove.urlToImage!);
        if (await imageFile.exists()) {
          await imageFile.delete();
          debugPrint('Local image file deleted: ${articleToRemove.urlToImage}');
        }
      } catch (e) {
        debugPrint('Error deleting local image file: $e');
      }
    }

    int initialLength = _localArticlesList.length;
    _localArticlesList.removeWhere((article) {
      bool titleMatch = article.title == articleToRemove.title;
      bool timestampMatch = article.publishedAt == articleToRemove.publishedAt;
      bool imageMatch = article.urlToImage == articleToRemove.urlToImage;
      return titleMatch && timestampMatch && imageMatch;
    });

    if (_localArticlesList.length < initialLength) {
      await _saveArticlesToPrefs();
      notifyListeners();
      debugPrint('Local article removed and saved: ${articleToRemove.title}');
    } else {
      debugPrint(
        'Could not find local article to remove: ${articleToRemove.title}',
      );
    }
  }

  Future<void> addNewlyCreatedArticle(Article article) async {
    _localArticlesList.insert(0, article);
    await _saveArticlesToPrefs();
    notifyListeners();
    debugPrint(
      'Artikel baru dari server berhasil disimpan secara lokal: ${article.title}',
    );
  }
}
