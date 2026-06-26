import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';

/// Chỉ lo đọc/ghi cả list xuống shared_preferences dạng JSON.
/// Logic cộng dồn quantity nằm ở CartProvider.
class CartStorage {
  static const _key = 'cart';

  Future<List<CartItem>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_key);
    if (str == null) return [];
    final List<dynamic> jsonList = jsonDecode(str) as List<dynamic>;
    return jsonList
        .map((j) => CartItem.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(items.map((i) => i.toJson()).toList()),
    );
  }
}
