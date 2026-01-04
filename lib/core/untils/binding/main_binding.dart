import 'package:get/get.dart';
import '../../../controllers/ledger_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize LedgerController when MainScreen is loaded
    Get.lazyPut<LedgerController>(() => LedgerController(), fenix: true);
  }
}
