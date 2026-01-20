class AppRoutes {
  // Auth & Setup Routes
  static const String splash = '/';
  static const String appEntryWrapper = '/app-entry-wrapper';
  static const String selectLanguage = '/select-language';
  static const String numberVerify = '/number-verify';
  static const String otpVerify = '/otp-verify';
  static const String shopDetail = '/shop-detail';

  // Main App Routes
  static const String main = '/main';
  static const String home = '/home';
  static const String folder = '/folder';
  static const String genericFolder = '/generic-folder/:folderId';
  static const String activities = '/activities';
  static const String settings = '/settings';
  static const String editProfile = '/edit-profile';
  static const String contactSearch = '/contact-search';
  static const String share = '/share';
  static const String publicScreen = '/publicScreen';
  static const String recycleBin = '/recycle-bin';
  static const String securitySettings = '/security-settings';
  static const String policyTerms = '/policy-terms';
  static const String aboutUs = '/about-us';
  static const String shareFile = '/share-file/:shareId';
  static const String shareDemo = '/share-demo/:shareId';
  static const String fileSharePreview = '/file-share-preview';
  static const String searchScreen = '/search-screen'; // 🔍 NEW: Dedicated search screen
  static const String changeNumber = '/change-number'; // 📱 NEW: Change merchant number screen
  static const String manageBusinesses = '/manage-businesses'; // 🏢 NEW: Manage businesses screen
  static const String addCustomer = '/add-customer';
  static const String customerForm = '/customer-form';
  static const String ledgerDetail = '/ledger-detail';
  static const String addTransaction = '/add-transaction';
  static const String ledgerDashboard = '/ledger-dashboard';
  static const String customerStatement = '/customer-statement';
  static const String myPlan = '/my-plan'; // 📋 NEW: My Plan screen
  static const String payment = '/payment'; // 💳 NEW: Payment screen
  static const String deactivatedAccounts = '/deactivated-accounts'; // 📦 NEW: Deactivated accounts screen
}