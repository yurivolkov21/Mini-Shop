import 'dart:io';
import 'package:dio/dio.dart';

class CloudImage {
  final String url;
  final String publicId; // cần để xoá
  CloudImage(this.url, this.publicId);

  factory CloudImage.fromJson(Map<String, dynamic> j) =>
      CloudImage(j['url'] as String, j['publicId'] as String);
}

class CloudinaryRepo {
  // ⚠️ THAY bằng URL server Node của bạn.
  // - Máy thật (cùng WiFi với PC): IP LAN máy tính -> 'http://192.168.20.55:3000'
  // - Android emulator + server local: 'http://10.0.2.2:3000'
  // - Deploy Render: 'https://minishop-media.onrender.com'
  static const String baseUrl = 'http://192.168.20.55:3000';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
  ));

  /// Upload 1 ảnh lên server (server đẩy tiếp lên Cloudinary).
  /// onProgress: 0.0 -> 1.0 (tiến trình phone -> server).
  Future<CloudImage> uploadImage(
    File file, {
    void Function(double progress)? onProgress,
  }) async {
    final form = FormData.fromMap({
      'image': await MultipartFile.fromFile(file.path, filename: 'upload.jpg'),
    });
    final res = await _dio.post(
      '/images',
      data: form,
      onSendProgress: (sent, total) {
        if (total > 0) onProgress?.call(sent / total);
      },
    );
    return CloudImage.fromJson(res.data as Map<String, dynamic>);
  }

  /// Lấy toàn bộ ảnh để vẽ gallery
  Future<List<CloudImage>> listImages() async {
    final res = await _dio.get('/images');
    return (res.data as List)
        .map((j) => CloudImage.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// Xoá ảnh theo publicId (dio tự encode dấu / trong query)
  Future<void> deleteImage(String publicId) async {
    await _dio.delete('/images', queryParameters: {'publicId': publicId});
  }
}
