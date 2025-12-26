import 'package:get/get.dart';
import '../../../controllers/tolgee_language_controller.dart';
class TolgeeBinding extends Bindings {
  @override
  void dependencies() {
    // Register TolgeeLanguageController
    Get.lazyPut<TolgeeLanguageController>(
      () => TolgeeLanguageController(),
      fenix: true,
    );
  }
}