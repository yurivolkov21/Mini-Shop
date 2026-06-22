import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = AuthService();
  bool _loading = false;

  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      await _auth.signInWithGoogle();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng nhập lỗi: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_bag, size: 72, color: Colors.teal),
            const SizedBox(height: 8),
            Text('MiniShop',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 32),
            if (_loading)
              const CircularProgressIndicator()
            else
              FilledButton.icon(
                onPressed: _signIn,
                icon: const Icon(Icons.login),
                label: const Text('Sign in with Google'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(260, 50),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
