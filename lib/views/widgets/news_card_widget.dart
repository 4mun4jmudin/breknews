// lib/views/widgets/news_card_widget.dart
import 'dart:io'; // Import untuk File
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/article_model.dart';
import '../utils/helper.dart' as helper;
import '../../routes/route_name.dart';

class NewsCardWidget extends StatelessWidget {
  final Article article;
  final bool isBookmarked;
  final VoidCallback onBookmarkTap;

  const NewsCardWidget({
    super.key,
    required this.article,
    required this.isBookmarked,
    required this.onBookmarkTap,
  });

  Widget _buildErrorImage(ThemeData theme) {
    return Container(
      width: 100.0,
      height: 100.0,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: theme.hintColor.withOpacity(0.5),
        size: 40,
      ),
    );
  }

  Widget _buildLoadingImage(
    ThemeData theme,
    ColorScheme colorScheme,
    ImageChunkEvent loadingProgress,
  ) {
    return Container(
      width: 100.0,
      height: 100.0,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;

    String formattedDate = article.publishedAt != null
        ? DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(article.publishedAt!)
        : 'No date available';

    String sourceDisplay = article.sourceName?.isNotEmpty ?? false
        ? article.sourceName!
        : (article.author?.isNotEmpty ?? false
              ? article.author!
              : "Unknown Source");

    bool isLocalArticle = article.url == null || article.url!.isEmpty;

    Widget imageWidget;
    if (article.urlToImage != null && article.urlToImage!.isNotEmpty) {
      if (article.urlToImage!.startsWith('http')) {
        imageWidget = Image.network(
          article.urlToImage!,
          width: 100.0,
          height: 100.0,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildErrorImage(theme),
          loadingBuilder:
              (
                BuildContext context,
                Widget child,
                ImageChunkEvent? loadingProgress,
              ) {
                if (loadingProgress == null) return child;
                return _buildLoadingImage(theme, colorScheme, loadingProgress);
              },
        );
      } else {
        File imageFile = File(article.urlToImage!);
        if (imageFile.existsSync()) {
          imageWidget = Image.file(
            imageFile,
            width: 100.0,
            height: 100.0,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint(
                "Error loading local image file: ${imageFile.path}, Error: $error",
              );
              return _buildErrorImage(theme);
            },
          );
        } else {
          debugPrint("Local image file does not exist: ${imageFile.path}");
          imageWidget = _buildErrorImage(theme);
        }
      }
    } else {
      imageWidget = _buildErrorImage(theme);
    }

    return InkWell(
      onTap: () {
        context.pushNamed(RouteName.articleDetail, extra: article);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: imageWidget,
            ),
            helper.hsMedium,
            Expanded(
              child: SizedBox(
                height: 100.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textTheme.bodyLarge?.color,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        helper.vsSuperTiny,
                        Text(
                          sourceDisplay,
                          style: textTheme.bodySmall?.copyWith(
                            color: textTheme.bodyMedium?.color?.withOpacity(
                              0.7,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Text(
                      formattedDate,
                      style: textTheme.labelSmall?.copyWith(
                        color: theme.hintColor.withOpacity(0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            helper.hsTiny,
            InkWell(
              onTap: onBookmarkTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Icon(
                  isLocalArticle
                      ? Icons.delete_outline_rounded
                      : (isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded),
                  color: isLocalArticle
                      ? theme.colorScheme.error.withOpacity(0.8)
                      : (isBookmarked ? colorScheme.primary : theme.hintColor),
                  size: 24.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
