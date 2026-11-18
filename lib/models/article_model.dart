class ArticleModel {
  final int id;
  final String title;
  final String url;
  final String imageUrl;
  final String newsSite;
  final String summary;
  final String publishedAt;
  final String author;
  final String type; // 'articles', 'blogs', or 'reports'

  ArticleModel({
    required this.id,
    required this.title,
    required this.url,
    required this.imageUrl,
    required this.newsSite,
    required this.summary,
    required this.publishedAt,
    required this.author,
    required this.type,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json, {String type = 'articles'}) {
    // Ekstraksi nama author jika ada di list authors, jika tidak fallback ke news_site
    String authorName = '';
    if (json['authors'] != null && (json['authors'] as List).isNotEmpty) {
      final firstAuthor = json['authors'][0];
      if (firstAuthor is Map && firstAuthor['name'] != null) {
        authorName = firstAuthor['name'].toString();
      }
    }
    final site = json['news_site']?.toString() ?? '';
    if (authorName.isEmpty) {
      authorName = site.isNotEmpty ? site : 'Unknown';
    }

    return ArticleModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      newsSite: site.isNotEmpty ? site : authorName,
      summary: json['summary']?.toString() ?? '',
      publishedAt: json['published_at']?.toString() ?? '',
      author: authorName,
      type: json['type']?.toString() ?? type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'image_url': imageUrl,
      'news_site': newsSite,
      'summary': summary,
      'published_at': publishedAt,
      'author': author,
      'type': type,
    };
  }
}
