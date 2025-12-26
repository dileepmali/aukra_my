import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/services/error_service.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  final _storage = GetStorage();
  final _storageKey = 'app_theme_mode';

  // Observable theme mode
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;

  ThemeMode get themeMode => _themeMode.value;

  @override
  void onInit() {
    super.onInit();
    // Load saved theme preference
    _loadThemeFromStorage();
    // Set initial status bar style
    _updateStatusBarStyle(_themeMode.value);
  }

  // Load theme from storage
  void _loadThemeFromStorage() {
    try {
      final savedTheme = _storage.read(_storageKey);
      if (savedTheme != null) {
        switch (savedTheme) {
          case 'light':
            _themeMode.value = ThemeMode.light;
            break;
          case 'dark':
            _themeMode.value = ThemeMode.dark;
            break;
          case 'system':
          default:
            _themeMode.value = ThemeMode.system;
            break;
        }
      }
    } catch (e) {
      debugPrint('Error loading theme from storage: $e');
      _themeMode.value = ThemeMode.system;
    }
  }

  // Save theme to storage
  Future<void> _saveThemeToStorage(ThemeMode mode) async {
    try {
      String themeString = 'system';
      switch (mode) {
        case ThemeMode.light:
          themeString = 'light';
          break;
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.system:
        default:
          themeString = 'system';
          break;
      }
      await _storage.write(_storageKey, themeString);
    } catch (e) {
      debugPrint('Error saving theme to storage: $e');
    }
  }

  // Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    debugPrint('🎨 Setting theme mode to: $mode');
    _themeMode.value = mode;
    await _saveThemeToStorage(mode);

    // Update GetMaterialApp theme
    Get.changeThemeMode(mode);

    // Update status bar style based on theme
    _updateStatusBarStyle(mode);

    debugPrint('✅ Theme changed successfully to: $mode');
  }

  // Update status bar style based on theme mode
  // ✅ Android 15+ edge-to-edge compatible implementation
  void _updateStatusBarStyle(ThemeMode mode) {
    try {
      final isDark = mode == ThemeMode.dark ||
                     (mode == ThemeMode.system && Get.isPlatformDarkMode);

      // ✅ For edge-to-edge on Android 15+, we only set icon brightness
      // The statusBarColor and navigationBarColor are deprecated and ignored
      // The system bars are now transparent by default with enableEdgeToEdge()
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          // ✅ Only set icon/text colors, not bar background colors
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          // ⚠️ REMOVED: statusBarColor (deprecated in Android 15)
          // ⚠️ REMOVED: systemNavigationBarColor (deprecated in Android 15)
          // These are now controlled by enableEdgeToEdge() in MainActivity
        ),
      );

      debugPrint('✅ Status bar updated for ${isDark ? "dark" : "light"} theme (edge-to-edge compatible)');
    } catch (e) {
      debugPrint('❌ Error updating status bar: $e');
    }
  }

  // Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final isDark = Get.isDarkMode;
    await setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  // Set light theme
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }

  // Set dark theme
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }

  // Set system theme
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  // Check if current theme is dark
  bool get isDarkMode {
    if (_themeMode.value == ThemeMode.system) {
      return Get.isPlatformDarkMode;
    }
    return _themeMode.value == ThemeMode.dark;
  }

  // Get current theme name
  String get currentThemeName {
    switch (_themeMode.value) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
      default:
        return 'System';
    }
  }
}