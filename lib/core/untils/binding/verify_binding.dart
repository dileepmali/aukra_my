import 'package:get/get.dart';
import '../../../controllers/verify_otp_controller.dart';

class VerifyBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(OtpVerifyController());
  }
}
