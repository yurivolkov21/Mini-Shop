import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../firebase_options.dart';

// PHẢI là hàm top-level + @pragma để không bị xoá khi build release
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Isolate riêng -> phải init lại Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Notification dạng 'notification' sẽ được HĐH tự hiện; ở đây chỉ log
  print('[BG] message: ${message.messageId} data=${message.data}');
}
