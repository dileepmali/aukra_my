import 'package:get/get.dart';
import '../../../controllers/ledger_dashboard_controller.dart';

class LedgerDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LedgerDashboardController>(
      () => LedgerDashboardController(),
    );
  }
}
