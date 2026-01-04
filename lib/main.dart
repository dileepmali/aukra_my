import 'package:aukra_anantkaya_space/presentations/routes/app_routes.dart';
import 'package:aukra_anantkaya_space/presentations/routes/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/localizations/l10n/app_localizations.dart';
import 'app/themes/app_themes.dart';
import 'controllers/localization_controller.dart';
import 'controllers/theme_controller.dart';
import 'core/services/contact_cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dotenv (load .env file)
  await dotenv.load(fileName: ".env");

  // Initialize GetStorage
  await GetStorage.init();

  // ✅ Initialize Hive for contact caching (ULTRA FAST subsequent loads)
  await ContactCacheService.init();

  // Initialize controllers
  Get.put(LocalizationController(), permanent: true);
  Get.put(ThemeController(), permanent: true);

  runApp(const MyApp());
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

