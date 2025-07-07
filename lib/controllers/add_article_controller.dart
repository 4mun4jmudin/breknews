// lib/controllers/add_article_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/news_api_service.dart';
import '../services/image_upload_service.dart';

class AddArticleController with ChangeNotifier {
  final NewsApiService _newsApiService = NewsApiService();
  final ImageUploadService _imageUploadService = ImageUploadService();

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _statusMessage = "";
  String get statusMessage => _statusMessage;

  Future<Map<String, dynamic>> publishArticle({
    required String title,
    required String content,
    required String category,
    required String tagsString,
    File? imageFile,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? imageUrl;
      if (imageFile != null) {
        _statusMessage = "Mengunggah gambar...";
        notifyListeners();

        imageUrl = await _imageUploadService.uploadImage(imageFile);
        if (imageUrl == null) {
          throw Exception("Gagal mengunggah gambar ke server.");
        }
      }

      _statusMessage = "Memublikasikan artikel...";
      notifyListeners();

      final List<String> tagsList = tagsString
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final result = await _newsApiService.addArticle(
        title: title,
        content: content,
        category: category,
        tags: tagsList,
        imageUrl: imageUrl,
      );

      if (!result['success']) {
        _errorMessage = result['message'];
      }

      _statusMessage = "";
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      _statusMessage = "";
      return {'success': false, 'message': _errorMessage!};
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // --- [PERBAIKAN] Metode updateArticle yang sebelumnya terlewat, sekarang ditambahkan ---
  Future<Map<String, dynamic>> updateArticle({
    required String id,
    required String title,
    required String content,
    required String category,
    required String tagsString,
    File? imageFile,
    String? initialImageUrl, // URL gambar yang sudah ada
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? finalImageUrl = initialImageUrl;

      // Jika ada file gambar baru yang dipilih, unggah
      if (imageFile != null) {
        _statusMessage = "Mengunggah gambar baru...";
        notifyListeners();
        finalImageUrl = await _imageUploadService.uploadImage(imageFile);
        if (finalImageUrl == null) {
          throw Exception("Gagal mengunggah gambar baru ke server.");
        }
      }

      _statusMessage = "Memperbarui artikel...";
      notifyListeners();

      final List<String> tagsList = tagsString
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      // Panggil service untuk update
      final result = await _newsApiService.updateArticle(
        id: id,
        title: title,
        content: content,
        category: category,
        tags: tagsList,
        imageUrl: finalImageUrl,
      );

      if (!result['success']) {
        _errorMessage = result['message'];
      } else {
        // Kirim balik URL gambar yang baru (jika ada) agar UI bisa update
        result['newImageUrl'] = finalImageUrl;
      }

      _statusMessage = "";
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      _statusMessage = "";
      return {'success': false, 'message': _errorMessage!};
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
