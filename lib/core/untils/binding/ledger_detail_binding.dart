import 'package:get/get.dart';
import '../../../controllers/ledger_detail_controller.dart';

class LedgerDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<LedgerDetailController>(LedgerDetailController());
  }
}
