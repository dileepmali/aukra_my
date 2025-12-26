// lib/bindings/number_binding.dart
import 'package:get/get.dart';

import '../../../controllers/verify_otp_controller.dart';

class NumberBinding extends Bindings {
  @override
  void dependencies() {
    // Use Get.put instead of lazyPut for immediate initialization
    // Also add OtpVerifyController if it's related
    Get.put<OtpVerifyController>(OtpVerifyController());
  }
}
