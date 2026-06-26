import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../pages/cart_page.dart';

// Selector: CHỈ rebuild khi itemCount đổi (không phải mỗi lần total đổi)
class CartBadge extends StatelessWidget {
  const CartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<CartProvider, int>(
      selector: (_, cart) => cart.itemCount,
      builder: (context, count, _) {
        return IconButton(
          icon: Badge(
            isLabelVisible: count > 0,
            label: Text('$count'),
            child: const Icon(Icons.shopping_cart),
          ),
          tooltip: 'Giỏ hàng',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartPage()),
          ),
        );
      },
    );
  }
}
