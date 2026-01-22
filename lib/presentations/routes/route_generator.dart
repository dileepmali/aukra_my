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
import '../mobile/auth/number_verify_screen.dart';
import '../mobile/auth/otp_verify_screen.dart';
import '../mobile/language/select_language_screen.dart';
import '../mobile/screens/about_us_screen.dart';
import '../mobile/screens/add_customer_screen.dart';
import '../mobile/screens/add_transaction_screen.dart';
import '../mobile/screens/change_number_screen.dart';
import '../mobile/screens/customer_form_screen.dart';
import '../mobile/screens/customer_statement_screen.dart';
import '../mobile/screens/deactivated_accounts_screen.dart';
import '../mobile/screens/ledger_dashboard_screen.dart';
import '../mobile/screens/ledger_detail_screen.dart';
import '../mobile/screens/main_screen.dart';
import '../mobile/screens/manage_businesses_screen.dart';
import '../mobile/screens/my_plan_screen.dart';
import '../mobile/screens/payment_screen.dart';
import '../mobile/screens/policy_terms_screen.dart';
import '../mobile/screens/search_screen.dart';
import '../mobile/screens/shop_detail_screen.dart';
import '../mobile/screens/splash_screen.dart';
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
    // Note: AuthMiddleware removed - splash already validates token
    // Biometric/PIN check handled by PrivacySettingController when needed
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
  GetPage(
    name: AppRoutes.myPlan,
    page: () => const MyPlanScreen(),
  ),
  GetPage(
    name: AppRoutes.payment,
    page: () {
      final args = Get.arguments as Map<String, dynamic>?;
      return PaymentScreen(
        planName: args?['planName'] ?? '',
        planPrice: args?['planPrice'] ?? '',
        planDuration: args?['planDuration'] ?? '',
      );
    },
  ),
  GetPage(
    name: AppRoutes.deactivatedAccounts,
    page: () => const DeactivatedAccountsScreen(),
  ),
];

// Placeholder screen builder for future screens