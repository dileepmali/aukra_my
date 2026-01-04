import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'auth_storage.dart';

class ImageUploadApi {
  String get baseUri => '${dotenv.env['API_BASE_URL'] ?? "https://api.anantkhata.com"}/';

  /// Upload single image and get uploadedKey
  Future<int?> uploadImage(File imageFile) async {
    try {
      final token = await AuthStorage.getValidToken();
      if (token == null) {
        throw Exception('Authentication required. Please login.');
      }

      final url = '${baseUri}api/upload'; // Adjust endpoint as per your API
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'deviceName': 'Flutter',
        'deviceType': 'ANDROID',
        'deviceId': 'flutter_dev_001',
        'deviceVersion': '1.0.5',
        'appVersion': 'ASAWA',
      });

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // Field name - adjust as per your API
          imageFile.path,
        ),
      );

      debugPrint('🖼️ Uploading image: ${imageFile.path}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📤 Upload Response Status: ${response.statusCode}');
      debugPrint('📤 Upload Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Adjust based on your API response structure
        // Example: {"uploadedKey": 123} or {"id": 123} or {"data": {"id": 123}}
        if (data is Map<String, dynamic>) {
          return data['uploadedKey'] ?? data['id'] ?? data['data']?['id'];
        }
      } else {
        throw Exception('Failed to upload image: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Image Upload Error: $e');
      rethrow;
    }
    return null;
  }

  /// Upload multiple images and get array of uploadedKeys
  Future<List<int>> uploadMultipleImages(List<File> imageFiles) async {
    List<int> uploadedKeys = [];

    for (var imageFile in imageFiles) {
      try {
        final uploadedKey = await uploadImage(imageFile);
        if (uploadedKey != null) {
          uploadedKeys.add(uploadedKey);
        }
      } catch (e) {
        debugPrint('❌ Failed to upload image: ${imageFile.path}');
        // Continue uploading other images even if one fails
      }
    }

    return uploadedKeys;
  }
}
