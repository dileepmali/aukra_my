import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/secure_logger.dart';
import '../services/device_info_service.dart';
import 'auth_storage.dart';

class LogoutApi {
  static String get baseUri =>
      '${dotenv.env['API_BASE_URL'] ?? "https://api.anantkhata.com"}/';

  /// Call logout API: POST /api/auth/logout
  ///
  /// Success Response (200):
  /// {
  ///   "message": "Logout successfully"
  /// }
  ///
  /// Error Response (400):
  /// {
  ///   "statusCode": 400,
  ///   "message": "Invalid request data",
  ///   "errors": [...]
  /// }
  static Future<Map<String, dynamic>> logout() async {
    try {
      final url = '${baseUri}api/auth/logout';

      SecureLogger.divider('LOGOUT API');
      SecureLogger.info('URL: $url');
      SecureLogger.info('Method: POST');

      // Get token for authorization
      final token = await AuthStorage.getValidToken();
      if (token == null) {
        SecureLogger.error('No valid token found for logout');
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      // Prepare headers with real device info
      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
        "deviceName": DeviceInfoService.deviceName,
        "deviceType": DeviceInfoService.deviceType,
        "deviceId": DeviceInfoService.deviceId,
        "deviceVersion": DeviceInfoService.deviceVersion,
        "appVersion": "1.0.0",
      };

      SecureLogger.log('Headers prepared', sensitive: true);

      // Make POST request (no body needed)
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      SecureLogger.info('Response Status: ${response.statusCode}');
      SecureLogger.info('Response Body: ${response.body}');

      // Parse response
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        SecureLogger.success('✅ Logout API call successful');
        return {
          'success': true,
          'message': responseData['message'] ?? 'Logout successfully',
          'data': responseData,
        };
      } else {
        // Error response
        SecureLogger.error('❌ Logout API failed: ${responseData['message']}');
        return {
          'success': false,
          'message': responseData['message'] ?? 'Logout failed',
          'statusCode': responseData['statusCode'] ?? response.statusCode,
          'errors': responseData['errors'],
        };
      }
    } catch (e, stackTrace) {
      SecureLogger.error('❌ Logout API Exception: $e');
      SecureLogger.error('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}
