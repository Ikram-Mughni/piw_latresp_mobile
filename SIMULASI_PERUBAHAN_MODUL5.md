# 🚀 LAPORAN & PANDUAN SIMULASI PENGUBAHAN STUDI KASUS (MODUL 5: DUMMYJSON PRODUCTS)

Dokumen ini menjelaskan **secara lengkap dan terperinci** proses simulasi pengubahan studi kasus dari **Spaceflight News API** (soal latihan) menjadi **DummyJSON Products API** (studi kasus Modul 5).

---

## 📊 1. Perbandingan Sebelum vs Sesudah Pengubahan

| Komponen | Template Awal (Spaceflight News) | Hasil Simulasi (Modul 5: DummyJSON) |
| :--- | :--- | :--- |
| **Domain Kasus** | Portal Berita Antariksa & Misi Roket | Katalog Produk E-Commerce / Toko Online |
| **Base URL API** | `https://api.spaceflightnewsapi.net/v4` | `https://dummyjson.com` |
| **Root JSON Response** | Dibungkus key `data['results']` | Dibungkus key `data['products']` |
| **Menu Halaman Utama** | 1. News (`articles`)<br>2. Blog (`blogs`)<br>3. Reports (`reports`) | 1. All Products (`products`)<br>2. Beauty & Skincare (`products/category/beauty`)<br>3. Fragrances (`products/category/fragrances`) |
| **Atribut Data Utama** | `title`, `author`, `published_at`, `summary`, `url` | `title`, `brand`, `category`, `price`, `rating`, `stock`, `description` |
| **Fitur Filter Chip** | Filter berdasarkan **Author / News Site** (*NASA*, *Spaceflight Now*, dsb) | Filter berdasarkan **Brand Produk** (*Essence*, *Glamour Beauty*, dsb) |
| **Tampilan Halaman List** | Thumbnail + Judul Berita + Author | Thumbnail + Judul Produk + Harga ($) + Brand |
| **Tampilan Halaman Detail**| Banner Gambar + Judul + Author + Tanggal + Ringkasan Berita | Banner Gambar + Judul + Harga + Bintang Rating + Badge Brand/Kategori/Stok + Deskripsi Produk |
| **Fitur Favorite (Hive)** | Menyimpan data artikel berita ke Box `'favorites'` | Menyimpan data produk ke Box `'favorites'` (reaktif `ValueListenableBuilder`) |
| **Fitur Autentikasi** | Login/Register SharedPreferences + Sesi + SnackBar merah | **Tetap Sama (100% Utuh)** |

---

## 🔄 2. Langkah-Langkah Pengubahan Kode (Step-by-Step)

### Langkah 1: Menyesuaikan Model Data
**Berkas**: `lib/models/product_model.dart`
- **Sebelumnya**: Atribut artikel seperti `publishedAt`, `newsSite`, `author`.
- **Pengubahan**: Dibuat class `ProductModel` dengan atribut:
  - `id` (int)
  - `title` (String)
  - `description` (String)
  - `category` (String)
  - `price` (double)
  - `rating` (double)
  - `stock` (int)
  - `brand` (String)
  - `imageUrl` (String diambil dari `thumbnail` atau `images[0]`)
  - `webUrl` (String untuk membuka link situs web via `url_launcher`)
- **Trik Penting**: Pada `fromJson()`, seluruh parsing nilai angka dikonversi dengan aman menggunakan `(json['price'] as num).toDouble()` dan diberi nilai *fallback* `??` agar tidak terjadi *crash null pointer*.

---

### Langkah 2: Menyesuaikan Service API
**Berkas**: `lib/services/api_service.dart`
- **Sebelumnya**:
  ```dart
  static const String baseUrl = 'https://api.spaceflightnewsapi.net/v4';
  // Mengambil data['results']
  ```
- **Pengubahan**:
  ```dart
  static const String baseUrl = 'https://dummyjson.com';
  // Mengambil data['products']
  ```
- Method `getProducts(String endpoint)` sekarang mendukung endpoint root `products` maupun endpoint kategori seperti `products/category/beauty`.

---

