import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'auth/auth_gate.dart';
import 'pages/onboarding_page.dart';
import 'providers/cart_provider.dart';
import 'notifications/fcm_background_handler.dart';
import 'notifications/notification_service.dart';

// ⚠️ Web client OAuth ID lấy từ google-services.json (client_type = 3)
const serverClientId =
    '673847018023-nsbjmg81itvrtjm6s30biti50bahguv4.apps.googleusercontent.com';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // FCM: đăng ký handler nền NGAY sau init Firebase, TRƯỚC runApp
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationService().initialize();
  // Google Sign-In (Lab 1): initialize 1 lần trước khi authenticate
  await GoogleSignIn.instance.initialize(serverClientId: serverClientId);

  // Cart: tạo provider + nạp giỏ đã lưu TRƯỚC khi vẽ UI
  final cart = CartProvider();
  await cart.load();

  runApp(
    // .value vì 'cart' đã tạo sẵn ở trên (KHÔNG dùng create:)
    ChangeNotifierProvider.value(
      value: cart,
      child: const MiniShopApp(),
    ),
  );
}

class MiniShopApp extends StatelessWidget {
  const MiniShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MiniShop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const AppLauncher(), // điểm vào: Onboarding (lần đầu) -> AuthGate
    );
  }
}

// Đọc cờ onboarding_seen: chưa xem -> Onboarding; đã xem -> AuthGate (Login/Home)
class AppLauncher extends StatefulWidget {
  const AppLauncher({super.key});

  @override
  State<AppLauncher> createState() => _AppLauncherState();
}

class _AppLauncherState extends State<AppLauncher> {
  bool? _showOnboarding; // null = đang đọc prefs

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_seen') ?? false;
    if (!mounted) return;
    setState(() => _showOnboarding = !seen);
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _showOnboarding! ? const OnboardingPage() : const AuthGate();
  }
}
