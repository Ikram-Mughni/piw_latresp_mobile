// =========================================================================
// [RESPONSI CHECKPOINT 1: MODEL DATA]
// File ini merepresentasikan struktur data dari API.
// JIKA STUDI KASUS BERUBAH:
// 1. Sesuaikan nama atribut sesuai JSON dari API baru (misal: name, price, category, dsb).
// 2. Sesuaikan tipe datanya (int, String, double, List).
// 3. Pada fromJson(): petakan key JSON ke variabel (selalu gunakan fallback "??" untuk mencegah error null).
// 4. Pada toJson(): sesuaikan agar data yang disimpan ke Hive Favorite tetap lengkap.
// =========================================================================

class ArticleModel {
  // [RESPONSI]: Ganti/tambah atribut sesuai data baru
  final int id;
  final String title;
  final String url;
  final String imageUrl;
  final String newsSite;
  final String summary;
  final String publishedAt;
  final String author;
  final String type; // Kategori/endpoint menu (misal: 'articles', 'blogs', 'reports')

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

  // [RESPONSI]: Factory constructor untuk konversi JSON dari API ke objek Dart
  factory ArticleModel.fromJson(Map<String, dynamic> json, {String type = 'articles'}) {
    // Ekstraksi nama author / kategori jika bersarang (nested)
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
      // [RESPONSI]: Sesuaikan key JSON di bawah ini dengan nama key dari API baru
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Tanpa Judul',
      url: json['url']?.toString() ?? '',
      // Jika image berupa List string (seperti DummyJSON json['images'][0]), sesuaikan di sini
      imageUrl: json['image_url']?.toString() ??
          (json['images'] is List && (json['images'] as List).isNotEmpty
              ? json['images'][0].toString()
              : json['image']?.toString() ?? ''),
      newsSite: site.isNotEmpty ? site : authorName,
      summary: json['summary']?.toString() ?? json['description']?.toString() ?? '',
      publishedAt: json['published_at']?.toString() ?? '',
      author: authorName,
      type: json['type']?.toString() ?? type,
    );
  }

  // [RESPONSI]: toJson() digunakan untuk menyimpan data ke Hive Favorite
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