### Langkah 3: Menyesuaikan Menu di Halaman Utama
**Berkas**: `lib/screens/home_screen.dart`
- Mengganti 3 pilihan menu kartu:
  1. **All Products**: Mengirim parameter `endpoint: 'products'`.
  2. **Beauty & Skincare**: Mengirim parameter `endpoint: 'products/category/beauty'`.
  3. **Fragrances**: Mengirim parameter `endpoint: 'products/category/fragrances'`.
- Tombol **Log Out** merah dan sapaan `Hai, $username!` tetap dipertahankan karena merupakan standar penilaian responsi.

---

### Langkah 4: Menyesuaikan Halaman List & Fitur Filter
**Berkas**: `lib/screens/list_screen.dart`
- **Pengubahan Tipe Data**: Menggunakan `List<ProductModel>`.
- **Pengubahan Filter Chip**: 
  - Jika pada studi kasus awal menyaring berdasarkan `author`, pada API produk ini kita ekstrak kumpulan merek unik (`brandSet`) dari data yang masuk.
  - Pengguna dapat memilih *chip* merek (misal: *Essence*, *Glamour Beauty*, dsb) untuk memfilter produk yang tampil.
- **Card Item**: Menampilkan harga produk (`\$${product.price}`) dan merek (`product.brand`) di bawah judul produk.
- **Exception Handling**: Widget gambar tetap menggunakan `loadingBuilder` dan `errorBuilder` sehingga jika koneksi lambat atau gambar rusak, aplikasi menampilkan ikon *placeholder* tanpa *crash*.

---

### Langkah 5: Menyesuaikan Halaman Detail
**Berkas**: `lib/screens/detail_screen.dart`
- Menerima objek `ProductModel product`.
- Menampilkan:
  - Banner gambar produk berukuran besar.
  - Judul produk.
  - Harga dengan font tebal berwarna biru (`Color(0xFF4C6EF5)`).
  - Indikator rating bintang dengan latar belakang kuning lembut (`Colors.amber`).
  - Badge `Chip` informatif untuk **Brand**, **Kategori**, dan **Stok (pcs)**.
  - Deskripsi lengkap produk.
- **Tombol Launch URL**: Tombol mengambang (*Floating Action Button*) "Buka Web" mengarahkan pengguna ke halaman resmi produk DummyJSON via `url_launcher`.
- **Tombol Favorite**: Ikon hati di AppBar menyimpan data produk ke Hive Box `'favorites'` secara instan dengan feedback `SnackBar`.

---

### Langkah 6: Menyesuaikan Halaman Favorite
**Berkas**: `lib/screens/favorite_screen.dart`
- Memetakan isi Hive Box ke objek `ProductModel`.
- Menampilkan daftar produk favorit dengan harga dan merek.
- Karena menggunakan `ValueListenableBuilder<Box>`, penambahan atau penghapusan favorit (baik dari halaman detail maupun langsung dari halaman favorite) **otomatis langsung terupdate tanpa perlu *refresh* manual**.

---

## 🛡️ 3. Berkas yang TIDAK Perlu Diubah (Hemat Waktu!)

Saat menghadapi soal responsi baru nanti, berkas berikut **tidak perlu Anda ubah sama sekali**:
1. **`lib/screens/login_screen.dart`**: Sudah memiliki validasi input, SharedPreferences session, fungsi auto-login di `initState()`, dan pesan SnackBar merah jika akun tidak cocok.
2. **`lib/screens/register_screen.dart`**: Sudah memiliki form registrasi pengguna baru yang tersimpan ke SharedPreferences.
3. **`lib/main.dart`**: Sudah memuat inisialisasi `WidgetsFlutterBinding.ensureInitialized()`, `Hive.initFlutter()`, pembukaan box `'favorites'`, serta tema Material.

---

## 🔎 4. Hasil Verifikasi Kode

Proyek telah diuji dan dianalisis menggunakan perintah resmi:
```bash
flutter analyze
```
**Hasil Output:**
```text
Analyzing flutter_application_1...
No issues found! (ran in 5.5s)
```
Semua file bersih dari kesalahan sintaksis, peringatan linter, maupun *type mismatch*. Proyek siap dijalankan di emulator maupun device fisik dengan perintah `flutter run`.
