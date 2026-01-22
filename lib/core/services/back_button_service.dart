import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../presentations/mobile/auth/number_verify_screen.dart';
import '../../presentations/mobile/language/select_language_screen.dart';
import '../../presentations/widgets/dialogs/exit_confirmation_dialog.dart';
import '../untils/binding/localization.dart';
import '../untils/binding/number_binding.dart';

/// Centralized service for managing Android back button behavior across the app
class BackButtonService {
  static const String _tag = 'BackButtonService';
  
  // Navigation stack to track screen hierarchy
  static List<String> _navigationStack = [];
  static String _currentActiveScreen = '';
  
  // 🔒 THREAD SAFETY: Add mutex-like behavior for state management
  static bool _isUpdatingState = false;
  static Map<String, bool> _registeredInterceptors = {};
  static DateTime? _lastRegistrationTime;

  /// Register back button interceptor for a specific screen with improved reliability
  static Future<void> register({
    required String screenName,
    required VoidCallback onBackPressed,
    String? interceptorName,
    int priority = 0, // Higher priority interceptors execute first
  }) async {
    // 🔒 PREVENT RACE CONDITIONS: Block concurrent registrations
    if (_isUpdatingState) {
      debugPrint('⏳ [$_tag] Registration blocked - another registration in progress');
      await Future.delayed(Duration(milliseconds: 100));
      return register(
        screenName: screenName,
        onBackPressed: onBackPressed,
        interceptorName: interceptorName,
        priority: priority,
      );
    }

    _isUpdatingState = true;
    final name = interceptorName ?? '${screenName}_interceptor';
    
    try {
      // 🧹 CLEANUP: Remove existing interceptors to prevent duplicates
      if (_registeredInterceptors.containsKey(name)) {
        BackButtonInterceptor.removeByName(name);
        debugPrint('🗑️ [$_tag] Removed existing interceptor: $name');
      }
      
      // Priority system: Lower zIndex = Higher priority (executes first)
      int zIndex;
      if (screenName == 'ShareScreen' || screenName == 'ContactSearchScreen') {
        zIndex = 0; // Highest priority
      } else if (screenName.contains('GenericFolderScreen')) {
        zIndex = 1; // Medium priority
      } else if (screenName == 'MainScreen') {
        zIndex = 10; // Lowest priority
      } else {
        zIndex = 5; // Default priority
      }
      
      // 🚀 FAST INTERCEPTOR: Simplified logic for better performance
      BackButtonInterceptor.add(
        (stopDefaultButtonEvent, routeInfo) {
          try {
            // ⚡ QUICK CHECK: Skip if not the active screen
            if (screenName != _currentActiveScreen && 
                !_currentActiveScreen.contains(screenName) &&
                !(screenName == 'MainScreen' && _currentActiveScreen.startsWith('MainScreen'))) {
              return false;
            }
            
            // 🛡️ SAFETY CHECK: Ensure callback is still valid
            if (_registeredInterceptors[name] != true) {
              debugPrint('⚠️ [$_tag] Interceptor $name is no longer registered');
              return false;
            }
            
            // 🚦 EXECUTE CALLBACK
            debugPrint('✅ [$_tag] $screenName handling back button');
            onBackPressed();
            return true;
            
          } catch (e) {
            debugPrint('💥 [$_tag] Error in interceptor $name: $e');
            return false;
          }
        },
        name: name,
        zIndex: zIndex,
        context: Get.context,
      );
      
      // 📝 TRACK REGISTRATION
      _registeredInterceptors[name] = true;
      _lastRegistrationTime = DateTime.now();
      
      debugPrint('✅ [$_tag] Successfully registered: $name for $screenName (zIndex: $zIndex)');
      
    } catch (e) {
      debugPrint('💥 [$_tag] Failed to register interceptor $name: $e');
    } finally {
      _isUpdatingState = false;
    }
  }

  /// Remove back button interceptor with improved cleanup
  static void remove({String? interceptorName}) {
    if (interceptorName != null) {
      BackButtonInterceptor.removeByName(interceptorName);
      _registeredInterceptors.remove(interceptorName);
      debugPrint('🗑️ [$_tag] Removed interceptor: $interceptorName');
    } else {
      BackButtonInterceptor.removeAll();
      _registeredInterceptors.clear();
      debugPrint('🗑️ [$_tag] Removed all interceptors');
    }
  }

