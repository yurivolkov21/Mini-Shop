import 'package:shared_preferences/shared_preferences.dart';

/// Lưu danh sách ID sản phẩm yêu thích.
/// Dùng String vì product `_id` của Mongo là String (không phải int như lab gốc).
class FavoritesStorage {
  static const _key = 'favorites';

  Future<Set<String>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? []).toSet(); // Set: không trùng, check nhanh
  }

  Future<void> toggle(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = await getAll();
    if (favs.contains(productId)) {
      favs.remove(productId); // đang thích => bỏ
    } else {
      favs.add(productId); // chưa thích => thêm
    }
    await prefs.setStringList(_key, favs.toList());
  }

  Future<bool> isFavorite(String productId) async {
    final favs = await getAll();
    return favs.contains(productId);
  }
}
