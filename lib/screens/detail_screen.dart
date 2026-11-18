import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article_model.dart';

class DetailScreen extends StatefulWidget {
  final ArticleModel item;
  final String endpoint;

  const DetailScreen({
    super.key,
    required this.item,
    required this.endpoint,
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

  // Cek apakah data ini sudah ada di dalam Hive favorite box
  void _checkFavoriteStatus() {
    setState(() {
      _isFavorite = _favoriteBox.containsKey(widget.item.id.toString());
    });
  }

  // Toggle status favorite (tambah / hapus dari Hive)
  Future<void> _toggleFavorite() async {
    final key = widget.item.id.toString();
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
      await _favoriteBox.put(key, widget.item.toJson());
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

  // Membuka situs resmi via url_launcher
  Future<void> _openOfficialSite() async {
    if (widget.item.url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL situs tidak tersedia'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Uri uri = Uri.parse(widget.item.url);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuka URL situs resmi'),
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

  // Format tanggal ISO 8601 menjadi format terbaca
  String _formatDate(String isoString) {
    if (isoString.isEmpty) return '-';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final year = dt.year;
      final month = dt.month.toString().padLeft(2, '0');
      final day = dt.day.toString().padLeft(2, '0');
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$year-$month-$day $hour:$minute';
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detail',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4C6EF5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
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
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Banner dengan Exception Handling
                SizedBox(
                  width: double.infinity,
                  height: 240,
                  child: Image.network(
                    widget.item.imageUrl,
                    width: double.infinity,
                    height: 240,
                    fit: BoxFit.cover,
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul Data
                      Text(
                        widget.item.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Author / News Site
                      Text(
                        widget.item.author,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Tanggal Publish
                      Text(
                        _formatDate(widget.item.publishedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      // Summary / Isi Ringkasan
                      Text(
                        widget.item.summary.isNotEmpty
                            ? widget.item.summary
                            : 'Tidak ada ringkasan yang tersedia.',
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
          // Tombol Buka Situs Resmi (Launch URL) di pojok kanan bawah
          Positioned(
            bottom: 20,
            right: 20,
            child: Tooltip(
              message: 'Buka Web',
              child: FloatingActionButton.extended(
                backgroundColor: const Color(0xFFECEEFE),
                foregroundColor: const Color(0xFF4C6EF5),
                elevation: 3,
                icon: const Icon(Icons.open_in_new, size: 20),
                label: const Text(
                  'Buka Web',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: _openOfficialSite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
