import 'dart:io';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../../core/untils/binding/localization.dart';
import '../../core/untils/binding/number_binding.dart';
import '../../core/untils/binding/splash_binding.dart';
import '../../core/untils/binding/verify_binding.dart';
import '../auth/number_verify_screen.dart';
import '../auth/otp_verify_screen.dart';
import '../language/select_language_screen.dart';
import '../screens/splash_screen.dart';
import 'app_routes.dart';

final List<GetPage> getPages = [
  GetPage(
    name: AppRoutes.splash,
    page: () => const SplashScreen(),
    binding: SplashBinding(),
  ),
  // GetPage(
  //   name: AppRoutes.appEntryWrapper,
  //   page: () => const AppEntryWrapper(),
  // ),
  GetPage(
    name: AppRoutes.selectLanguage,
    page: () => const SelectLanguageScreen(),
    binding: LocalizationBinding(),
  ),
  GetPage(
    name: AppRoutes.numberVerify,
    page: () => const NumberVerifyScreen(),
    binding: NumberBinding(),
  ),
  GetPage(
    name: AppRoutes.otpVerify,
    page: () => const OtpVerifyScreen(),
    binding: VerifyBinding(),
  ),
  // GetPage(
  //   name: AppRoutes.main,
  //   page: () => const MainScreen(),
  //   binding: AppBarAndFolderBinding(),
  //   middlewares: [AuthMiddleware()],
  // ),

  


];

// Placeholder screen builder for future screens
