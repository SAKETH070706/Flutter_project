import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'cc4mb4xr';
  static const String apiKey = '235475845626936';
  static const String apiSecret = '5yly4qz95-ESvOdGKWNCdhTSKAg';

  /// Uploads raw image bytes to Cloudinary using signed authentication.
  /// Returns the CDN secure_url (e.g. https://res.cloudinary.com/...)
  static Future<String?> uploadImage(
    Uint8List imageBytes, {
    String fileName = 'student_photo.jpg',
  }) async {
    try {
      final timestamp =
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

      // Cloudinary signature formula:
      // Alphabetical order of parameters + apiSecret
      final stringToSign = 'timestamp=$timestamp$apiSecret';
      final signature = sha1.convert(utf8.encode(stringToSign)).toString();

      final uri =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri);

      request.fields['api_key'] = apiKey;
      request.fields['timestamp'] = timestamp;
      request.fields['signature'] = signature;

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: fileName,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['secure_url'] as String?;
      } else {
        // Fallback: If signed fails due to account settings, try generic unsigned preset
        return await _uploadUnsignedFallback(imageBytes, fileName);
      }
    } catch (e) {
      return null;
    }
  }

  // Backup fallback using standard unsigned upload if enabled
  static Future<String?> _uploadUnsignedFallback(
      Uint8List imageBytes, String fileName) async {
    try {
      final uri =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = 'ml_default';
      request.files.add(
        http.MultipartFile.fromBytes('file', imageBytes, filename: fileName),
      );
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['secure_url'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
