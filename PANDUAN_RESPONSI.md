# 📘 PANDUAN LENGKAP MENGHADAPI RESPONSI PRAKTIKUM MOBILE (TPM)
*Template Universal Arsitektur Responsi UPN "Veteran" Yogyakarta*

---

## 🎯 1. Pola Umum Soal Responsi

Pada praktikum TPM, format ujian responsi memiliki struktur fitur yang **90% selalu sama**:
1. **Fitur Login & Register**: Sesi disimpan di `SharedPreferences` (auto-login saat restart aplikasi, `SnackBar` merah jika salah).
2. **Halaman Utama (Dashboard)**: Menampilkan salam `Hai, $username!`, menu pilihan kartu, dan tombol **Log Out** merah di bawah.
3. **Halaman List**: Mengambil data dinamis dari REST API via `http`, menampilkan judul, thumbnail (`errorBuilder`), dan *info subtitle*.
4. **Fitur Filter**: Baris horizontal `FilterChip` untuk menyaring data berdasarkan atribut tertentu (*author*, *category*, *clan*, *brand*, atau *status*).
5. **Fitur Detail**: Menampilkan banner gambar besar, judul, metadata, tanggal/harga, deskripsi lengkap, tombol **Launch URL**, dan tombol aksi **Favorite** (ikon hati).
6. **Fitur Favorite**: Menggunakan **Hive Database** dengan `ValueListenableBuilder` agar data reaktif dan tersinkronisasi otomatis di semua layar.

> **Yang Berubah saat Responsi HANYA:**
> - Domain studi kasus (misal: SpaceFlight, Anime, Produk E-Commerce, Film, Resep Makanan, atau Game).
> - Alamat URL API (`baseUrl` & *endpoints*).
> - Struktur key JSON dari API.

---

## 🗺️ 2. Peta File & Checklist Cepat

Semua titik perubahan di dalam kode sudah ditandai dengan komentar khusus:  
Tekan **`Ctrl + Shift + F`** di VS Code, lalu ketik:
```text
[RESPONSI]
```
Anda akan langsung melihat semua baris yang perlu disesuaikan!

