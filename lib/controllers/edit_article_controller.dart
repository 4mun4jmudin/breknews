// lib/controllers/edit_article_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/news_api_service.dart';
import '../services/image_upload_service.dart';

class EditArticleController with ChangeNotifier {
  final NewsApiService _newsApiService = NewsApiService();
  final ImageUploadService _imageUploadService = ImageUploadService();

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _statusMessage = "";
  String get statusMessage => _statusMessage;

  Future<Map<String, dynamic>> updateArticle({
    required String id,
    required String title,
    required String content,
    required String category,
    required String tagsString,
    File? imageFile,
    String? initialImageUrl,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    _statusMessage = "Menyimpan perubahan...";
    notifyListeners();

    try {
      String? finalImageUrl = initialImageUrl;

      if (imageFile != null) {
        _statusMessage = "Mengunggah gambar baru...";
        notifyListeners();
        finalImageUrl = await _imageUploadService.uploadImage(imageFile);
        if (finalImageUrl == null) {
          throw Exception("Gagal mengunggah gambar baru.");
        }
      }

      _statusMessage = "Memperbarui artikel...";
      notifyListeners();

      final List<String> tagsList = tagsString
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final result = await _newsApiService.updateArticle(
        id: id,
        title: title,
        content: content,
        category: category,
        tags: tagsList,
        imageUrl: finalImageUrl,
      );

      if (result['success']) {
        result['newImageUrl'] = finalImageUrl;
      } else {
        _errorMessage = result['message'];
      }

      return result;
    } catch (e) {
      _errorMessage = e.toString();
      return {'success': false, 'message': _errorMessage!};
    } finally {
      _isSaving = false;
      _statusMessage = "";
      notifyListeners();
    }
  }
}
