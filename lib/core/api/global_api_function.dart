import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';

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
    
    // 🔍 Enhanced Network Logging
    print('\n🌐 ===== API REQUEST START =====');
    print('📍 URL: $fullUrl');
    print('🔄 Method: $method');
    print('⏰ Timeout: ${timeout.inSeconds}s');
    print('🔐 Requires Auth: $requireAuth');

    try {
      String? token;

      if (requireAuth) {
        token = await AuthStorage.getValidToken();
        if (token == null) {
          print('❌ AUTH FAILED: No valid token found');
          errorMessage = "Authentication required. Please login.";
          data = null;
          isLoading = false;
          notifyListeners();
          print('🌐 ===== API REQUEST END (AUTH FAILED) =====\n');
          return;
        }
        print('🔑 Auth Token: ${token.substring(0, 20)}...');
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
      
      print('📋 Headers: $requestHeaders');
      if (body != null) {
        print('📦 Body: $body');
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

      // 📊 Response Logging
      print('📈 Status Code: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        data = _tryDecode(response.body);
        print('✅ SUCCESS: Data parsed successfully');

        // Save token automatically if returned
        if (data is Map && data["token"] != null) {
          print('🔑 Token received from API: ${data["token"]}');
          await AuthStorage.saveToken(data["token"]);
        } else {
          print('⚠️ No token found in API response');
          if (data is Map) {
            print('🔍 Response data keys: ${data.keys.toList()}');
          }
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
        
        print('❌ ERROR: $errorMsg');
        print('📄 Error Body: $errorBody');
        
        errorMessage = errorMsg;
        data = errorBody; // Keep error data for detailed error handling
      }
    } on SocketException {
      errorMessage = "No Internet Connection";
      data = null;
      print('❌ SOCKET EXCEPTION: No internet connection detected');
    } on FormatException {
      errorMessage = "Invalid Response Format";
      data = null;
    } on HttpException {
      errorMessage = "Bad HTTP Response";
      data = null;
    } on TimeoutException {
      errorMessage = "Request Timed Out";
      data = null;
    } catch (e) {
      errorMessage = "Unexpected Error: $e";
      data = null;
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
