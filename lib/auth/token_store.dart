import 'package:shared_preferences/shared_preferences.dart';

class TokenStore {
  static const _key = 'app_jwt';

  static Future<void> save(String jwt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jwt);
  }

  static Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
