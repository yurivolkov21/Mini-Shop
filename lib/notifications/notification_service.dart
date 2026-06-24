import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final _fcm = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();

  // channel phải KHỚP id khai báo trong AndroidManifest
  static const _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Thông báo quan trọng',
    description: 'Kênh cho push notification của MiniShop',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    // 1. Xin quyền (Android 13+ và iOS)
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('Quyền notification: ${settings.authorizationStatus}');

    // 2. Khởi tạo local notifications + tạo channel (Android)
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _local.initialize(
      settings: initSettings, // v22: 'settings' là named parameter
      onDidReceiveNotificationResponse: (resp) {
        // user tap notification do MÌNH vẽ (foreground)
        print('Tap local notif, payload=${resp.payload}');
      },
    );
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // 3. Lấy token thiết bị (gửi lên backend ở bước sau)
    final token = await _fcm.getToken();
    print('FCM token: $token');
    // TODO: gửi token lên backend POST /devices

    // token có thể đổi -> lắng nghe để cập nhật backend
    _fcm.onTokenRefresh.listen((newToken) {
      print('Token refresh: $newToken');
      // TODO: gửi newToken lên backend
    });

    // 4a. FOREGROUND: app đang mở -> Android KHÔNG tự hiện, mình tự vẽ
    FirebaseMessaging.onMessage.listen((message) {
      final n = message.notification;
      if (n != null) {
        _local.show(
          id: n.hashCode, // v22: tất cả là named parameter
          title: n.title,
          body: n.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: message.data['route'],
        );
      }
    });

    // 4b. BACKGROUND-TAP: app ở nền, user tap notification mở app
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);

    // 4c. TERMINATED: app đã tắt hẳn, mở lên TỪ notification
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) _handleTap(initialMessage);
  }

  void _handleTap(RemoteMessage message) {
    final route = message.data['route'];
    print('Mở app từ notification, route=$route');
    // TODO: dùng navigatorKey để điều hướng tới màn tương ứng
  }
}
