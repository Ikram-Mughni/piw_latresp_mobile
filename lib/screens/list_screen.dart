// =========================================================================
// [RESPONSI CHECKPOINT 4: HALAMAN LIST & FITUR FILTER]
// File ini menampilkan daftar item dari API dan Filter Chip horizontal.
// JIKA STUDI KASUS BERUBAH:
// 1. Pada _fetchData(): tentukan atribut apa yang dijadikan filter (author, category, clan, brand).
// 2. Pada FilterChip: sesuaikan logika filter item[field] == selectedFilter.
// 3. Pada ListView item card: sesuaikan gambar thumbnail (errorBuilder), judul, dan subtitle info.
// =========================================================================

import 'package:flutter/material.dart';
import '../models/article_model.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';
import 'favorite_screen.dart';

class ListScreen extends StatefulWidget {
  final String menuTitle;
  final String endpoint;

  const ListScreen({
    super.key,
    required this.menuTitle,
    required this.endpoint,
  });

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<ArticleModel> _allArticles = [];
  List<String> _filters = [];
  String _selectedFilter = 'All';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Mengambil data dari API berdasarkan endpoint (Modul 5)
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ApiService.getArticles(widget.endpoint);

      // [RESPONSI]: Ekstraksi data unik untuk Filter Chip.
      // Bisa diganti e.category, e.brand, e.clan, dsb sesuai soal baru.
      final Set<String> filterSet = {};
      for (final item in data) {
        if (item.author.trim().isNotEmpty) {
          filterSet.add(item.author.trim());
        }
      }

      setState(() {
        _allArticles = data;
        _filters = ['All', ...filterSet];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // [RESPONSI]: Logika penyaringan data berdasarkan Chip yang aktif
    final displayedArticles = _selectedFilter == 'All'
        ? _allArticles
        : _allArticles.where((item) => item.author == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: Text(
          widget.menuTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF4C6EF5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Tombol menuju halaman Favourite (Modul 4 & Modul 6)
          IconButton(
            tooltip: 'Halaman Favourite',
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoriteScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // [RESPONSI]: Baris Horizontal Filter Chip
          if (!_isLoading && _filters.isNotEmpty)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: _filters.map((filter) {
                    final bool isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        showCheckmark: isSelected,
                        checkmarkColor: const Color(0xFF4C6EF5),
                        selected: isSelected,
                        label: Text(filter),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? const Color(0xFF4C6EF5)
                              : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                        backgroundColor: const Color(0xFFF1F3F9),
                        selectedColor: const Color(0xFFE4E9FE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF4C6EF5)
                                : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          const Divider(height: 1, thickness: 1),

          // [RESPONSI]: Tampilan List Data Dinamis (Modul 2 & 5)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Terjadi kesalahan:\n$_errorMessage',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4C6EF5),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _fetchData,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    : displayedArticles.isEmpty
                        ? Center(
                            child: Text(
                              'Tidak ada data untuk filter "$_selectedFilter"',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            itemCount: displayedArticles.length,
                            itemBuilder: (context, index) {
                              final item = displayedArticles[index];
                              return Card(
                                elevation: 1.5,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                color: const Color(0xFFFBFBFE),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailScreen(
                                          item: item,
                                          endpoint: widget.endpoint,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        // [RESPONSI]: Leading Thumbnail & Exception Handling Gambar
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            item.imageUrl,
                                            width: 85,
                                            height: 65,
                                            fit: BoxFit.cover,
                                            loadingBuilder:
                                                (context, child, progress) {
                                              if (progress == null) {
                                                return child;
                                              }
                                              return Container(
                                                width: 85,
                                                height: 65,
                                                color: Colors.grey.shade100,
                                                child: const Center(
                                                  child: SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              // Tampilan fallback jika URL gambar gagal/rusak
                                              return Container(
                                                width: 85,
                                                height: 65,
                                                color: Colors.grey.shade200,
                                                child: const Icon(
                                                  Icons
                                                      .image_not_supported_outlined,
                                                  color: Colors.grey,
                                                  size: 28,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        // [RESPONSI]: Judul dan Informasi Tambahan
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                item.author,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
