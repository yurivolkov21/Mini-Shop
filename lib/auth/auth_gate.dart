import 'package:flutter/material.dart';
import 'token_store.dart';
import '../pages/login_page.dart';
import '../pages/home_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<String?> _future;

  @override
  void initState() {
    super.initState();
    _future = TokenStore.read(); // đọc JWT 1 lần
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final jwt = snapshot.data;
        return (jwt != null && jwt.isNotEmpty)
            ? const HomePage()
            : const LoginPage();
      },
    );
  }
}
