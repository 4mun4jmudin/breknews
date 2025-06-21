// lib/views/widgets/add_local_article_screen.dart
// ignore_for_file: deprecated_member_use, use_build_context_synchronously, duplicate_ignore

import 'dart:io';
import 'package:breaknews/controllers/local_article_controller.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/article_model.dart';
import '../utils/helper.dart' as helper;
import '../../routes/route_name.dart';
import '../../controllers/add_article_controller.dart';

class AddLocalArticleScreen extends StatefulWidget {
  const AddLocalArticleScreen({super.key});

  @override
  State<AddLocalArticleScreen> createState() => _AddLocalArticleScreenState();
}

class _AddLocalArticleScreenState extends State<AddLocalArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  String? _selectedCategory;
  File? _selectedImageFile; // <-- Diaktifkan kembali

  final List<String> _categories = [
    'Technology',
    'Sports',
    'Health',
    'Business',
    'Entertainment',
    'Science',
  ];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1000,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: ${e.toString()}')),
        );
      }
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Ambil dari Kamera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              if (_selectedImageFile != null)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Hapus Gambar',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedImageFile = null;
                    });
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveArticle(AddArticleController controller) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Silakan pilih kategori.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final result = await controller.publishArticle(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _selectedCategory!,
      tagsString: _tagsController.text,
      imageFile: _selectedImageFile,
    );

    if (mounted) {
      if (result['success']) {
        // --- LOGIKA BARU DITAMBAHKAN DI SINI ---
        // 1. Ambil objek artikel dari hasil respons
        final Article newArticleFromServer = result['article'];

        // 2. Dapatkan instance LocalArticleController dari Provider
        final localArticleController = Provider.of<LocalArticleController>(
          context,
          listen: false,
        );

        // 3. Panggil metode untuk menyimpan artikel secara lokal
        await localArticleController.addNewlyCreatedArticle(
          newArticleFromServer,
        );
        // ------------------------------------------

        // Lanjutkan alur yang sudah ada
        await _showSuccessDialog();

        _titleController.clear();
        _contentController.clear();
        _tagsController.clear();
        setState(() {
          _selectedImageFile = null;
          _selectedCategory = null;
        });

        context.goNamed(RouteName.home);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Terjadi kesalahan.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddArticleController(),
      child: Consumer<AddArticleController>(
        builder: (context, controller, child) {
          final ThemeData theme = Theme.of(context);
          return Scaffold(
            appBar: AppBar(title: const Text("Publish New Article")),
            body: AbsorbPointer(
              absorbing: controller.isSaving,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // --- UI Pemilih Gambar Diaktifkan Kembali ---
                      GestureDetector(
                        onTap: () => _showImageSourceActionSheet(context),
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: _selectedImageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(11.0),
                                  child: Image.file(
                                    _selectedImageFile!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 40,
                                      color: theme.hintColor,
                                    ),
                                    helper.vsSmall,
                                    Text(
                                      'Tambah Foto Sampul',
                                      style: TextStyle(color: theme.hintColor),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      helper.vsLarge,

                      // ... (Sisa form fields tetap sama, tidak perlu diubah)
                      Text(
                        "News Details",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      helper.vsMedium,

                      _buildTextField(
                        controller: _titleController,
                        labelText: "Title",
                        hintText: "Enter news title",
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Title cannot be empty.';
                          }
                          if (value.trim().length < 10) {
                            return 'Title must be at least 10 characters.';
                          }
                          return null;
                        },
                      ),
                      helper.vsMedium,
                      Text(
                        'Select Category*',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      helper.vsSuperTiny,
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        hint: Text(
                          'Select category',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: theme.hintColor,
                        ),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: theme.brightness == Brightness.dark
                              ? theme.inputDecorationTheme.fillColor
                              : helper.cGrey.withOpacity(0.7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        dropdownColor: theme.cardColor,
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Please select a category' : null,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      helper.vsMedium,

                      _buildTextField(
                        controller: _contentController,
                        labelText: "Add News/Article",
                        hintText: "Type News/Article Here ...",
                        maxLines: 8,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Content cannot be empty.';
                          }
                          if (value.trim().length < 20) {
                            return 'Content must be at least 20 characters.';
                          }
                          return null;
                        },
                      ),
                      helper.vsMedium,

                      _buildTextField(
                        controller: _tagsController,
                        labelText: "Add Tag",
                        hintText: "Enter tags, separated by commas",
                        validator: (value) {
                          if (value != null &&
                              value.trim().isNotEmpty &&
                              value.trim().length < 3) {
                            return 'Tag must be at least 3 characters if provided.';
                          }
                          return null;
                        },
                      ),
                      helper.vsLarge,
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.fromLTRB(
                16.0,
                8.0,
                16.0,
                MediaQuery.of(context).padding.bottom + 16.0,
              ),
              child: ElevatedButton(
                onPressed: () => _saveArticle(controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: controller.isSaving
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            controller.statusMessage.isNotEmpty
                                ? controller.statusMessage
                                : 'Menyimpan...',
                          ),
                        ],
                      )
                    : const Text('Publish Now'),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Helper widgets dan functions tidak perlu diubah ---
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && Navigator.of(dialogContext).canPop()) {
            Navigator.of(dialogContext).pop();
          }
        });
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Theme.of(context).cardColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              helper.vsMedium,
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: helper.cSuccess.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  color: helper.cSuccess,
                  size: 60.0,
                ),
              ),
              helper.vsLarge,
              Text(
                "Great!",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: helper.cSuccess,
                ),
              ),
              helper.vsSmall,
              Text(
                "Your Article Was Successfully Published",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.color?.withOpacity(0.8),
                ),
              ),
              helper.vsLarge,
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? prefixIcon,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$labelText*',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.textTheme.bodyMedium?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        helper.vsSuperTiny,
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.textTheme.bodyLarge?.color,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor,
            ),
            prefixIcon: prefixIcon,
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? theme.inputDecorationTheme.fillColor
                : helper.cGrey.withOpacity(0.7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          textCapitalization: maxLines > 1
              ? TextCapitalization.sentences
              : TextCapitalization.words,
        ),
      ],
    );
  }
}
