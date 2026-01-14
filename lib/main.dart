import 'dart:async';
import 'package:aukra_anantkaya_space/presentations/routes/app_routes.dart';
import 'package:aukra_anantkaya_space/presentations/routes/route_generator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';

import 'app/localizations/l10n/app_localizations.dart';
import 'app/themes/app_themes.dart';
import 'controllers/localization_controller.dart';
import 'controllers/theme_controller.dart';
import 'core/services/contact_cache_service.dart';
import 'core/services/device_info_service.dart';
import 'core/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⚡ CRITICAL ONLY: Minimal blocking initialization
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔔 Register FCM background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // ⚡ Controllers MUST be registered before runApp (synchronous, fast)
  Get.put(LocalizationController(), permanent: true);
  Get.put(ThemeController(), permanent: true);

  // 🚀 RUN APP IMMEDIATELY - Don't block on heavy services
  runApp(const MyApp());

  // ⚡ BACKGROUND SERVICES: Initialize after app is running
  // These run in background while splash screen is visible
  unawaited(_initializeBackgroundServices());
}

/// Initialize non-critical services in background
/// This runs AFTER runApp() so splash screen is already visible
Future<void> _initializeBackgroundServices() async {
  // Initialize GetStorage (fast, but non-blocking)
  await GetStorage.init();

  // Initialize device info for API headers (real device name, ID, etc.)
  await DeviceInfoService.init();

  // Initialize Hive for contact caching
  await ContactCacheService.init();

  // Initialize FCM for push notifications
  await FcmService.init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    // Get controllers
    final localizationController = Get.find<LocalizationController>();
    final themeController = Get.find<ThemeController>();

    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          enableLog: true, // Enable GetX logs to debug
          defaultTransition: Transition.noTransition, // Default transition
          popGesture: true, // Enable iOS-style back swipe
          locale: localizationController.currentLocale.value,
          fallbackLocale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeController.themeMode,
          initialRoute: AppRoutes.splash, // Use initialRoute to trigger binding
          getPages: getPages,
        );
      },
    );
  }
}

