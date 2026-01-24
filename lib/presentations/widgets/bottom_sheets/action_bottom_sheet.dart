import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_text.dart';
import '../../../controllers/privacy_setting_controller.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../custom_single_border_color.dart';

class ActionBottomSheet extends StatelessWidget {
  final String? partyName;
  final VoidCallback? onReminder;
  final VoidCallback? onCall;
  final VoidCallback? onWhatsappReminder;
  final Function(String pin)? onDeactivateConfirmed;

  const ActionBottomSheet({
    Key? key,
    this.partyName,
    this.onReminder,
    this.onCall,
    this.onWhatsappReminder,
    this.onDeactivateConfirmed,
  }) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    String? partyName,
    VoidCallback? onReminder,
    VoidCallback? onCall,
    VoidCallback? onWhatsappReminder,
    Function(String pin)? onDeactivateConfirmed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.black : AppColorsLight.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ActionBottomSheet(
        partyName: partyName,
        onReminder: onReminder,
        onCall: onCall,
        onWhatsappReminder: onWhatsappReminder,
        onDeactivateConfirmed: onDeactivateConfirmed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final responsive = AdvancedResponsiveHelper(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final bottomSheetHeight = responsive.hp(28) + bottomPadding;

    return Stack(
      children: [
        Container(
          height: bottomSheetHeight,
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF262626) : AppColorsLight.scaffoldBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            bottom: true,
            child: Column(
              children: [
                // Top spacing
                SizedBox(height: responsive.hp(1.5)),

                // Drag handle
                Center(
                  child: Container(
                    width: responsive.wp(20),
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.white
                          : AppColorsLight.textPrimary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(responsive.borderRadiusMedium),
                    ),
                  ),
                ),

                SizedBox(height: responsive.hp(2)),

                // "Action" title at top left
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: responsive.wp(4)),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AppText.searchbar2(
                      'Action',
                      color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                    ),
                  ),
                ),

                SizedBox(height: responsive.hp(1.5)),

                // 2x2 Grid of options
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: responsive.wp(4)),
                    child: Column(
                      children: [
                        // Row 1: Reminder | Call
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildActionOption(
                                  context,
                                  responsive,
                                  AppIcons.notificationIc,
                                  'Reminder',
                                  () {
                                    Navigator.of(context).pop();
                                    onReminder?.call();
                                  },
                                ),
                              ),
                              SizedBox(width: responsive.wp(3)),
                              Expanded(
                                child: _buildActionOption(
                                  context,
                                  responsive,
                                  AppIcons.callIc,
                                  'Call',
                                  () {
                                    Navigator.of(context).pop();
                                    onCall?.call();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: responsive.hp(1.5)),

                        // Row 2: Whatsapp reminder | Deactivate
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildActionOption(
                                  context,
                                  responsive,
                                  AppIcons.whatsappIc,
                                  'Whatsapp reminder',
                                  () {
                                    Navigator.of(context).pop();
                                    onWhatsappReminder?.call();
                                  },
                                ),
                              ),
                              SizedBox(width: responsive.wp(3)),
                              Expanded(
                                child: _buildActionOption(
                                  context,
                                  responsive,
                                  AppIcons.reminderIc,
                                  'Deactivate',
                                  () async {
                                    Navigator.of(context).pop();
                                    // Use global PIN check - skips dialog if PIN is disabled
                                    final privacyController = Get.find<PrivacySettingController>();
                                    final pinResult = await privacyController.requirePinIfEnabled(
                                      context,
                                      title: 'Enter Security Pin to block',
                                      subtitle: 'Enter your 4-digit pin to deactivate "${partyName ?? "this account"}"',
                                      confirmButtonText: 'Confirm',
                                      confirmGradientColors: [AppColors.red500, AppColors.red500],
                                    );

                                    // null means cancelled or failed
                                    if (pinResult == null) return;

                                    // 'SKIP' means PIN is disabled, use empty string
                                    // Otherwise use the validated PIN
                                    final securityKey = pinResult == 'SKIP' ? '' : pinResult;
                                    onDeactivateConfirmed?.call(securityKey);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: responsive.hp(1)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Border widget
        Positioned.fill(
          child: CustomSingleBorderWidget(
            position: BorderPosition.top,
            borderWidth: isDark ? 1.0 : 2.0,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionOption(
    BuildContext context,
    AdvancedResponsiveHelper responsive,
    String svgIcon,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final iconColor = isDestructive
        ? AppColors.red500
        : (isDark ? AppColors.white : AppColorsLight.textPrimary);

    final textColor = isDestructive
        ? AppColors.red500
        : (isDark ? AppColors.white : AppColorsLight.textPrimary);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  colors: [AppColors.containerLight, AppColors.containerLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [AppColorsLight.white, AppColorsLight.container],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
          border: Border.all(
            color: isDark ? AppColors.driver : AppColorsLight.border,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgIcon,
              width: responsive.iconSizeLarge,
              height: responsive.iconSizeLarge,
              colorFilter: ColorFilter.mode(
                iconColor,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(height: responsive.hp(1)),
            AppText.headlineLarge1(
              label,
              color: textColor,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
