// lib/controllers/edit_profile_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileController with ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController cityController;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  File? _selectedImageFile;
  File? get selectedImageFile => _selectedImageFile;

  String? _initialProfileImagePath;
  String? get initialProfileImagePath => _initialProfileImagePath;

  bool _imageWasRemoved = false;

  bool get imageWasRemoved => _imageWasRemoved;

  EditProfileController({required String userId}) {
    usernameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    cityController = TextEditingController();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      usernameController.text = prefs.getString('currentUsername') ?? '';
      emailController.text = prefs.getString('currentUserEmail') ?? '';

      phoneController.text = prefs.getString('localPhoneNumber') ?? '';
      addressController.text = prefs.getString('localAddress') ?? '';
      cityController.text = prefs.getString('localCity') ?? '';

      _initialProfileImagePath =
          prefs.getString('localProfilePicPath') ??
          prefs.getString('currentUserAvatarUrl');
    } catch (e) {
      _errorMessage = "Gagal memuat data untuk diedit: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        _selectedImageFile = File(pickedFile.path);
        _imageWasRemoved = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Gagal memilih gambar: $e";
      notifyListeners();
    }
  }

  void removeProfileImage() {
    _selectedImageFile = null;
    _imageWasRemoved = true;
    notifyListeners();
  }

  Future<Map<String, dynamic>> saveProfileChanges() async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('currentUsername', usernameController.text);
      await prefs.setString('localPhoneNumber', phoneController.text);
      await prefs.setString('localAddress', addressController.text);
      await prefs.setString('localCity', cityController.text);

      if (_selectedImageFile != null) {
        await prefs.setString('localProfilePicPath', _selectedImageFile!.path);
      } else if (_imageWasRemoved) {
        await prefs.remove('localProfilePicPath');
        await prefs.remove('currentUserAvatarUrl');
      }

      return {'success': true, 'message': 'Profil berhasil diperbarui!'};
    } catch (e) {
      _errorMessage = "Error menyimpan profil: $e";
      return {'success': false, 'message': _errorMessage!};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    super.dispose();
  }
}
