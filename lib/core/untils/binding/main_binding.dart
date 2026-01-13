import 'package:get/get.dart';
import '../../../controllers/ledger_controller.dart';
import '../../../controllers/privacy_setting_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize LedgerController when MainScreen is loaded
    Get.lazyPut<LedgerController>(() => LedgerController(), fenix: true);

    // Initialize PrivacySettingController globally (permanent)
    // This controller manages security PIN state across the entire app
    // It loads privacy settings from API to check if PIN is enabled
    if (!Get.isRegistered<PrivacySettingController>()) {
      Get.put<PrivacySettingController>(
        PrivacySettingController(),
        permanent: true,
      );
    }
  }
}
