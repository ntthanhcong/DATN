import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _verificationId;

  /// Gửi OTP đến số điện thoại
  bool isValidPhoneNumber(String rawPhone) {
    // Nhập từ người dùng: 097xxxxxxx
    return RegExp(r'^0(3[2-9]|5[6|8|9]|7[06-9]|8[1-9]|9[0-9])[0-9]{7}$')
        .hasMatch(rawPhone);
  }

  Future<bool> checkPhoneExists(String phone) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  String normalizePhone(String rawPhone) {
    // Ví dụ: 0978151445 => +84978151445
    return '+84' + rawPhone.substring(1);
  }

  Future<String?> sendOTP(String rawPhone,
      {bool forRegistration = true}) async {
    if (!isValidPhoneNumber(rawPhone)) {
      return "Số điện thoại không hợp lệ";
    }

    final phone = normalizePhone(rawPhone);

    if (forRegistration) {
      final exists = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (exists.docs.isNotEmpty) return "Số điện thoại đã được sử dụng";
    }

    // Gửi OTP
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (e) => throw e.message ?? "Lỗi xác minh",
        codeSent: (verificationId, _) => _verificationId = verificationId,
        codeAutoRetrievalTimeout: (verificationId) =>
            _verificationId = verificationId,
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Xác minh mã OTP
  Future<bool> verifyOTP(String otp) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Đăng nhập bằng username và password (Firestore)
  Future<UserModel?> loginWithUsername(String username, String password) async {
    final userDoc = await _firestore.collection('users').doc(username).get();
    if (!userDoc.exists || userDoc['password'] != password) return null;
    return UserModel.fromJson(userDoc.data()!, userDoc.id);
  }

  /// Đăng ký người dùng mới
  /// Đăng ký người dùng mới với kiểm tra trùng lặp username, email, phone
  Future<String?> registerUser(UserModel user) async {
    try {
      final existingByUsername =
          await _firestore.collection('users').doc(user.username).get();
      if (existingByUsername.exists) return "Tên tài khoản đã tồn tại";

      final existingEmail = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();
      if (existingEmail.docs.isNotEmpty) return "Email đã được sử dụng";

      await _firestore
          .collection('users')
          .doc(user.username)
          .set(user.toJson());
      return null;
    } catch (e) {
      return "Lỗi đăng ký: $e";
    }
  }

  /// Gửi OTP để đặt lại mật khẩu
  Future<String?> sendPasswordResetOTP(String phone) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (e) => throw e.message ?? "Lỗi gửi OTP",
        codeSent: (verificationId, _) => _verificationId = verificationId,
        codeAutoRetrievalTimeout: (verId) => _verificationId = verId,
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Xác minh OTP trong quá trình quên mật khẩu
  Future<bool> verifyPasswordOTP(String otp) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Đặt lại mật khẩu mới
  Future<bool> resetPassword(String username, String newPassword) async {
    try {
      final userDoc = _firestore.collection('users').doc(username);
      final snapshot = await userDoc.get();
      if (!snapshot.exists) return false;
      await userDoc.update({'password': newPassword});
      return true;
    } catch (_) {
      return false;
    }
  }
}
