import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../auth/auth_api.dart';
import '../auth/token_store.dart';
import 'login_page.dart';
import 'profile_page.dart';

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
    ).timeout(const Duration(seconds: 15));

    if (res.statusCode == 401) {
      throw Exception('Phiên đăng nhập hết hạn');
    }
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
    }
    throw Exception('Lỗi tải sản phẩm (${res.statusCode})');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MiniShop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
          ),
        ],
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
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: products.length,
            itemBuilder: (context, i) {
              final p = products[i] as Map<String, dynamic>;
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Image.network(
                        p['imageUrl'] ?? '',
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(p['name'] ?? '',
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
