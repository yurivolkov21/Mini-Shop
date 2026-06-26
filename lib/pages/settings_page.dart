import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/cart_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.delete_sweep),
            title: const Text('Xoá toàn bộ giỏ hàng'),
            onTap: () async {
              await context.read<CartProvider>().clear();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xoá giỏ hàng')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt),
            title: const Text('Xem lại onboarding (để test)'),
            subtitle: const Text('Reset cờ rồi khởi động lại app'),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('onboarding_seen');
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã reset — restart app để xem onboarding'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
