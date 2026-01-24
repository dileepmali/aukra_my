import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_text.dart';
import '../../../controllers/deactivated_accounts_controller.dart';
import '../../../controllers/privacy_setting_controller.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../../../core/services/error_service.dart';
import '../../../core/untils/error_types.dart';
import '../../widgets/custom_app_bar/custom_app_bar.dart';
import '../../widgets/custom_app_bar/model/app_bar_config.dart';
import '../../widgets/list_item_widget.dart';

class DeactivatedAccountsScreen extends StatelessWidget {
  const DeactivatedAccountsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DeactivatedAccountsController());
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.overlay : AppColorsLight.scaffoldBackground,
      appBar: CustomResponsiveAppBar(
        config: AppBarConfig(
          type: AppBarType.titleOnly,
          showBorder: true,
          customHeight: responsive.hp(12),
          customPadding: EdgeInsets.symmetric(horizontal: responsive.wp(2)),
          leadingWidget: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.arrow_back,
                  color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                  size: responsive.iconSizeLarge,
                ),
              ),
              SizedBox(width: responsive.wp(3)),
              AppText.searchbar2(
                'Deactivated Accounts',
                color: isDark ? Colors.white : AppColorsLight.textPrimary,
                fontWeight: FontWeight.w500,
                maxLines: 1,
                minFontSize: 12,
                letterSpacing: 1.1,
              ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
              strokeWidth: 1.0,
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty && controller.deactivatedAccounts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.red500),
                SizedBox(height: responsive.hp(2)),
                AppText.headlineLarge1(
                  controller.errorMessage.value,
                  color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: responsive.hp(2)),
                TextButton(
                  onPressed: controller.refresh,
                  child: AppText.headlineLarge1(
                    'Retry',
                    color: AppColorsLight.splaceSecondary1,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
          backgroundColor: isDark ? AppColors.containerDark : AppColorsLight.white,
          onRefresh: controller.refresh,
          child: controller.deactivatedAccounts.isEmpty
              ? _buildEmptyState(responsive, isDark)
              : _buildAccountsList(context, controller, responsive, isDark),
        );
      }),
    );
  }

  Widget _buildEmptyState(AdvancedResponsiveHelper responsive, bool isDark) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: responsive.hp(25)),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AppIcons.boxIc,
                width: responsive.iconSizeExtraLarge * 2,
                height: responsive.iconSizeExtraLarge * 2,
                colorFilter: ColorFilter.mode(
                  isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(height: responsive.hp(3)),
              AppText.searchbar1(
                'No deactivated accounts',
                color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: responsive.hp(1)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.wp(10)),
                child: AppText.headlineLarge1(
                  'Accounts you deactivate will appear here. You can restore them anytime.',
                  color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountsList(
    BuildContext context,
    DeactivatedAccountsController controller,
    AdvancedResponsiveHelper responsive,
    bool isDark,
  ) {
    return Obx(() => ListView.builder(
      padding: EdgeInsets.only(top: responsive.wp(2)),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: controller.deactivatedAccounts.length,
      itemBuilder: (context, index) {
        final account = controller.deactivatedAccounts[index];
        final name = account.partyName;
        final phone = account.mobileNumber;
        final deactivatedDate = account.updatedAt != null
            ? DateFormat('dd MMM yyyy').format(account.updatedAt!)
            : 'Unknown';

        return ListItemWidget(
          title: name,
          subtitle: phone.isNotEmpty ? '+91-$phone' : account.partyType,
          showAvatar: false,
          customTrailing: GestureDetector(
            onTap: () async {
              // Use global PIN check - skips dialog if PIN is disabled
              final privacyController = Get.find<PrivacySettingController>();
              final pinResult = await privacyController.requirePinIfEnabled(
                context,
                title: 'Enter Security Pin to unblock',
                subtitle: 'Enter your 4-digit pin to activate "$name"',
                confirmButtonText: 'Confirm',
                confirmGradientColors: [AppColors.red500, AppColors.red500],
              );

              // null means cancelled or failed
              if (pinResult == null) return;

              // 'SKIP' means PIN is disabled, use empty string
              // Otherwise use the validated PIN
              final securityKey = pinResult == 'SKIP' ? '' : pinResult;

              final success = await controller.activateLedger(
                account.id,
                securityKey,
              );

              if (success) {
                // Show success message using AdvancedErrorService
                AdvancedErrorService.showSuccess(
                  '$name is activated',
                  type: SuccessType.snackbar,
                );
              } else {
                // Show error message using AdvancedErrorService
                AdvancedErrorService.showError(
                  controller.errorMessage.value.isNotEmpty
                      ? controller.errorMessage.value
                      : 'Failed to activate $name',
                  severity: ErrorSeverity.medium,
                  category: ErrorCategory.general,
                );
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText.headlineLarge(
                      'Activate',
                      color: AppColors.successPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.successPrimary,
                      size: responsive.iconSizeMedium,
                    ),
                  ],
                ),
                SizedBox(height: responsive.hp(0.3)),
                AppText.headlineMedium(
                  'Blocked: $deactivatedDate',
                  color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                ),
              ],
            ),
          ),
          showBorder: true,
          onTap: () {
            debugPrint('Deactivated account tapped: $name');
          },
        );
      },
    ));
  }
}