// lib/data/models/article_model.dart
class Article {
  final String? sourceId;
  final String? sourceName;
  final String? author;
  final String title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final DateTime? publishedAt;
  final String? content;
  final String? slug; // Tambahan field untuk slug

  Article({
    this.sourceId,
    this.sourceName,
    this.author,
    required this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.slug,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      sourceId:
          json['id'] as String?, // Gunakan 'id' dari artikel sebagai sourceId
      sourceName:
          json['author_name'] as String? ??
          'Sumber tidak diketahui', // Langsung ambil dari 'author_name'
      author:
          json['author_name'] as String?, // Langsung ambil dari 'author_name'
      title: json['title'] as String? ?? 'Tanpa Judul',
      description: json['summary'] as String? ?? json['content'] as String?,
      url: json['slug'] != null ? '/api/news/${json['slug']}' : null,
      urlToImage:
          json['featured_image_url']
              as String?, // Sesuaikan dengan key 'featured_image_url'
      publishedAt:
          json['published_at'] !=
              null // Prioritaskan 'published_at'
          ? DateTime.tryParse(json['published_at'] as String)
          : null,
      content: json['content'] as String?,
      slug: json['slug'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': {'id': sourceId, 'name': sourceName},
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt?.toIso8601String(),
      'content': content,
      'slug': slug,
    };
  }
}
