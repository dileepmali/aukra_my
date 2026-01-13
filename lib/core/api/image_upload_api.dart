import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'auth_storage.dart';
import '../services/device_info_service.dart';

class ImageUploadApi {
  String get baseUri =>
      '${dotenv.env['API_BASE_URL'] ?? "https://api.anantkhata.com"}/';

  /// Get pre-signed S3 upload URL from backend
  /// POST /api/ledgerTranscation/get-upload-url/{merchantId}
  Future<Map<String, dynamic>> _getUploadUrl({
    required int merchantId,
    required String fileName,
    required String mimeType,
  }) async {
    try {
      final token = await AuthStorage.getValidToken();
      if (token == null) {
        throw Exception('Authentication required. Please login.');
      }

      final url = '${baseUri}api/ledgerTranscation/get-upload-url/$merchantId';

      debugPrint('🔗 Getting upload URL from: $url');
      debugPrint('   - fileName: $fileName');
      debugPrint('   - mimeType: $mimeType');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'deviceName': DeviceInfoService.deviceName,
          'deviceType': DeviceInfoService.deviceType,
          'deviceId': DeviceInfoService.deviceId,
          'deviceVersion': DeviceInfoService.deviceVersion,
          'appVersion': '1.0.0',
        },
        body: jsonEncode({
          'fileName': fileName,
          'mimeType': mimeType,
        }),
      );

      debugPrint('📥 Get Upload URL Response: ${response.statusCode}');
      debugPrint('📥 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['uploadUrl'] == null || data['keyId'] == null) {
          throw Exception('Invalid response: missing uploadUrl or keyId');
        }

        return {
          'uploadUrl': data['uploadUrl'] as String,
          'keyId': data['keyId'] as int,
        };
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to get upload URL');
      }
    } catch (e) {
      debugPrint('❌ Get Upload URL Error: $e');
      rethrow;
    }
  }

  /// Upload image bytes directly to S3 using pre-signed URL
  /// PUT request to S3 uploadUrl
  Future<bool> _uploadToS3({
    required String uploadUrl,
    required File imageFile,
    required String mimeType,
  }) async {
    try {
      debugPrint('📤 Uploading to S3: $uploadUrl');

      // Read file as bytes
      final bytes = await imageFile.readAsBytes();
      debugPrint('   - File size: ${bytes.length} bytes');

      // PUT request to S3 pre-signed URL
      final response = await http.put(
        Uri.parse(uploadUrl),
        headers: {
          'Content-Type': mimeType,
        },
        body: bytes,
      );

      debugPrint('📤 S3 Upload Response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ S3 Upload successful');
        return true;
      } else {
        debugPrint('❌ S3 Upload failed: ${response.body}');
        throw Exception('Failed to upload image to S3: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ S3 Upload Error: $e');
      rethrow;
    }
  }

  /// Get MIME type from file
  String _getMimeType(File file) {
    final mimeType = lookupMimeType(file.path);
    return mimeType ?? 'image/jpeg'; // Default to jpeg if not detected
  }

  /// Get file name from file path
  String _getFileName(File file) {
    return path.basename(file.path);
  }

  /// Upload single image using pre-signed S3 URL
  /// Returns keyId on success, null on failure
  Future<int?> uploadImage(File imageFile) async {
    try {
      // Get merchant ID
      final merchantId = await AuthStorage.getMerchantId();
      if (merchantId == null) {
        throw Exception('Merchant ID not found. Please login again.');
      }

      // Extract file info
      final fileName = _getFileName(imageFile);
      final mimeType = _getMimeType(imageFile);

      debugPrint('🖼️ Starting image upload: $fileName');

      // Step 1: Get pre-signed upload URL from backend
      final uploadData = await _getUploadUrl(
        merchantId: merchantId,
        fileName: fileName,
        mimeType: mimeType,
      );

      final uploadUrl = uploadData['uploadUrl'] as String;
      final keyId = uploadData['keyId'] as int;

      debugPrint('🔑 Received keyId: $keyId');

      // Step 2: Upload image to S3 using pre-signed URL
      final uploadSuccess = await _uploadToS3(
        uploadUrl: uploadUrl,
        imageFile: imageFile,
        mimeType: mimeType,
      );

      if (uploadSuccess) {
        debugPrint('✅ Image uploaded successfully with keyId: $keyId');
        return keyId;
      } else {
        throw Exception('S3 upload failed');
      }
    } catch (e) {
      debugPrint('❌ Image Upload Error: $e');
      rethrow;
    }
  }

  /// Upload multiple images and get array of keyIds
  /// Returns list of successfully uploaded keyIds
  Future<List<int>> uploadMultipleImages(List<File> imageFiles) async {
    List<int> uploadedKeys = [];

    debugPrint('📤 Starting batch upload of ${imageFiles.length} images...');

    for (int i = 0; i < imageFiles.length; i++) {
      final imageFile = imageFiles[i];
      try {
        debugPrint('📤 Uploading image ${i + 1}/${imageFiles.length}');
        final keyId = await uploadImage(imageFile);
        if (keyId != null) {
          uploadedKeys.add(keyId);
          debugPrint('✅ Image ${i + 1} uploaded: keyId = $keyId');
        }
      } catch (e) {
        debugPrint('❌ Failed to upload image ${i + 1}: ${imageFile.path}');
        debugPrint('   Error: $e');
        // Continue uploading other images even if one fails
      }
    }

    debugPrint('📤 Batch upload complete: ${uploadedKeys.length}/${imageFiles.length} successful');
    debugPrint('📤 Uploaded keyIds: $uploadedKeys');

    return uploadedKeys;
  }
}
