import 'package:get/get.dart';

import '../core/api/auth_storage.dart';
import '../presentations/language/select_language_screen.dart';
import '../presentations/routes/app_routes.dart';


class SplashController extends GetxController {
  var isNavigating = false.obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  bool skipDelay = false;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments is Map<String, dynamic>) {
      skipDelay = (Get.arguments as Map<String, dynamic>)['skipDelay'] ?? false;
    }
    
    // Force skipDelay in test mode
    if (Get.testMode) {
      skipDelay = true;
    }
    
    initializeApp();
  }

  Future<void> initializeApp() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // ⚡ HIGHLY OPTIMIZED: Reduced to 150ms for ultra-fast app startup
      // Minimal delay for SharedFileHandlerService while keeping deep links fast
      if (!skipDelay && !Get.testMode) {
        await Future.delayed(const Duration(milliseconds: 150)); // Reduced from 300ms
      }

      // Check token validity and navigate accordingly
      // await _checkAuthenticationAndNavigate();
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      _handleError();
    }
  }

  Future<void> _checkAuthenticationAndNavigate() async {
    try {
      isLoading.value = false;

      // Skip auth check in test mode
      if (Get.testMode) {
        return;
      }

      // Normal authentication flow
      // Check if user is already logged in
      final bool isLoggedIn = await AuthStorage.isTokenValid();
      print('Splash: Login status - ${isLoggedIn ? "Logged in" : "Not logged in"}');

      if (isLoggedIn) {
        // User is logged in - navigate to AppEntryWrapper for authentication
        print('Splash: User logged in - going to AppEntryWrapper for authentication');
        _navigateToAppEntryWrapper();
      } else {
        // User is not logged in - skip authentication, go to language selection
        print('Splash: User not logged in - going to language selection');
        _navigateToLanguageScreen();
      }

    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Navigation failed: $e';
      // Navigate to language screen on error
      _navigateToLanguageScreen();
    }
  }

  void _navigateToAppEntryWrapper() {
    if (isNavigating.value) return;

    isNavigating.value = true;

    try {
      // Navigate to AppEntryWrapper for device authentication
      Get.offAllNamed(AppRoutes.appEntryWrapper);
    } catch (_) {
      isNavigating.value = false;
      // Fallback to main screen
      _navigateToMainScreen();
    }
  }

  void _navigateToLanguageScreen() {
    if (isNavigating.value) return;
    
    isNavigating.value = true;
    
    try {
      if (AppRoutes.selectLanguage.isNotEmpty) {
        Get.offNamed(AppRoutes.selectLanguage);
      } else {
        Get.off(() => const SelectLanguageScreen());
      }
    } catch (_) {
      isNavigating.value = false;
      Get.off(() => const SelectLanguageScreen());
    }
  }

  void _navigateToMainScreen() {
    if (isNavigating.value) return;
    
    isNavigating.value = true;
    
    try {
      // Navigate to main screen for authenticated users
      Get.offNamed(AppRoutes.main);
    } catch (_) {
      isNavigating.value = false;
      // Ultimate fallback to language selection
      Get.off(() => const SelectLanguageScreen());
    }
  }


  void _handleError() {
    Get.defaultDialog(
      title: 'त्रुटि',
      middleText: 'कुछ गलत हुआ है। कृपया ऐप को दोबारा शुरू करें।',
      barrierDismissible: false,
      onConfirm: () {
        Get.back();
        isNavigating.value = false;
        initializeApp();
      },
      onCancel: () {
        Get.back();
        Get.off(() => const SelectLanguageScreen());
      },
      textConfirm: 'पुनः प्रयास करें',
      textCancel: 'छोड़ें',
    );
  }

}
