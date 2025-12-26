
import 'package:get/get.dart';

import '../../../controllers/splash_controller.dart';
import '../../services/auth_service.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Register AuthService as a global service (must be registered first)
    Get.put<AuthService>(
      AuthService(),
      permanent: true, // Keep service alive throughout app lifecycle
    );

    // SplashController को properly bind करें
    Get.lazyPut<SplashController>(
          () => SplashController(),
      fenix: true, // Controller को memory में रखने के लिए
    );

    // Register BackgroundUploadService as a global service
  }
}