import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/product_repo.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_badge.dart';
import 'add_product_page.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _repo = ProductRepo();
  bool _deleting = false;

  Future<void> _edit() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddProductPage(existing: widget.product)),
    );
    if (ok == true && mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xoá sản phẩm?'),
        content: Text('Xoá "${widget.product['name']}" khỏi cửa hàng.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _deleting = true);
    try {
      await _repo.deleteProduct(widget.product['_id'] as String);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi xoá: $e')),
      );
    }
  }

  void _addToCart() {
    final p = widget.product;
    context.read<CartProvider>().addItem(
          productId: (p['_id'] ?? '').toString(),
          name: (p['name'] ?? '').toString(),
          price: (p['price'] ?? 0) as num,
          imageUrl: (p['imageUrl'] ?? '').toString(),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm "${p['name']}" vào giỏ'),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final imageUrl = (p['imageUrl'] ?? '').toString();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
        actions: [
          const CartBadge(),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Sửa',
            onPressed: _deleting ? null : _edit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.red,
            tooltip: 'Xoá',
            onPressed: _deleting ? null : _delete,
          ),
        ],
      ),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: imageUrl.isEmpty
                ? Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported, size: 64),
                  )
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.broken_image, size: 64),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (p['name'] ?? '').toString(),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '${p['price'] ?? ''} đ',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.teal.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Chip(label: Text((p['category'] ?? 'general').toString())),
                if ((p['description'] ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Mô tả', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text((p['description']).toString()),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Thêm vào giỏ'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: _addToCart,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