  /// Handle back button for Select Language Screen - Show exit dialog
  /// Handle back button for Select Language Screen - Show exit dialog
  static void handleSelectLanguageBack() {
    debugPrint('🔙 [$_tag] SelectLanguageScreen back button pressed');

    // ✅ Check if we just came from NumberVerifyScreen
    if (Get.isRegistered<bool>(tag: 'isNavigatingFromNumberVerify')) {
      debugPrint('⏭️ [$_tag] Skipping exit dialog because navigation is from NumberVerifyScreen');
      // Cleanup flag
      Get.delete<bool>(tag: 'isNavigatingFromNumberVerify');
      return;
    }

    debugPrint('🔙 [$_tag] Showing exit confirmation dialog');
    // Show exit confirmation dialog
    Get.dialog<bool>(
      const ExitConfirmationDialog(),
      barrierDismissible: false,
    ).then((shouldExit) {
      if (shouldExit == true) {
        debugPrint('✅ [$_tag] User confirmed exit - closing app');
        SystemNavigator.pop();
      } else {
        debugPrint('❌ [$_tag] User cancelled exit - staying in app');
      }
    });
  }

  /// Handle back button for Number Verify Screen - Go to Select Language
  static void handleNumberVerifyBack() {
    debugPrint('🔙 [$_tag] NumberVerifyScreen back button pressed - navigating to SelectLanguageScreen');

    // First remove current interceptor to prevent conflicts
    BackButtonInterceptor.removeByName('number_verify_interceptor');
    
    // Set a flag to indicate we're navigating back programmatically
    // This prevents the SelectLanguageScreen from immediately showing exit dialog
    Get.put<bool>(true, tag: 'isNavigatingFromNumberVerify');
    debugPrint('🚩 [$_tag] Set navigation flag: isNavigatingFromNumberVerify = true');

    // Use Get.off to replace current screen instead of stacking
    try {
      debugPrint('🔄 [$_tag] Using Get.off() to navigate to SelectLanguageScreen');
      Get.off(
        () => const SelectLanguageScreen(),
        binding: LocalizationBinding(),
      );
      debugPrint('✅ [$_tag] Successfully navigated to SelectLanguageScreen');
    } catch (e) {
      debugPrint('💥 [$_tag] Error in handleNumberVerifyBack: $e');
      // Emergency fallback
      debugPrint('🚨 [$_tag] Using emergency fallback - trying Get.back()');
      try {
        Get.back();
      } catch (fallbackError) {
        debugPrint('💥 [$_tag] Both Get.off() and Get.back() failed: $fallbackError');
      }
    }
    
    // Clean up the flag after navigation completes (increased delay for safety)
    Future.delayed(Duration(milliseconds: 1500), () {
      if (Get.isRegistered<bool>(tag: 'isNavigatingFromNumberVerify')) {
        Get.delete<bool>(tag: 'isNavigatingFromNumberVerify');
        debugPrint('🧹 [$_tag] Cleaned up navigation flag: isNavigatingFromNumberVerify');
      }
    });
  }



  /// Handle back button for OTP Verify Screen - Go to Number Verify
  static void handleOtpVerifyBack() {
    debugPrint('🔙 [$_tag] OtpVerifyScreen back button pressed - navigating to NumberVerifyScreen');
    
    // Always use Get.off() to ensure we go to NumberVerifyScreen
    // This prevents any navigation stack issues
    try {
      debugPrint('🔄 [$_tag] Using Get.off() to ensure clean navigation to NumberVerifyScreen');
      Get.off(
        () => NumberVerifyScreen(),
        binding: NumberBinding(),
      );
      debugPrint('✅ [$_tag] Successfully navigated to NumberVerifyScreen');
    } catch (e) {
      debugPrint('💥 [$_tag] Error in handleOtpVerifyBack: $e');
      // Emergency fallback
      debugPrint('🚨 [$_tag] Using emergency fallback - trying Get.back()');
      try {
        Get.back();
      } catch (fallbackError) {
        debugPrint('💥 [$_tag] Both Get.off() and Get.back() failed: $fallbackError');
      }
    }
  }

