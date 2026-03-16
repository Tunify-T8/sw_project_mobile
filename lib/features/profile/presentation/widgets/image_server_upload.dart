import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String _cloudName = "your_cloud_name";
  static const String _uploadPreset = "your_unsigned_preset_name";

  static Future<String?> uploadImage(File imageFile) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

    try {
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = utf8.decode(responseData); // Better for special characters
        final jsonResponse = jsonDecode(responseString);
        return jsonResponse['secure_url'] as String;
      }
      return null;
    } catch (e) {
      print('Cloudinary Error: $e');
      return null;
    }
  }
}