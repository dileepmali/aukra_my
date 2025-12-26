// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:sizer/sizer.dart';
//
// import '../core/utils/binding/splash_binding.dart';
// import '../controllers/localization_controller.dart';
// import '../controllers/theme_controller.dart';
// import '../presentation/screens/splash_screen.dart';
// import '../presentation/routes/route_generator.dart';
// import 'localizations/l10n/app_localizations.dart';
// import 'themes/app_themes.dart';
//
// /// Main application widget
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
//   @override
//   void initState() {
//     super.initState();
//
//     // Initialize SplashBinding for direct splash screen access
//     SplashBinding().dependencies();
//
//     // Log when widget is ready
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       debugPrint('MyApp widget ready, services already initialized');
//     });
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Sizer(
//       builder: (context, orientation, deviceType) {
//         return Obx(() {
//           // Ensure LocalizationController is registered
//           if (!Get.isRegistered<LocalizationController>()) {
//             debugPrint('LocalizationController not found, registering now...');
//             Get.put<LocalizationController>(
//               LocalizationController(),
//               permanent: true,
//             );
//           }
//
//           final localizationController = Get.find<LocalizationController>();
//
//           // Ensure ThemeController is registered
//           if (!Get.isRegistered<ThemeController>()) {
//             debugPrint('ThemeController not found, registering now...');
//             Get.put<ThemeController>(
//               ThemeController(),
//               permanent: true,
//             );
//           }
//
//           final themeController = Get.find<ThemeController>();
//
//           return GetMaterialApp(
//             title: 'AnantSpace',
//             debugShowCheckedModeBanner: false,
//             enableLog: false, // Disable GetX logs for faster performance
//             defaultTransition: Transition.noTransition, // No transition for faster navigation
//             transitionDuration: Duration.zero, // Zero transition duration
//             popGesture: true, // Enable iOS-style back swipe
//             locale: localizationController.currentLocale.value,
//             fallbackLocale: const Locale('en'),
//             localizationsDelegates: AppLocalizations.localizationsDelegates,
//             supportedLocales: AppLocalizations.supportedLocales,
//             unknownRoute: GetPage(
//               name: '/not-found',
//               page: () => const SplashScreen(),
//             ),
//             theme: AppThemes.lightTheme,
//             darkTheme: AppThemes.darkTheme,
//             themeMode: themeController.themeMode,
//             home: const SplashScreen(), // Instant splash screen
//             getPages: getPages,
//           );
//         });
//       },
//     );
//   }
// }