  /// Handle back button for Main Screen - Show exit dialog on Home tab double-tap, navigate on others
  static void handleMainScreenBack(
      int currentIndex,
      List<int> tabHistory,
      Function(int) onTabChange, {
      DateTime? lastBackPressed,
      Function(DateTime?)? onUpdateLastBackPressed,
      }) {
    debugPrint('🔙 [$_tag] MainScreen back - currentIndex: $currentIndex');
    debugPrint('📱 [$_tag] Current active screen in stack: $_currentActiveScreen');

    // Check if we're really on HomeScreen (tab 0) and not in any nested screen
    final isOnHomeTab = currentIndex == 0;
    final isHomeScreenActive = _currentActiveScreen.contains('HomeScreen');
    final hasNestedScreen = _currentActiveScreen.contains('ShareScreen') || 
                           _currentActiveScreen.contains('ContactScreen') ||
                           _currentActiveScreen.contains('GenericFolderScreen');
    
    if (isOnHomeTab && isHomeScreenActive && !hasNestedScreen) {
      // ✅ Home tab pe ho aur koi nested screen nahi hai → Double-tap detection for exit
      debugPrint('🏠 [$_tag] On Home tab with no nested screens - checking for double-tap');
      
      DateTime now = DateTime.now();
      
      if (lastBackPressed != null && 
          now.difference(lastBackPressed).inMilliseconds < 2000) {
        // ✅ Double-tap detected within 2 seconds → Show exit dialog
        debugPrint('🔄 [$_tag] Double-tap detected! Showing exit confirmation dialog');
        onUpdateLastBackPressed?.call(null); // Reset timer
        
        Get.dialog<bool>(
          const ExitConfirmationDialog(),
          barrierDismissible: false,
        ).then((shouldExit) {
          if (shouldExit == true) {
            debugPrint('✅ [$_tag] User confirmed exit - closing app');
            SystemNavigator.pop();
          } else {
            debugPrint('❌ [$_tag] User cancelled exit - staying in app');
          }
        });
      } else {
        // ✅ First tap → Show toast and start timer
        debugPrint('👆 [$_tag] First back press on Home - showing toast');
        onUpdateLastBackPressed?.call(now);
        
        // Show toast to user
        Get.showSnackbar(
          GetSnackBar(
            message: 'Press back again to exit',
            duration: Duration(seconds: 2),
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent,
            messageText: Text(
              'Press back again to exit',
              style: TextStyle(color: Colors.white),
            ),
            margin: EdgeInsets.all(16),
            borderRadius: 8,
          ),
        );
      }
    } else {
      // ✅ Agar kisi aur tab par ho → Exit dialog NAHI, sirf tab switch
      if (tabHistory.isNotEmpty) {
        int previousTab = tabHistory.removeLast();
        debugPrint('🔙 [$_tag] Going back to previous tab: $previousTab (history: $tabHistory)');
        onTabChange(previousTab);
      } else {
        // ❌ Agar history khali hai → direct Home tab pe bhej do
        debugPrint('📂 [$_tag] No history - switching to Home tab');
        onTabChange(0);
      }
    }
  }

  /// Handle back button for any other screen - Default navigation (NO EXIT DIALOG)
  static void handleDefaultBack() {
    debugPrint('🔙 [$_tag] Default back pressed');

    try {
      if (Get.previousRoute.isNotEmpty) {
        // ✅ Agar koi previous route hai to usi par wapas jao
        debugPrint('⬅️ [$_tag] Navigating back to previous route: ${Get.previousRoute}');
        Get.back();
      } else {
        // ❌ Agar koi previous route hi nahi hai → Simple navigation back (NO EXIT DIALOG)
        debugPrint('⚠️ [$_tag] No previous route found - attempting simple back navigation');
        Get.back();
      }
    } catch (e) {
      debugPrint('💥 [$_tag] Error in handleDefaultBack: $e');
      try {
        Get.back();
      } catch (fallbackError) {
        debugPrint('💥 [$_tag] Fallback Get.back() also failed: $fallbackError');
        // Even in error case, do NOT show exit dialog from other screens
        debugPrint('🚫 [$_tag] Not showing exit dialog from non-MainScreen');
      }
    }
  }

  /// Register interceptor with automatic cleanup
  static void registerWithCleanup({
    required String screenName,
    required VoidCallback onBackPressed,
    String? interceptorName,
    int priority = 0,
  }) {
    final name = interceptorName ?? '${screenName}_interceptor';
    
    debugPrint('🔧 [$_tag] registerWithCleanup called for $screenName with interceptor: $name, priority: $priority');
    
    // Remove any existing interceptors for this screen first
    BackButtonInterceptor.removeByName(name);
    
    // Additional cleanup for SelectLanguageScreen to prevent conflicts
    if (screenName == 'SelectLanguageScreen') {
      debugPrint('🧹 [$_tag] Extra cleanup for SelectLanguageScreen - removing potential conflicting interceptors');
      BackButtonInterceptor.removeByName('otp_verify_interceptor');
      BackButtonInterceptor.removeByName('number_verify_interceptor');
    }
    
    // Register new interceptor with priority
    register(
      screenName: screenName,
      onBackPressed: onBackPressed,
      interceptorName: name,
      priority: priority, // Pass priority to register method
    );
  }

