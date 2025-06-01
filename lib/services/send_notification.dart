import 'dart:convert';
import 'package:http/http.dart' as http;

/// Gửi thông báo từ app Flutter lên server Node.js để đẩy FCM
Future<void> sendNotificationFromFlutter({
  required String token,
  required String title,
  required String body,
}) async {
  const serverUrl =
      'http://10.0.2.2:3000/send-notification'; // nếu chạy trên Android Emulator

  try {
    final response = await http.post(
      Uri.parse(serverUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'title': title,
        'body': body,
      }),
    );

    if (response.statusCode == 200) {
      print("✅ Gửi thông báo thành công!");
    } else {
      print("❌ Gửi thất bại: ${response.body}");
    }
  } catch (e) {
    print("🚨 Lỗi khi gửi thông báo: $e");
  }
}
