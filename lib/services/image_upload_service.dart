import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImageUploadService {
  static Future<String?> uploadImage(File file) async {
    final uri = Uri.parse(
        "https://api.imgbb.com/1/upload?key=6ecfa1a0ba42a85550bc2762d42ffd5e");
    final base64Image = base64Encode(file.readAsBytesSync());

    final response = await http.post(uri, body: {
      'image': base64Image,
      'name': 'chat_image_${DateTime.now().millisecondsSinceEpoch}',
    });

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data']['url'];
    } else {
      return null;
    }
  }
}
