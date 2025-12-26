// lib/bindings/localization_binding.dart
import 'package:get/get.dart';

import '../../../controllers/localization_controller.dart';

class LocalizationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocalizationController>(() => LocalizationController());
  }
}
