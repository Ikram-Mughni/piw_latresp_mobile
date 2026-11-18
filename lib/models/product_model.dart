// =========================================================================
// [SIMULASI MODUL 5: MODEL DATA PRODUK]
// SEBELUMNYA: ArticleModel (berisi title, news_site, summary, published_at, dsb)
// SEKARANG: ProductModel (menyesuaikan atribut API DummyJSON: price, rating, stock, brand, dsb)
//
// CARA ADAPTASI:
// 1. Tentukan atribut yang dimiliki API baru.
// 2. Pada fromJson(), petakan key JSON dengan fallback (??) agar tidak null pointer.
// 3. Pada toJson(), simpan data yang ingin dicatat di Hive Favorite.
// =========================================================================

class ProductModel {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double rating;
  final int stock;
  final String brand;
  final String imageUrl;
  final String webUrl; // URL web untuk url_launcher

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.imageUrl,
    required this.webUrl,
  });

  // Factory constructor mengonversi JSON API DummyJSON ke objek Dart
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Menangani gambar: DummyJSON menyediakan array 'images' dan string 'thumbnail'
    String selectedImage = '';
    if (json['thumbnail'] != null && json['thumbnail'].toString().isNotEmpty) {
      selectedImage = json['thumbnail'].toString();
    } else if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      selectedImage = json['images'][0].toString();
    }

    return ProductModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? 'Tanpa Nama Produk',
      description: json['description']?.toString() ?? 'Tidak ada deskripsi tersedia.',
      category: json['category']?.toString() ?? 'Umum',
      // Mengonversi angka ke double secara aman
      price: json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      stock: json['stock'] is int ? json['stock'] : int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      brand: json['brand']?.toString() ?? 'No Brand',
      imageUrl: selectedImage,
      // Jika API tidak menyediakan URL spesifik, buat URL dummy atau link ke dummyjson
      webUrl: 'https://dummyjson.com/products/${json['id']}',
    );
  }

  // Digunakan untuk penyimpanan lokal di Hive (Fitur Favorite)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'rating': rating,
      'stock': stock,
      'brand': brand,
      'imageUrl': imageUrl,
      'webUrl': webUrl,
    };
  }
}
