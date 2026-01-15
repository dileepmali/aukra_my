import 'package:aukra_anantkaya_space/app/constants/app_icons.dart';
import 'package:aukra_anantkaya_space/core/responsive_layout/helper_class_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_text.dart';
import '../../../buttons/app_button.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../../controllers/qr_code_controller.dart';
import '../../screens/payment_success_screen.dart';
import '../../screens/payment_error_screen.dart';
import '../custom_single_border_color.dart';

class PaymentQRBottomSheet extends StatefulWidget {
  final String planName;
  final String planPrice;
  final String planDuration;

  const PaymentQRBottomSheet({
    super.key,
    required this.planName,
    required this.planPrice,
    required this.planDuration,
  });

  static void show(
    BuildContext context, {
    required String planName,
    required String planPrice,
    required String planDuration,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentQRBottomSheet(
        planName: planName,
        planPrice: planPrice,
        planDuration: planDuration,
      ),
    );
  }

  @override
  State<PaymentQRBottomSheet> createState() => _PaymentQRBottomSheetState();
}

class _PaymentQRBottomSheetState extends State<PaymentQRBottomSheet> {
  late final QrCodeController _qrCodeController;

  @override
  void initState() {
    super.initState();
    // Initialize controller
    _qrCodeController = Get.put(QrCodeController());

    // Generate QR code on init
    _qrCodeController.generateQrCode(
      amount: widget.planPrice,
      planName: widget.planName,
      planDuration: widget.planDuration,
    );
  }

  @override
  void dispose() {
    // Clean up controller
    _qrCodeController.clearData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: responsive.hp(65),
      decoration: BoxDecoration(
        color: isDark ? AppColors.containerLight : AppColorsLight.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(responsive.borderRadiusExtraLarge1),
          topRight: Radius.circular(responsive.borderRadiusExtraLarge1),
        ),
      ),
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                // Drag handle
                Container(
                  margin: EdgeInsets.only(top: responsive.hp(1.5)),
                  width: responsive.wp(20),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: responsive.hp(2)),

                // Title and Subtitle
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: responsive.wp(5)),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Title
                        AppText.searchbar2(
                          'Scan QR to make payment',
                          color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(height: responsive.hp(0.5)),
                        // Subtitle
                        AppText.bodyLarge(
                          'You can pay scanning the QR code or clicking payment option below.',
                          color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                          textAlign: TextAlign.start,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: responsive.hp(2)),

                // Divider Line
                Container(
                  height: 1,
                  color: isDark ? AppColors.driver : AppColorsLight.textSecondary.withValues(alpha: 0.3),
                ),
                SizedBox(height: responsive.hp(3)),

                // QR Code Container
                Container(
                  width: responsive.wp(65),
                  height: responsive.wp(70),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                  ),
                  child: _buildQRCodeWidget(responsive),
                ),
              ],
            ),
            bottomNavigationBar: SafeArea(
              child: Stack(
                children: [Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.wp(5),
                    vertical: responsive.hp(2),
                  ),
                  color: Colors.transparent,
                  child: AppButton(
                    leadingIcon: Icons.arrow_back,
                    text: 'Pay ₹${widget.planPrice}',
                    width: double.infinity,
                    height: responsive.hp(6),
                    borderColor: isDark ? AppColors.driver : AppColorsLight.gradientColor1,
                    gradientColors: isDark
                        ? [AppColors.containerLight, AppColors.containerDark]
                        : [AppColorsLight.gradientColor1, AppColorsLight.gradientColor2],
                    textColor: Colors.white,
                    fontSize: responsive.fontSize(16),
                    fontWeight: FontWeight.w600,
                    borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                    onPressed: () => _processPayment(context),
                  ),
                ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomSingleBorderWidget(
                        position: BorderPosition.top,
                        borderWidth: isDark ? 1.0 : 2.0,
                      ),
                    ),
                  ),]
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomSingleBorderWidget(
                position: BorderPosition.top,
                borderWidth: isDark ? 1.0 : 2.0,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Process payment and navigate to success/error screen
  Future<void> _processPayment(BuildContext context) async {
    debugPrint('💰 Processing payment...');

    // Store values before closing bottom sheet
    final planName = widget.planName;
    final planPrice = widget.planPrice;
    final planDuration = widget.planDuration;
    final transactionId = _qrCodeController.transactionId ?? 'TXN${DateTime.now().millisecondsSinceEpoch}';

    // Close the bottom sheet first
    Get.back();

    // Verify payment (dummy implementation)
    // TODO: Set to true for success screen, false for error screen testing
    final isSuccess = false; // Changed to false to test error screen

    if (isSuccess) {
      // Navigate to success screen using GetX
      Get.off(() => PaymentSuccessScreen(
        planName: planName,
        planPrice: planPrice,
        planDuration: planDuration,
        transactionId: transactionId,
      ));
    } else {
      // Navigate to error screen using GetX
      Get.off(() => PaymentErrorScreen(
        planName: planName,
        planPrice: planPrice,
        errorMessage: 'Payment could not be completed. Please try again.',
      ));
    }
  }

  /// Build QR Code Widget with loading and error states
  Widget _buildQRCodeWidget(AdvancedResponsiveHelper responsive) {
    return Obx(() {
      // Show loading state
      if (_qrCodeController.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            color: AppColorsLight.gradientColor1,
          ),
        );
      }

      // Show error state
      if (_qrCodeController.hasError.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: responsive.wp(20),
                color: Colors.red,
              ),
              SizedBox(height: responsive.hp(1)),
              Text(
                _qrCodeController.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: responsive.fontSize(12),
                ),
              ),
              SizedBox(height: responsive.hp(2)),
              // Retry button
              GestureDetector(
                onTap: () => _qrCodeController.refreshQrCode(),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.wp(4),
                    vertical: responsive.hp(1),
                  ),
                  decoration: BoxDecoration(
                    color: AppColorsLight.gradientColor1,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // Show QR code
      if (_qrCodeController.hasQrCode) {
        return Image.network(
          _qrCodeController.qrCodeUrl!,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColorsLight.gradientColor1,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code,
                    size: responsive.wp(30),
                    color: AppColorsLight.textSecondary,
                  ),
                  SizedBox(height: responsive.hp(1)),
                  Text(
                    'Failed to load QR',
                    style: TextStyle(
                      color: AppColorsLight.textSecondary,
                      fontSize: responsive.fontSize(12),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }

      // Default placeholder
      return Icon(
        Icons.qr_code,
        size: responsive.wp(40),
        color: AppColorsLight.textPrimary,
      );
    });
  }
}