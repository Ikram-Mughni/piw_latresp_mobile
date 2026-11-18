// =========================================================================
// [RESPONSI CHECKPOINT 2: SERVICE & ENDPOINTS API]
// File ini mengatur pemanggilan HTTP Request ke server API.
// JIKA STUDI KASUS BERUBAH:
// 1. Ganti baseUrl dengan URL API baru pada soal.
// 2. Periksa format root response API:
//    - Apakah dibungkus Map: data['results'] / data['products'] / data['data']?
//    - Ataukah langsung berupa List: data as List?
// 3. Sesuaikan method getArticles() dan getDetail() di bawah ini.
// =========================================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

class ApiService {
  // [RESPONSI]: Ganti baseUrl sesuai domain API yang diberikan di soal
  static const String baseUrl = 'https://api.spaceflightnewsapi.net/v4';

  // [RESPONSI]: Mengambil list data dari API
  static Future<List<ArticleModel>> getArticles(String endpoint) async {
    // Sesuaikan format URL jika API baru tidak memerlukan garis miring di akhir
    final url = Uri.parse('$baseUrl/$endpoint/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // [RESPONSI TIP]:
      // Kasus A: Jika data API dibungkus key tertentu, contoh: data['results'] atau data['products']
      List results = [];
      if (data is Map<String, dynamic>) {
        results = data['results'] ?? data['products'] ?? data['data'] ?? [];
      } else if (data is List) {
        // Kasus B: Jika response API langsung berupa List array murni [...]
        results = data;
      }

      return results
          .map((item) => ArticleModel.fromJson(item, type: endpoint))
          .toList();
    } else {
      throw Exception('Gagal memuat data dari API (Status: ${response.statusCode})');
    }
  }

  // [RESPONSI]: Mengambil detail satu item berdasarkan id
  static Future<ArticleModel> getDetail(String endpoint, int id) async {
    final url = Uri.parse('$baseUrl/$endpoint/$id/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ArticleModel.fromJson(data, type: endpoint);
    } else {
      throw Exception('Gagal memuat detail data (id: $id)');
    }
  }
}
