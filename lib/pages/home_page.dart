import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../auth/auth_api.dart';
import '../auth/token_store.dart';
import '../providers/cart_provider.dart';
import '../widgets/favorite_button.dart';
import '../widgets/cart_badge.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'upload_page.dart';
import 'add_product_page.dart';
import 'product_detail_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadProducts();
  }

  Future<List<dynamic>> _loadProducts() async {
    final jwt = await TokenStore.read();
    final res = await http.get(
      Uri.parse('${AuthApi.baseUrl}/products'),
      headers: {'Authorization': 'Bearer $jwt'}, // <- gắn token
    ).timeout(const Duration(seconds: 60)); // Render free cold start ~30-50s

    if (res.statusCode == 401) {
      throw Exception('Phiên đăng nhập hết hạn');
    }
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
    }
    throw Exception('Lỗi tải sản phẩm (${res.statusCode})');
  }

  void _reload() {
    setState(() {
      _future = _loadProducts();
    });
  }

  Future<void> _openAddProduct() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddProductPage()),
    );
    if (created == true) _reload();
  }

  Future<void> _openDetail(Map<String, dynamic> product) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
    );
    if (changed == true) _reload(); // có sửa/xoá -> tải lại
  }

  void _addToCart(Map<String, dynamic> p) {
    // read: chỉ gọi action, KHÔNG listen trong callback
    context.read<CartProvider>().addItem(
          productId: (p['_id'] ?? '').toString(),
          name: (p['name'] ?? '').toString(),
          price: (p['price'] ?? 0) as num,
          imageUrl: (p['imageUrl'] ?? '').toString(),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm "${p['name']}" vào giỏ'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MiniShop'),
        actions: [
          const CartBadge(), // badge số lượng dùng chung
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            tooltip: 'Upload ảnh',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UploadPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Cài đặt',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Tài khoản',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddProduct,
        icon: const Icon(Icons.add),
        label: const Text('Thêm SP'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // 401 -> đá về Login
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if ('${snapshot.error}'.contains('hết hạn')) {
                await TokenStore.clear();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (r) => false,
                );
              }
            });
            return Center(child: Text('${snapshot.error}'));
          }
          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const Center(
              child: Text('Chưa có sản phẩm. Bấm "Thêm SP" để tạo.'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemCount: products.length,
              itemBuilder: (context, i) {
                final p = products[i] as Map<String, dynamic>;
                final id = (p['_id'] ?? '').toString();
                final name = (p['name'] ?? '').toString();
                return InkWell(
                  onTap: () => _openDetail(p),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.network(
                                  p['imageUrl'] ?? '',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.image_not_supported),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: DecoratedBox(
                                  decoration: const BoxDecoration(
                                    color: Colors.black26,
                                    shape: BoxShape.circle,
                                  ),
                                  child: FavoriteButton(productId: id),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    if (p['price'] != null)
                                      Text(
                                        '${p['price']} đ',
                                        style: TextStyle(
                                            color: Colors.teal.shade700),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_shopping_cart),
                                tooltip: 'Thêm vào giỏ',
                                onPressed: () => _addToCart(p),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