| No | Nama Berkas | Lokasi | Yang Perlu Diubah |
| :---: | :--- | :--- | :--- |
| **1** | [article_model.dart](file:///e:/SEMESTER%205/Praktikum%20Mobile/Latihan%20Responsi%20Prim/flutter_application_1/lib/models/article_model.dart) | `lib/models/` | Atribut class, `fromJson()`, dan `toJson()`. |
| **2** | [api_service.dart](file:///e:/SEMESTER%205/Praktikum%20Mobile/Latihan%20Responsi%20Prim/flutter_application_1/lib/services/api_service.dart) | `lib/services/` | `baseUrl` dan nama key pembungkus JSON (`results`, `products`, `data`, dsb). |
| **3** | [home_screen.dart](file:///e:/SEMESTER%205/Praktikum%20Mobile/Latihan%20Responsi%20Prim/flutter_application_1/lib/screens/home_screen.dart) | `lib/screens/` | Judul menu, deskripsi menu, dan string *endpoint* yang dikirim ke `ListScreen`. |
| **4** | [list_screen.dart](file:///e:/SEMESTER%205/Praktikum%20Mobile/Latihan%20Responsi%20Prim/flutter_application_1/lib/screens/list_screen.dart) | `lib/screens/` | Atribut yang disaring oleh `FilterChip` dan teks di Card list. |
| **5** | [detail_screen.dart](file:///e:/SEMESTER%205/Praktikum%20Mobile/Latihan%20Responsi%20Prim/flutter_application_1/lib/screens/detail_screen.dart) | `lib/screens/` | Informasi atribut yang ditampilkan di halaman detil. |
| **-** | `login_screen.dart` | `lib/screens/` | **TIDAK PERLU DIUBAH** (Sudah otomatis bekerja). |
| **-** | `register_screen.dart` | `lib/screens/` | **TIDAK PERLU DIUBAH** (Sudah otomatis bekerja). |
| **-** | `favorite_screen.dart` | `lib/screens/` | **TIDAK PERLU DIUBAH** (Sudah otomatis reaktif via Hive). |
| **-** | `main.dart` | `lib/` | **TIDAK PERLU DIUBAH** (Sudah ada inisialisasi Hive & SharedPreferences). |

---

## 🛠️ 3. Langkah Demi Langkah Mengganti Studi Kasus

### Langkah 1: Cek Struktur JSON API Baru
Buka URL API di browser atau Postman. Perhatikan 2 hal penting:
1. **Apakah root JSON berupa Map atau List?**
   - **Bentuk Map dengan key pembungkus** (paling sering):
     ```json
     {
       "results": [ {"id": 1, "name": "..."} ]
     }
     ```
     *(atau `"products": [...]`, `"characters": [...]`, `"data": [...]`)*
   - **Bentuk List langsung**:
     ```json
     [
       {"id": 1, "name": "..."}
     ]
     ```
2. **Nama-nama key penting**:
   - ID: `id` atau `_id`
   - Judul/Nama: `title`, `name`, `strMeal`
   - Gambar: `image_url`, `thumbnail`, `images` (berupa array), atau `avatar`
   - Kategori/Filter: `category`, `clan`, `status`, `news_site`, `brand`
   - Deskripsi: `summary`, `description`, `bio`, `strInstructions`
   - Link Web: `url`, `link`, `source`

---

### Langkah 2: Sesuaikan Model Data (`lib/models/article_model.dart`)

Ubah atribut dan pemetaan `fromJson`:

```dart
class ArticleModel {
  final int id;
  final String title;
  final String url;
  final String imageUrl;
  final String category; // contoh: diganti category / clan / brand
  final String summary;
  final String extraInfo; // contoh: harga, tanggal, atau rating

  ArticleModel({
    required this.id,
    required this.title,
    required this.url,
    required this.imageUrl,
    required this.category,
    required this.summary,
    required this.extraInfo,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      // Selalu gunakan fallback '??' agar tidak pernah error null
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? json['name'] ?? 'Tanpa Nama',
      url: json['url'] ?? '',
      // Trik gambar: jika berupa array list, ambil index ke-0
      imageUrl: (json['images'] is List && (json['images'] as List).isNotEmpty)
          ? json['images'][0].toString()
          : (json['image_url'] ?? json['thumbnail'] ?? json['image'] ?? ''),
      category: json['category'] ?? json['clan'] ?? json['news_site'] ?? 'Umum',
      summary: json['summary'] ?? json['description'] ?? '',
      extraInfo: json['price']?.toString() ?? json['published_at'] ?? '',
    );
  }

  // Wajib ada untuk penyimpanan Hive Favorite
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'url': url,
    'image_url': imageUrl,
    'category': category,
    'summary': summary,
    'extraInfo': extraInfo,
  };
}
```

---

### Langkah 3: Sesuaikan Service API (`lib/services/api_service.dart`)

Ganti `baseUrl` dan pastikan key pembungkus sesuai dengan JSON API baru:

```dart
class ApiService {
  // 1. Ganti base URL sesuai soal
  static const String baseUrl = 'https://api.contoh.com/v1';

  static Future<List<ArticleModel>> getArticles(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List results = [];
      if (data is Map<String, dynamic>) {
        // Ambil array dari key yang sesuai:
        results = data['results'] ?? data['products'] ?? data['characters'] ?? data['data'] ?? [];
      } else if (data is List) {
        // Jika response API langsung berupa List [...]
        results = data;
      }

      return results.map((item) => ArticleModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat data API (${response.statusCode})');
    }
  }
}
```

---

### Langkah 4: Sesuaikan Menu Halaman Utama (`lib/screens/home_screen.dart`)

Di dalam `home_screen.dart`, perbarui daftar kartu menu:

```dart
_buildMenuCard(
  context: context,
  icon: Icons.movie_outlined, // Pilih icon yang relevan
  title: 'Anime Populer',
  subtitle: 'Daftar anime terbaru dan terpopuler saat ini.',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ListScreen(
          menuTitle: 'Anime Populer',
          endpoint: 'characters', // <-- Parameter endpoint API baru
        ),
      ),
    );
  },
),
```

---

### Langkah 5: Sesuaikan List & Filter (`lib/screens/list_screen.dart`)

1. **Bagian Filter Chip**:
   Tentukan atribut apa yang ingin disaring:
   ```dart
   final Set<String> filterSet = {};
   for (final item in data) {
     if (item.category.trim().isNotEmpty) {
       filterSet.add(item.category.trim()); // Atribut yang ingin difilter
     }
   }
   ```
2. **Logika Filtering**:
   ```dart
   final displayedArticles = _selectedFilter == 'All'
       ? _allArticles
       : _allArticles.where((item) => item.category == _selectedFilter).toList();
   ```
3. **Card Item**:
   Tampilkan atribut yang sesuai pada `title` dan `subtitle`.

---

### Langkah 6: Sesuaikan Halaman Detail (`lib/screens/detail_screen.dart`)

Tampilkan data yang diminta soal:
- Gambar banner (sudah ada `errorBuilder` jika URL bermasalah).
- Judul (`widget.item.title`).
- Kategori / Author / Clan (`widget.item.category`).
- Informasi Tambahan (Harga / Tanggal Publish / Rating).
- Deskripsi (`widget.item.summary`).
- **Tombol Launch URL & Favorite**: Sudah otomatis berfungsi menyimpan ke Hive box tanpa perlu diubah!

---

## 💡 4. Contoh Kasus Nyata & Cara Cepat Menyesuaikannya

### Contoh Kasus A: API DummyJSON (`https://dummyjson.com/products`)
- **Base URL**: `https://dummyjson.com`
- **Endpoint**: `products`
- **Root JSON**: Dibungkus key `"products": [ ... ]`
- **Mapping Model**:
  - `title`: `json['title']`
  - `imageUrl`: `json['thumbnail']`
  - `category`: `json['category']` (bisa jadi Filter Chip: *beauty, fragrances, furniture*)
  - `extraInfo`: `'Rp ${json['price']}'`
  - `summary`: `json['description']`

### Contoh Kasus B: API Dattebayo Naruto (`https://dattebayo-api.onrender.com/characters`)
- **Base URL**: `https://dattebayo-api.onrender.com`
- **Endpoint**: `characters`
- **Root JSON**: Dibungkus key `"characters": [ ... ]`
- **Mapping Model**:
  - `title`: `json['name']`
  - `imageUrl`: `(json['images'] as List)[0]`
  - `category`: `json['personal']?['clan'] ?? 'No Clan'` (Filter Chip berdasarkan Clan!)
  - `extraInfo`: `json['personal']?['birthdate'] ?? '-'`
  - `summary`: `(json['jutsu'] as List).take(3).join(', ')`

---

## ✅ 5. Checklist Pengumpulan Ujian

1. [ ] Jalankan `flutter analyze` via terminal untuk memastikan **0 Error & 0 Warning**.
2. [ ] Pastikan fitur Login gagal mengeluarkan `SnackBar` merah.
3. [ ] Pastikan fitur Register dapat menambah user baru dan bisa dipakai login.
4. [ ] Pastikan fitur auto-login jalan saat aplikasi di-*hot restart*.
5. [ ] Pastikan tombol Logout merah di Halaman Utama berfungsi menghapus sesi.
6. [ ] Pastikan gambar pada List dan Detail tidak crash saat URL kosong/rusak (`errorBuilder`).
7. [ ] Pastikan tombol Favorite (ikon hati) di Detail menambah item ke halaman Favorite, dan bisa dihapus secara langsung.
8. [ ] Buat repositori GitHub dengan format penamaan resmi:
   ```text
   [NIM]_LatResMobile_SI-E
   ```
9. [ ] Commit & Push ke GitHub:
   ```bash
   git init
   git add .
   git commit -m "feat: complete mobile responsi project"
   git branch -M main
   git remote add origin https://github.com/<username>/<NIM>_LatResMobile_SI-E.git
   git push -u origin main
   ```
