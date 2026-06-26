import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApi {
  // Backend gộp (Node + TS + MongoDB) trên Render — KHÔNG có dấu / ở cuối.
  // Local dev: đổi sang 'http://<IP_LAN>:3000' (máy thật) hoặc 'http://10.0.2.2:3000' (emulator).
  static const String baseUrl = 'https://mini-shop-api-2dno.onrender.com';

  /// Gửi Firebase idToken, nhận về app JWT do backend cấp
  Future<String> exchangeFirebaseToken(String firebaseIdToken) async {
    final res = await http
        .post(
          Uri.parse('$baseUrl/auth/google'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'idToken': firebaseIdToken}),
        )
        .timeout(const Duration(seconds: 60)); // Render free cold start ~30-50s

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final jwt = data['token'] as String?;
      if (jwt == null) throw Exception('Backend không trả về token');
      return jwt;
    }
    throw Exception('Đăng nhập thất bại (server ${res.statusCode})');
  }
}
