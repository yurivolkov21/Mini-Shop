import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_api.dart';
import 'token_store.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _api = AuthApi();

  User? get currentUser => _auth.currentUser;

  /// Đăng nhập Google -> Firebase -> đổi lấy app JWT -> lưu máy.
  /// Trả về Firebase User để UI hiển thị tên/avatar.
  Future<User> signInWithGoogle() async {
    // 1. Mở hộp chọn tài khoản Google (API v7)
    final googleUser = await GoogleSignIn.instance.authenticate();

    // 2. Lấy idToken của Google (v7: authentication là đồng bộ, không await)
    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) {
      // Thường do thiếu serverClientId khi initialize()
      throw Exception('Không lấy được idToken Google (kiểm tra serverClientId)');
    }

    // 3. Đổi sang Firebase credential rồi đăng nhập Firebase
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final userCred = await _auth.signInWithCredential(credential);
    final user = userCred.user!;

    // 4. Lấy Firebase ID token, gửi backend đổi lấy app JWT, lưu lại
    final firebaseIdToken = await user.getIdToken();
    final appJwt = await _api.exchangeFirebaseToken(firebaseIdToken!);
    await TokenStore.save(appJwt);

    return user;
  }

  /// Logout: xoá sạch Firebase + Google + JWT
  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
    await TokenStore.clear();
  }
}
