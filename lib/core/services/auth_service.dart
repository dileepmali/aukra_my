import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../presentations/routes/app_routes.dart';

class AuthService extends GetxService {

  final _storage = const FlutterSecureStorage();
  var isLoggedIn = false.obs;

  Future<void> loadLoginStatus() async {
    final token = await _storage.read(key: 'token');
    isLoggedIn.value = token != null && token.isNotEmpty;
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
    isLoggedIn.value = true;
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'token');
    isLoggedIn.value = false;
  }

  /// Check authentication status and navigate accordingly
  /// Returns true if user is authenticated and navigated to home, false if navigated to auth flow
  static Future<bool> checkAuthAndNavigate() async {
    try {
      // Try to find AuthService, if not found then register it
      AuthService? authService;

      try {
        authService = Get.find<AuthService>();
      } catch (e) {
        print('AuthService not found in checkAuthAndNavigate, registering it...');
        Get.put<AuthService>(AuthService(), permanent: true);
        authService = Get.find<AuthService>();
      }

      await authService.loadLoginStatus();

      if (authService.isLoggedIn.value) {
        // User is authenticated, navigate to home screen
        Get.offAllNamed(AppRoutes.home);
        return true;
      } else {
        // User is not authenticated, navigate to language selection
        Get.offAllNamed(AppRoutes.selectLanguage);
        return false;
      }
    } catch (e) {
      print('Error in checkAuthAndNavigate: $e');
      // On error, navigate to language selection as fallback
      Get.offAllNamed(AppRoutes.selectLanguage);
      return false;
    }
  }
}