  /// Check if any interceptors are currently registered
  static bool get hasInterceptors {
    // This is a simple check - back_button_interceptor doesn't provide direct access
    // to check active interceptors, but we can track this if needed
    return true; // Placeholder - implement based on your needs
  }

  /// Emergency cleanup - remove all interceptors with improved state management
  static void emergencyCleanup() {
    debugPrint('🚨 [$_tag] Emergency cleanup - removing all interceptors');
    _isUpdatingState = true;
    
    try {
      BackButtonInterceptor.removeAll();
      _registeredInterceptors.clear();
      _navigationStack.clear();
      _currentActiveScreen = '';
      _lastRegistrationTime = null;
      
      // Clear any lingering references
      Future.delayed(Duration(milliseconds: 100), () {
        debugPrint('🧹 [$_tag] Cleanup references completed');
      });
      
      debugPrint('✅ [$_tag] Emergency cleanup completed');
    } catch (e) {
      debugPrint('💥 [$_tag] Error during emergency cleanup: $e');
    } finally {
      _isUpdatingState = false;
    }
  }
  
  /// Add screen to navigation stack
  static void pushScreen(String screenName) {
    if (_currentActiveScreen.isNotEmpty) {
      _navigationStack.add(_currentActiveScreen);
    }
    _currentActiveScreen = screenName;
    debugPrint('📱 [$_tag] Navigation Stack: ${_navigationStack} -> $_currentActiveScreen');
  }
  
  /// Remove screen from navigation stack
  static String? popScreen() {
    if (_navigationStack.isNotEmpty) {
      final previousScreen = _currentActiveScreen;
      _currentActiveScreen = _navigationStack.removeLast();
      debugPrint('📱 [$_tag] Navigation Stack: ${_navigationStack} <- $_currentActiveScreen (removed: $previousScreen)');
      return _currentActiveScreen;
    } else {
      debugPrint('📱 [$_tag] Navigation Stack is empty, clearing current screen');
      _currentActiveScreen = '';
      return null;
    }
  }
  
  /// Get current active screen
  static String get currentActiveScreen => _currentActiveScreen;
  
  /// Get navigation stack info
  static String get navigationStackInfo => 'Stack: $_navigationStack -> $_currentActiveScreen';

  /// 🔥 RELIABLE REGISTRATION: Use this method for guaranteed back button handling
  static Future<bool> safeRegister({
    required String screenName,
    required VoidCallback onBackPressed,
    String? interceptorName,
    int priority = 0,
    int maxRetries = 3,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('🔄 [$_tag] Safe registration attempt $attempt/$maxRetries for $screenName');
        
        await register(
          screenName: screenName,
          onBackPressed: onBackPressed,
          interceptorName: interceptorName,
          priority: priority,
        );
        
        // Verify registration was successful
        final name = interceptorName ?? '${screenName}_interceptor';
        if (_registeredInterceptors[name] == true) {
          debugPrint('✅ [$_tag] Safe registration successful for $screenName on attempt $attempt');
          return true;
        }
        
        debugPrint('⚠️ [$_tag] Registration verification failed for $screenName on attempt $attempt');
        await Future.delayed(Duration(milliseconds: 50 * attempt));
        
      } catch (e) {
        debugPrint('💥 [$_tag] Safe registration error on attempt $attempt: $e');
        if (attempt < maxRetries) {
          await Future.delayed(Duration(milliseconds: 100 * attempt));
        }
      }
    }
    
    debugPrint('❌ [$_tag] Safe registration failed after $maxRetries attempts for $screenName');
    return false;
  }

  /// 🛡️ HEALTH CHECK: Verify service is working correctly
  static Map<String, dynamic> getHealthStatus() {
    return {
      'isUpdatingState': _isUpdatingState,
      'registeredInterceptorsCount': _registeredInterceptors.length,
      'currentActiveScreen': _currentActiveScreen,
      'navigationStackSize': _navigationStack.length,
      'lastRegistrationTime': _lastRegistrationTime?.toIso8601String(),
      'registeredInterceptors': _registeredInterceptors.keys.toList(),
    };
  }
}