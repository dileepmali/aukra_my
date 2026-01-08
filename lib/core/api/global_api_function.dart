import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';
import '../utils/secure_logger.dart';

class ApiFetcher extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  dynamic data;

  String get baseUri => '${dotenv.env['API_BASE_URL'] ?? "https://api.anantkhata.com"}/';

  ApiFetcher();

  Future<void> request({
    required String url,
    String method = "GET",
    Map<String, String>? headers,
    dynamic body,
    Duration timeout = const Duration(seconds: 59),
    bool requireAuth = true,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final fullUrl = '$baseUri$url';

    // 🔍 Enhanced Network Logging (Only in debug mode)
    if (kDebugMode) {
      SecureLogger.divider('API REQUEST');
      SecureLogger.info('URL: $fullUrl');
      SecureLogger.info('Method: $method');
      SecureLogger.info('Timeout: ${timeout.inSeconds}s');
      SecureLogger.info('Requires Auth: $requireAuth');
    }

    try {
      String? token;

      if (requireAuth) {
        token = await AuthStorage.getValidToken();
        if (token == null) {
          SecureLogger.error('AUTH FAILED: No valid token found');
          errorMessage = "Authentication required. Please login.";
          data = null;
          isLoading = false;
          notifyListeners();
          return;
        }
        SecureLogger.log('Auth Token: ${token.substring(0, 20)}...', sensitive: true);
      }

      // Merge headers safely with device info
      final requestHeaders = {
        "Content-Type": "application/json",
        "deviceName": "Flutter",  // You can get real device name using device_info_plus package
        "deviceType": "ANDROID",  // Can be dynamic: Platform.isAndroid ? "ANDROID" : "IOS"
        "deviceId": "flutter_dev_001",  // Generate unique device ID
        "deviceVersion": "1.0.5",  // Your app version
        "appVersion": "ASAWA",  // Your app name/version
        if (token != null) "Authorization": "Bearer $token",
        ...?headers,
      };
      
      if (kDebugMode) {
        SecureLogger.log('Headers: $requestHeaders', sensitive: true);
        if (body != null) {
          SecureLogger.info('Body: $body');
        }
      }

      late http.Response response;

      switch (method.toUpperCase()) {
        case "POST":
          response = await http
              .post(Uri.parse(fullUrl),
                  headers: requestHeaders, body: jsonEncode(body))
              .timeout(timeout);
          break;
        case "PUT":
          response = await http
              .put(Uri.parse(fullUrl),
                  headers: requestHeaders, body: jsonEncode(body))
              .timeout(timeout);
          break;
        case "PATCH":
          response = await http
              .patch(Uri.parse(fullUrl),
                  headers: requestHeaders, body: jsonEncode(body))
              .timeout(timeout);
          break;
        case "DELETE":
          // Delete usually shouldn't have a body
          response = await http
              .delete(Uri.parse(fullUrl), headers: requestHeaders)
              .timeout(timeout);
          break;
        default:
          response =
              await http.get(Uri.parse(fullUrl), headers: requestHeaders)
                  .timeout(timeout);
      }

      // 📊 Response Logging (Only in debug mode)
      if (kDebugMode) {
        SecureLogger.apiResponse(
          statusCode: response.statusCode,
          url: fullUrl,
          body: response.body,
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        data = _tryDecode(response.body);
        SecureLogger.success('Data parsed successfully');

        // Save token automatically if returned
        if (data is Map && data["token"] != null) {
          SecureLogger.log('Token received from API', sensitive: true);
          await AuthStorage.saveToken(data["token"]);
        }
      } else {
        // Parse error response body for better error messages
        final errorBody = _tryDecode(response.body);
        String errorMsg = "Server Error: ${response.statusCode}";

        if (errorBody is Map && errorBody['message'] != null) {
          errorMsg = errorBody['message'];
        } else if (response.reasonPhrase != null) {
          errorMsg += " → ${response.reasonPhrase}";
        }

        SecureLogger.error('API Error: $errorMsg');

        errorMessage = errorMsg;
        data = errorBody; // Keep error data for detailed error handling
      }
    } on SocketException {
      errorMessage = "No Internet Connection";
      data = null;
      SecureLogger.error('SOCKET EXCEPTION: No internet connection');
    } on FormatException {
      errorMessage = "Invalid Response Format";
      data = null;
      SecureLogger.error('FORMAT EXCEPTION: Invalid response format');
    } on HttpException {
      errorMessage = "Bad HTTP Response";
      data = null;
      SecureLogger.error('HTTP EXCEPTION: Bad response');
    } on TimeoutException {
      errorMessage = "Request Timed Out";
      data = null;
      SecureLogger.error('TIMEOUT: Request took too long');
    } catch (e) {
      errorMessage = "Unexpected Error: $e";
      data = null;
      SecureLogger.error('UNEXPECTED ERROR: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  dynamic _tryDecode(String responseBody) {
    try {
      // Clean the response body from invalid UTF-8 characters
      final cleanedBody = _cleanUtf8String(responseBody);
      return jsonDecode(cleanedBody);
    } catch (e) {
      debugPrint('Warning: JSON decode failed: $e');
      return responseBody;
    }
  }

  String _cleanUtf8String(String input) {
    try {
      // Convert to bytes and back to ensure valid UTF-8
      final bytes = utf8.encode(input);
      return utf8.decode(bytes, allowMalformed: true);
    } catch (e) {
      debugPrint('Warning: UTF-8 cleaning failed: $e');
      // Return the original string if cleaning fails
      return input;
    }
  }
}
