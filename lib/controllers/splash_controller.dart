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

    // Only initialize app if we're actually on the splash screen
    // This prevents auto-navigation when controller is created elsewhere
    if (Get.currentRoute == AppRoutes.splash || Get.currentRoute == '/') {
      initializeApp();
    }
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
      // await _checkAuthenticationAndNavigate(); // TODO: Uncomment after testing splash screen
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

      print('');
      print('🚀 ========== APP STARTUP - ROUTE DECISION ==========');

      // ✅ Step 1: Check if user is already logged in (token exists and valid)
      final bool isLoggedIn = await AuthStorage.isTokenValid();
      final String? token = await AuthStorage.getToken();
      print('📱 Step 1: Token Check');
      print('   Token exists: ${token != null}');
      print('   Token valid: $isLoggedIn');

      if (!isLoggedIn) {
        // ❌ User is NOT logged in - Navigate to Language/Number Verify Screen
        print('');
        print('❌ DECISION: User not logged in');
        print('   → Navigate to Language Screen');
        print('====================================================');
        print('');
        _navigateToLanguageScreen();
        return;
      }

      // ✅ User IS logged in - Check merchant status
      print('');
      print('✅ User logged in - Checking merchant details...');

      // ✅ Step 2: Check if merchant ID exists (primary check)
      final int? merchantId = await AuthStorage.getMerchantId();
      print('📱 Step 2: Merchant ID Check');
      print('   Merchant ID: $merchantId');

      // ✅ Step 3: Check shop details flag (backup check)
      final bool hasShopDetails = await AuthStorage.hasShopDetails();
      print('📱 Step 3: Shop Details Flag Check');
      print('   Has Shop Details: $hasShopDetails');
      print('');

      // ✅ DECISION LOGIC:
      // If BOTH merchantId exists AND shop details flag is true → Main Screen
      // If token exists BUT merchantId is null → Shop Detail Screen
      // Otherwise → Language Screen (safety fallback)

      if (merchantId != null && hasShopDetails) {
        // ✅ Merchant already created - Navigate to Main Screen
        print('✅ DECISION: Merchant exists (ID: $merchantId)');
        print('   → Navigate to Main Screen');
        print('   → SKIP Shop Detail Screen');
        print('====================================================');
        print('');
        _navigateToMainScreen();
      } else if (merchantId == null && !hasShopDetails) {
        // ❌ Merchant NOT created - Navigate to Shop Detail Screen
        print('⚠️ DECISION: Merchant does not exist');
        print('   → Navigate to Shop Detail Screen');
        print('   → User will fill merchant details');
        print('====================================================');
        print('');
        _navigateToShopDetailScreen();
      } else {
        // ⚠️ Edge case: Data inconsistency
        print('⚠️ WARNING: Data inconsistency detected!');
        print('   Shop Details Flag: $hasShopDetails');
        print('   Merchant ID: $merchantId');
        print('   → Navigate to Shop Detail Screen (safe fallback)');
        print('====================================================');
        print('');
        _navigateToShopDetailScreen();
      }

    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Navigation failed: $e';
      print('');
      print('❌ ERROR during navigation: $e');
      print('   → Fallback to Language Screen');
      print('====================================================');
      print('');
      // Navigate to language screen on error
      _navigateToLanguageScreen();
    }
  }

  void _navigateToShopDetailScreen() {
    if (isNavigating.value) return;

    isNavigating.value = true;

    try {
      // Navigate to Shop Detail Screen to complete merchant details
      Get.offAllNamed(AppRoutes.shopDetail);
    } catch (_) {
      isNavigating.value = false;
      // Fallback to language screen
      _navigateToLanguageScreen();
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
