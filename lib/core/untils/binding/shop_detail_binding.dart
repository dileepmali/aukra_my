import 'package:get/get.dart';
import '../../../controllers/shop_detail_controller.dart';

class ShopDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ShopDetailController());
  }
}
