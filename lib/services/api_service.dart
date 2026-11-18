import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

class ApiService {
  static const String baseUrl = 'https://api.spaceflightnewsapi.net/v4';

  // Mengambil daftar data (articles, blogs, atau reports)
  static Future<List<ArticleModel>> getArticles(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint/'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'] ?? [];
      return results
          .map((item) => ArticleModel.fromJson(item, type: endpoint))
          .toList();
    } else {
      throw Exception('Gagal memuat data dari API ($endpoint)');
    }
  }

  // Mengambil detail satu data berdasarkan endpoint & id
  static Future<ArticleModel> getDetail(String endpoint, int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint/$id/'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ArticleModel.fromJson(data, type: endpoint);
    } else {
      throw Exception('Gagal memuat detail data (id: $id)');
    }
  }
}
