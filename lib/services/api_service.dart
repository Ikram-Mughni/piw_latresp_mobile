// =========================================================================
// [SIMULASI MODUL 5: SERVICE API DUMMYJSON]
// SEBELUMNYA: Base URL Spaceflight API ('https://api.spaceflightnewsapi.net/v4')
//             Root pembungkus: data['results']
//
// SEKARANG: Base URL DummyJSON ('https://dummyjson.com')
//           Root pembungkus: data['products']
//
// PERUBAHAN YANG DILAKUKAN:
// 1. Ganti baseUrl menjadi 'https://dummyjson.com'.
// 2. Pada getProducts(): parsing response JSON menggunakan key data['products'].
// 3. Mengubah return type menjadi List<ProductModel>.
// =========================================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  // [PERUBAHAN 1]: Ganti URL dasar API ke DummyJSON sesuai Modul 5
  static const String baseUrl = 'https://dummyjson.com';

  // [PERUBAHAN 2]: Mengambil daftar produk berdasarkan endpoint yang dipilih
  static Future<List<ProductModel>> getProducts(String endpoint) async {
    // Membentuk URL lengkap, misal: https://dummyjson.com/products atau https://dummyjson.com/products/category/beauty
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // [PERUBAHAN 3]: Pada DummyJSON, data produk dibungkus key "products"
      List results = [];
      if (data is Map<String, dynamic> && data.containsKey('products')) {
        results = data['products'] as List;
      } else if (data is List) {
        results = data;
      }

      // Konversi list json menjadi list ProductModel
      return results
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Gagal memuat produk dari API (Status: ${response.statusCode})');
    }
  }

  // [PERUBAHAN 4]: Mengambil data detail satu produk berdasarkan id
  static Future<ProductModel> getSingleProduct(int id) async {
    final url = Uri.parse('$baseUrl/products/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ProductModel.fromJson(data as Map<String, dynamic>);
    } else {
      throw Exception('Gagal memuat detail produk (id: $id)');
    }
  }
}
