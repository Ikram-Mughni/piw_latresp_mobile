// =========================================================================
// [SIMULASI MODUL 5: HALAMAN DETAIL PRODUK]
// SEBELUMNYA: Menampilkan artikel luar angkasa (author, publish date, summary).
// SEKARANG: Menampilkan spesifikasi produk (brand, harga, rating, stok, kategori, deskripsi).
//
// PERUBAHAN YANG DILAKUKAN:
// 1. Menerima parameter ProductModel product.
// 2. Menampilkan harga ($ / Rp), rating bintang, dan jumlah stok.
// 3. Tombol Favorite tetap menggunakan Hive database (Modul 6).
// 4. Tombol Launch URL membuka halaman web produk.
// =========================================================================

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product_model.dart';

class DetailScreen extends StatefulWidget {
  final ProductModel product;

  const DetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Box _favoriteBox;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _favoriteBox = Hive.box('favorites');
    _checkFavoriteStatus();
  }

  // Cek apakah produk ini sudah ada di dalam Hive favorite box (Modul 6)
  void _checkFavoriteStatus() {
    setState(() {
      _isFavorite = _favoriteBox.containsKey(widget.product.id.toString());
    });
  }

  // Toggle status favorite (tambah / hapus dari Hive)
  Future<void> _toggleFavorite() async {
    final key = widget.product.id.toString();
    if (_isFavorite) {
      await _favoriteBox.delete(key);
      setState(() => _isFavorite = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dihapus dari favorite'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      // Simpan data produk dalam bentuk Map JSON ke Hive
      await _favoriteBox.put(key, widget.product.toJson());
      setState(() => _isFavorite = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ditambahkan ke favorite'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  // Membuka situs web produk via url_launcher
  Future<void> _openProductSite() async {
    final Uri uri = Uri.parse(widget.product.webUrl);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuka URL produk'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detail Produk',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4C6EF5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Tombol Aksi Tambah / Hapus Favorite (Modul 6)
          IconButton(
            tooltip: _isFavorite ? 'Hapus dari Favorite' : 'Tambah ke Favorite',
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Banner Produk dengan Exception Handling (errorBuilder)
                SizedBox(
                  width: double.infinity,
                  height: 250,
                  child: Image.network(
                    widget.product.imageUrl,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // [PERUBAHAN]: Judul Produk
                      Text(
                        widget.product.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // [PERUBAHAN]: Harga dan Rating Produk
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${widget.product.price}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4C6EF5),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amber.shade400),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.product.rating}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // [PERUBAHAN]: Brand, Kategori & Stok Produk
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.branding_watermark_outlined, size: 16),
                            label: Text('Brand: ${widget.product.brand}'),
                            backgroundColor: const Color(0xFFF1F3F9),
                          ),
                          Chip(
                            avatar: const Icon(Icons.category_outlined, size: 16),
                            label: Text('Kategori: ${widget.product.category}'),
                            backgroundColor: const Color(0xFFF1F3F9),
                          ),
                          Chip(
                            avatar: const Icon(Icons.inventory_2_outlined, size: 16),
                            label: Text('Stok: ${widget.product.stock} pcs'),
                            backgroundColor: const Color(0xFFF1F3F9),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),

                      // Deskripsi Produk (Modul 5)
                      const Text(
                        'Deskripsi Produk:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.product.description,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tombol Buka Situs Resmi (Launch URL via url_launcher)
          Positioned(
            bottom: 20,
            right: 20,
            child: Tooltip(
              message: 'Buka Web Produk',
              child: FloatingActionButton.extended(
                backgroundColor: const Color(0xFFECEEFE),
                foregroundColor: const Color(0xFF4C6EF5),
                elevation: 3,
                icon: const Icon(Icons.open_in_new, size: 20),
                label: const Text(
                  'Buka Web',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: _openProductSite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
