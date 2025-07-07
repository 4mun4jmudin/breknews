// lib/views/widgets/local_articles_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/local_article_controller.dart';
import '../../data/models/article_model.dart';
import '../utils/helper.dart' as helper;
import 'news_card_widget.dart';
import '../../routes/route_name.dart';

class LocalArticlesScreen extends StatelessWidget {
  const LocalArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 20.0,
              bottom: 8.0,
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/icon.png',
                  height: 50.0,
                  width: 50.0,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.newspaper_rounded,
                      color: theme.colorScheme.primary,
                      size: 28.0,
                    );
                  },
                ),
                helper.hsLarge,
                Text(
                  "Berita Saya",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<LocalArticleController>(
              builder: (context, controller, child) {
                if (controller.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  );
                }

                if (controller.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        controller.errorMessage!,
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  );
                }

                if (controller.myArticles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 80,
                          color: theme.hintColor.withOpacity(0.6),
                        ),
                        helper.vsMedium,
                        Text(
                          'Anda belum mempublikasikan berita.',
                          style: textTheme.titleMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        helper.vsSmall,
                        Text(
                          'Tekan tombol "+" untuk membuat berita pertama Anda.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.refresh(),
                  color: theme.colorScheme.primary,
                  child: ListView.builder(
                    itemCount: controller.myArticles.length,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemBuilder: (context, index) {
                      final article = controller.myArticles[index];
                      return NewsCardWidget(
                        article: article,
                        isBookmarked: false, // Bookmark tidak relevan di sini
                        actions: [
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: theme.colorScheme.secondary,
                            ),
                            onPressed: () async {
                              // Navigasi ke layar edit, tunggu hasilnya untuk refresh
                              final result = await context.pushNamed<bool>(
                                RouteName.editArticle, // Pastikan route ini ada
                                extra: article,
                              );
                              if (result == true) {
                                controller.refresh();
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: theme.colorScheme.error,
                            ),
                            onPressed: () => _showDeleteDialog(
                              context,
                              controller,
                              article,
                              theme,
                            ),
                          ),
                        ],
                        onBookmarkTap: () {}, // Tidak ada aksi bookmark
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    LocalArticleController controller,
    Article article,
    ThemeData theme,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Hapus Artikel?'),
          content: Text('Anda yakin ingin menghapus "${article.title}"?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: Text(
                'Batal',
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: Text(
                'Hapus',
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                final result = await controller.removeArticle(article);
                Navigator.of(ctx).pop(); // Tutup dialog

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message']),
                      backgroundColor: result['success']
                          ? helper.cSuccess
                          : helper.cError,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
