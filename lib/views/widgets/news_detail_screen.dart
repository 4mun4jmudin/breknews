// lib/views/widgets/news_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Untuk context.pop()
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:url_launcher/url_launcher.dart'; // Untuk membuka URL

import '../../data/models/article_model.dart'; // Model Artikel
import '../utils/helper.dart'
    as helper; // Helper Anda (mungkin untuk fontWeight, spasi)

class NewsDetailScreen extends StatelessWidget {
  final Article article;

  const NewsDetailScreen({super.key, required this.article});

  Future<void> _launchURL(BuildContext context, String? urlString) async {
    // Tambahkan BuildContext untuk SnackBar
    if (urlString == null || urlString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL tidak tersedia untuk artikel ini.')),
      );
      return;
    }
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak bisa membuka link: $urlString')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;

    String formattedDate = article.publishedAt != null
        ? DateFormat('EEEE, dd MMMM yyyy, HH:mm',
                'id_ID') // Format tanggal Indonesia
            .format(article.publishedAt!)
        : 'Tanggal tidak tersedia';

    String authorDisplay = article.author?.isNotEmpty ?? false
        ? article.author!
        : (article.sourceName?.isNotEmpty ?? false
            ? article.sourceName!
            : 'Sumber tidak diketahui'); // Diubah dari "Penulis"

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor, // Warna background dari tema
      appBar: AppBar(
        backgroundColor:
            theme.appBarTheme.backgroundColor, // Warna AppBar dari tema
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: theme.appBarTheme.foregroundColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          article.sourceName ?? 'Detail Berita',
          style: theme.appBarTheme.titleTextStyle,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // TODO: Tambahkan logika dan ikon bookmark yang benar
          // IconButton(
          //   icon: Icon(Icons.bookmark_border_outlined, color: theme.appBarTheme.foregroundColor),
          //   onPressed: () {
          //     // Logika untuk menambah/menghapus bookmark
          //   },
          // ),
          IconButton(
            icon: Icon(Icons.share_outlined,
                color: theme.appBarTheme.foregroundColor),
            onPressed: () {
              // TODO: Implementasi fungsi share (misalnya menggunakan package 'share_plus')
              debugPrint('Tombol Share ditekan untuk: ${article.title}');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Fitur Share belum diimplementasikan.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
            bottom: 20.0), // Padding bawah agar tombol tidak terlalu mepet
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- CARD UNTUK GAMBAR DAN INFO UTAMA (JUDUL, PENULIS, TANGGAL) ---
            Card(
              margin: const EdgeInsets.all(12.0), // Margin untuk card
              elevation: 3.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              clipBehavior:
                  Clip.antiAlias, // Untuk memotong gambar sesuai bentuk card
              color: theme.cardColor, // Warna card dari tema
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Utama Artikel
                  if (article.urlToImage != null &&
                      article.urlToImage!.isNotEmpty)
                    Hero(
                      tag: article.url ?? article.title, // Tag Hero harus unik
                      child: Image.network(
                        article.urlToImage!,
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height *
                            0.30, // Tinggi gambar disesuaikan
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: MediaQuery.of(context).size.height * 0.30,
                            color: theme.highlightColor,
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.primary),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: MediaQuery.of(context).size.height * 0.30,
                            color: theme.highlightColor,
                            child: Icon(Icons.broken_image_outlined,
                                color: theme.hintColor, size: 60),
                          );
                        },
                      ),
                    )
                  else // Placeholder jika tidak ada gambar
                    Container(
                      height: MediaQuery.of(context).size.height *
                          0.25, // Sedikit lebih pendek jika tidak ada gambar
                      width: double.infinity,
                      color: theme.highlightColor,
                      child: Icon(Icons.image_not_supported_outlined,
                          color: theme.hintColor, size: 60),
                    ),

                  // Konten Teks di dalam Card, di bawah gambar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          article.title,
                          style: textTheme.headlineSmall?.copyWith(
                              // Gunakan gaya teks dari tema
                              fontWeight: FontWeight.bold,
                              color: textTheme
                                  .displayLarge?.color // Warna teks dari tema
                              ),
                        ),
                        helper.vsMedium,
                        Row(
                          children: [
                            Icon(Icons.person_outline_rounded,
                                size: 16, color: theme.hintColor),
                            helper.hsTiny,
                            Expanded(
                              child: Text(
                                authorDisplay,
                                style: textTheme.bodySmall?.copyWith(
                                    color: theme.hintColor,
                                    fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        helper.vsSuperTiny,
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 14, color: theme.hintColor),
                            helper.hsTiny,
                            Text(
                              formattedDate,
                              style: textTheme.bodySmall
                                  ?.copyWith(color: theme.hintColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ----------------------------------------------------------------

            // Konten Artikel (di luar Card)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.content != null && article.content!.isNotEmpty)
                    Text(
                      article.content!.split(' [+')[0],
                      style: textTheme.bodyLarge?.copyWith(
                          height: 1.6, color: textTheme.bodyLarge?.color),
                      textAlign: TextAlign.justify,
                    )
                  else if (article.description != null &&
                      article.description!.isNotEmpty)
                    Text(
                      article.description!,
                      style: textTheme.bodyLarge?.copyWith(
                          height: 1.6, color: textTheme.bodyLarge?.color),
                      textAlign: TextAlign.justify,
                    )
                  else
                    Padding(
                      // Beri padding jika konten tidak tersedia
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: Text(
                          "Konten detail tidak tersedia.",
                          style: textTheme.bodyMedium
                              ?.copyWith(color: theme.hintColor),
                        ),
                      ),
                    ),
                  helper.vsLarge,
                  if (article.url != null && article.url!.isNotEmpty)
                    Center(
                      child: ElevatedButton.icon(
                        icon:
                            const Icon(Icons.open_in_browser_rounded, size: 20),
                        label: Text(
                          'Baca Selengkapnya di ${article.sourceName ?? "Sumber"}',
                        ),
                        onPressed: () {
                          _launchURL(context, article.url);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            )),
                      ),
                    ),
                  helper.vsLarge,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
