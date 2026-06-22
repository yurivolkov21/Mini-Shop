import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApi {
  // ⚠️ THAY bằng URL Render thật của bạn — KHÔNG có dấu / ở cuối.
  // Backend (Node + MongoDB) sẽ được dựng ở lab sau; tạm dùng placeholder.
  static const String baseUrl = 'https://mini-shop-api.onrender.com';

  /// Gửi Firebase idToken, nhận về app JWT do backend cấp
  Future<String> exchangeFirebaseToken(String firebaseIdToken) async {
    final res = await http
        .post(
          Uri.parse('$baseUrl/auth/google'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'idToken': firebaseIdToken}),
        )
        .timeout(const Duration(seconds: 15)); // Render free plan ngủ đông

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final jwt = data['token'] as String?;
      if (jwt == null) throw Exception('Backend không trả về token');
      return jwt;
    }
    throw Exception('Đăng nhập thất bại (server ${res.statusCode})');
  }
}
