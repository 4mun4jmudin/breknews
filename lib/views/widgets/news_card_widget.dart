// lib/views/widgets/news_card_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/article_model.dart';
import '../utils/helper.dart'
    as helper; // Masih bisa digunakan untuk fontWeight, fontSize jika tidak dari tema
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context); // Dapatkan tema saat ini
    final TextTheme textTheme =
        theme.textTheme; // Dapatkan skema teks dari tema
    final ColorScheme colorScheme =
        theme.colorScheme; // Dapatkan skema warna dari tema

    String formattedDate = article.publishedAt != null
        ? DateFormat('yyyy-MM-dd').format(article.publishedAt!)
        : 'No date';

    String categoryOrSource = article.sourceName?.isNotEmpty ?? false
        ? article.sourceName!
        : (article.author?.isNotEmpty ?? false ? article.author! : "General");

    return InkWell(
      onTap: () {
        context.pushNamed(RouteName.articleDetail, extra: article);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Gambar Artikel
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: article.urlToImage != null &&
                      article.urlToImage!.isNotEmpty
                  ? Image.network(
                      article.urlToImage!,
                      width: 100.0,
                      height: 100.0,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                          width: 100.0,
                          height: 100.0,
                          color: theme.highlightColor,
                          child: Icon(Icons.image_not_supported,
                              color: theme.hintColor.withOpacity(0.5),
                              size: 30)),
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                            width: 100.0,
                            height: 100.0,
                            color: theme.highlightColor,
                            child: Center(
                                child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.primary),
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            )));
                      },
                    )
                  : Container(
                      width: 100.0,
                      height: 100.0,
                      color: theme.highlightColor,
                      child: Icon(Icons.image_not_supported,
                          color: theme.hintColor.withOpacity(0.5), size: 30)),
            ),
            helper.hsMedium,

            // Konten Teks
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    article.title,
                    // Gunakan style dari textTheme, lalu kustomisasi jika perlu
                    style: textTheme.titleSmall?.copyWith(
                        fontWeight: helper.bold,
                        color: textTheme.bodyLarge?.color),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  helper.vsSuperTiny,
                  Text(
                    categoryOrSource,
                    style: textTheme.bodySmall?.copyWith(
                        color: textTheme.bodyMedium?.color?.withOpacity(0.7)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  helper.vsSuperTiny,
                  Text(
                    formattedDate,
                    style:
                        textTheme.labelSmall?.copyWith(color: theme.hintColor),
                  ),
                ],
              ),
            ),
            helper.hsTiny,

            // Ikon Bookmark
            InkWell(
              onTap: onBookmarkTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: isBookmarked
                      ? colorScheme.primary
                      : theme.hintColor, // Gunakan warna tema
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
