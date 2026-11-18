// =========================================================================
// [SIMULASI MODUL 5: HALAMAN UTAMA PRODUK]
// SEBELUMNYA: 3 Menu Berita Luar Angkasa (News, Blog, Reports)
// SEKARANG: 3 Menu Katalog E-Commerce DummyJSON (All Products, Beauty, Fragrances)
//
// PERUBAHAN YANG DILAKUKAN:
// 1. Ganti judul dan deskripsi menu menjadi kategori produk.
// 2. Ganti string parameter endpoint yang dikirimkan ke ListScreen.
// 3. Tombol Logout dan sapaan pengguna tetap utuh sesuai standar responsi.
// =========================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'list_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  // Fungsi logout menghapus sesi SharedPreferences (Modul 6 & Modul 4)
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogin', false);

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: const Color(0xFFFBFBFE),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFECEEFE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF4C6EF5),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.4,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        // Menampilkan username login secara dinamis
        title: Text(
          'Hai, $username!',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF4C6EF5),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    // [PERUBAHAN 1]: Menu Semua Produk
                    _buildMenuCard(
                      context: context,
                      icon: Icons.storefront_outlined,
                      title: 'All Products',
                      subtitle:
                          'Jelajahi seluruh katalog produk yang tersedia di DummyJSON Store.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ListScreen(
                              menuTitle: 'All Products',
                              endpoint: 'products', // Endpoint API Semua Produk
                            ),
                          ),
                        );
                      },
                    ),

                    // [PERUBAHAN 2]: Menu Kategori Beauty
                    _buildMenuCard(
                      context: context,
                      icon: Icons.face_retouching_natural_outlined,
                      title: 'Beauty & Skincare',
                      subtitle:
                          'Temukan berbagai produk kecantikan, kosmetik, dan perawatan kulit terbaik.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ListScreen(
                              menuTitle: 'Beauty Products',
                              endpoint: 'products/category/beauty', // Endpoint Kategori Beauty
                            ),
                          ),
                        );
                      },
                    ),

                    // [PERUBAHAN 3]: Menu Kategori Fragrances
                    _buildMenuCard(
                      context: context,
                      icon: Icons.air_outlined,
                      title: 'Fragrances',
                      subtitle:
                          'Koleksi parfum dan wewangian premium pilihan dari berbagai merek terkenal.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ListScreen(
                              menuTitle: 'Fragrances',
                              endpoint: 'products/category/fragrances', // Endpoint Kategori Parfum
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Tombol Logout berwarna merah di bagian bawah
              SizedBox(
                width: 140,
                height: 42,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    elevation: 1,
                  ),
                  onPressed: () => _logout(context),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
