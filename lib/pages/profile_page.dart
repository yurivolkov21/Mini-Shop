import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final user = auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 48,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? const Icon(Icons.person, size: 48)
                  : null,
            ),
            const SizedBox(height: 12),
            Text(user?.displayName ?? '(Không tên)',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(user?.email ?? '', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () async {
                await auth.signOut();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(220, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
