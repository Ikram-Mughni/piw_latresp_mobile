// =========================================================================
// [RESPONSI CHECKPOINT 3: HALAMAN UTAMA / MENU PILIHAN]
// File ini menampilkan dashboard menu utama dan tombol Logout.
// JIKA STUDI KASUS BERUBAH:
// 1. Sesuaikan nama-nama menu (judul, deskripsi, icon) pada _buildMenuCard.
// 2. Sesuaikan endpoint yang dikirimkan ke ListScreen (misal: 'characters', 'episodes', 'products', dsb).
// 3. Tombol Logout sudah baku (SharedPreferences clear session).
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
        // [RESPONSI]: Menampilkan username login dinamis sesuai ketentuan Modul 4
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
                    // [RESPONSI]: Menu 1 - Sesuaikan title, deskripsi, dan endpoint API
                    _buildMenuCard(
                      context: context,
                      icon: Icons.newspaper_outlined,
                      title: 'News',
                      subtitle:
                          'Get an overview of the latest SpaceFlight news, from various sources! Easily link your users to the right websites.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ListScreen(
                              menuTitle: 'News',
                              endpoint: 'articles', // <-- Ganti endpoint di sini
                            ),
                          ),
                        );
                      },
                    ),

                    // [RESPONSI]: Menu 2 - Sesuaikan title, deskripsi, dan endpoint API
                    _buildMenuCard(
                      context: context,
                      icon: Icons.menu_book_outlined,
                      title: 'Blog',
                      subtitle:
                          'Blogs often provide a more detailed overview of launches and missions. A must-have for the serious spaceflight enthusiast.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ListScreen(
                              menuTitle: 'Blog',
                              endpoint: 'blogs', // <-- Ganti endpoint di sini
                            ),
                          ),
                        );
                      },
                    ),

                    // [RESPONSI]: Menu 3 - Sesuaikan title, deskripsi, dan endpoint API
                    _buildMenuCard(
                      context: context,
                      icon: Icons.analytics_outlined,
                      title: 'Reports',
                      subtitle:
                          'Space stations and other missions often publish their data. With SNAPI, you can include it in your app.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ListScreen(
                              menuTitle: 'Reports',
                              endpoint: 'reports', // <-- Ganti endpoint di sini
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // [RESPONSI]: Tombol Logout di bawah pilihan menu (Wajib ada)
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
