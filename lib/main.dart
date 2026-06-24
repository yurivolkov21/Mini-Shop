import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
// import 'auth/auth_gate.dart'; // bật lại khi đổi home về AuthGate (sau khi có auth backend)
import 'pages/upload_page.dart'; // TẠM: test PHẦN B Cloudinary
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
  runApp(const MiniShopApp());
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
      home: const UploadPage(), // TẠM: test Cloudinary; đổi lại const AuthGate() khi auth backend xong
    );
  }
}
