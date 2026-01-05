import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../../core/untils/binding/localization.dart';
import '../../core/untils/binding/number_binding.dart';
import '../../core/untils/binding/splash_binding.dart';
import '../../core/untils/binding/verify_binding.dart';
import '../../core/untils/binding/shop_detail_binding.dart';
import '../../core/untils/binding/main_binding.dart';
import '../../core/untils/binding/ledger_detail_binding.dart';
import '../../core/untils/binding/add_transaction_binding.dart';
import '../../core/untils/binding/ledger_dashboard_binding.dart';
import '../../core/middleware/protectRoutes.dart';
import '../auth/number_verify_screen.dart';
import '../auth/otp_verify_screen.dart';
import '../language/select_language_screen.dart';
import '../screens/shop_detail_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/main_screen.dart';
import '../screens/add_customer_screen.dart';
import '../screens/customer_form_screen.dart';
import '../screens/ledger_detail_screen.dart';
import '../screens/add_transaction_screen.dart';
import '../screens/ledger_dashboard_screen.dart';
import '../screens/customer_statement_screen.dart';
import '../screens/search_screen.dart';
import '../screens/change_number_screen.dart';
import '../screens/manage_businesses_screen.dart';
import '../screens/policy_terms_screen.dart';
import '../screens/about_us_screen.dart';
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
  GetPage(
    name: AppRoutes.shopDetail,
    page: () => const ShopDetailScreen(),
    binding: ShopDetailBinding(),
  ),
  GetPage(
    name: AppRoutes.main,
    page: () => const MainScreen(),
    binding: MainBinding(),
    middlewares: [AuthMiddleware()],
  ),
  GetPage(
    name: AppRoutes.addCustomer,
    preventDuplicates: false, // Allow navigation even if already on this route
    page: () {
      // Get partyType from arguments
      final args = Get.arguments as Map<String, dynamic>?;
      final partyType = args?['partyType'] as String?;

      print('📍 Route Generator - addCustomer page builder called');
      print('   Arguments received: $args');
      print('   PartyType extracted: $partyType');

      // Return new instance with key to force rebuild
      return AddCustomerScreen(
        key: ValueKey('addCustomer_${partyType ?? 'default'}_${DateTime.now().millisecondsSinceEpoch}'),
        partyType: partyType,
      );
    },
  ),
  GetPage(
    name: AppRoutes.customerForm,
    page: () => const CustomerFormScreen(),
  ),
  GetPage(
    name: AppRoutes.ledgerDetail,
    page: () => const LedgerDetailScreen(),
    binding: LedgerDetailBinding(),
  ),
  GetPage(
    name: AppRoutes.addTransaction,
    page: () => const AddTransactionScreen(),
    binding: AddTransactionBinding(),
  ),
  GetPage(
    name: AppRoutes.ledgerDashboard,
    page: () => const LedgerDashboardScreen(),
    binding: LedgerDashboardBinding(),
  ),
  GetPage(
    name: AppRoutes.customerStatement,
    page: () => const CustomerStatementScreen(),
  ),
  GetPage(
    name: AppRoutes.searchScreen,
    page: () => const SearchScreen(),
  ),
  GetPage(
    name: AppRoutes.changeNumber,
    page: () => const ChangeNumberScreen(),
  ),
  GetPage(
    name: AppRoutes.manageBusinesses,
    page: () => const ManageBusinessesScreen(),
    middlewares: [AuthMiddleware()],
  ),
  GetPage(
    name: AppRoutes.policyTerms,
    page: () => const PolicyTermsScreen(),
  ),
  GetPage(
    name: AppRoutes.aboutUs,
    page: () => const AboutUsScreen(),
  ),
];

// Placeholder screen builder for future screens