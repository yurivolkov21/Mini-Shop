import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth/auth_api.dart';
import '../auth/token_store.dart';

class ProductRepo {
  Future<Map<String, String>> _headers() async {
    final jwt = await TokenStore.read();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwt',
    };
  }

  Map<String, dynamic> _body({
    required String name,
    required num price,
    required String category,
    String? description,
    String? imageUrl,
  }) =>
      {
        'name': name,
        'price': price,
        'category': category,
        if (description != null && description.isNotEmpty)
          'description': description,
        'imageUrl': ?imageUrl,
      };

  /// Tạo sản phẩm mới (cần Bearer app JWT). imageUrl lấy từ Cloudinary.
  Future<void> createProduct({
    required String name,
    required num price,
    required String category,
    String? description,
    String? imageUrl,
  }) async {
    final res = await http
        .post(
          Uri.parse('${AuthApi.baseUrl}/products'),
          headers: await _headers(),
          body: jsonEncode(_body(
            name: name,
            price: price,
            category: category,
            description: description,
            imageUrl: imageUrl,
          )),
        )
        .timeout(const Duration(seconds: 60)); // Render free cold start ~30-50s

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Tạo sản phẩm thất bại (server ${res.statusCode})');
    }
  }

  /// Cập nhật sản phẩm theo id.
  Future<void> updateProduct({
    required String id,
    required String name,
    required num price,
    required String category,
    String? description,
    String? imageUrl,
  }) async {
    final res = await http
        .put(
          Uri.parse('${AuthApi.baseUrl}/products/$id'),
          headers: await _headers(),
          body: jsonEncode(_body(
            name: name,
            price: price,
            category: category,
            description: description,
            imageUrl: imageUrl,
          )),
        )
        .timeout(const Duration(seconds: 60));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Cập nhật thất bại (server ${res.statusCode})');
    }
  }

  /// Xoá sản phẩm theo id.
  Future<void> deleteProduct(String id) async {
    final res = await http
        .delete(
          Uri.parse('${AuthApi.baseUrl}/products/$id'),
          headers: await _headers(),
        )
        .timeout(const Duration(seconds: 60));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Xoá thất bại (server ${res.statusCode})');
    }
  }

  /// Lấy toàn bộ sản phẩm (để join với giỏ hàng).
  Future<List<Map<String, dynamic>>> listProducts() async {
    final jwt = await TokenStore.read();
    final res = await http.get(
      Uri.parse('${AuthApi.baseUrl}/products'),
      headers: {'Authorization': 'Bearer $jwt'},
    ).timeout(const Duration(seconds: 60));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Lỗi tải sản phẩm (server ${res.statusCode})');
    }
    final list = jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }
}
