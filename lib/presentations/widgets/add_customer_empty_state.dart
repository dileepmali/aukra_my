import 'package:aukra_anantkaya_space/app/constants/app_images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_text.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/responsive_layout/padding_navigation.dart';
import '../routes/app_routes.dart';
import '../../buttons/app_button.dart';

class AddCustomerEmptyState extends StatelessWidget {
  final String searchQuery;

  const AddCustomerEmptyState({
    Key? key,
    required this.searchQuery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final responsive = AdvancedResponsiveHelper(context);

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: responsive.hp(50),
          minHeight: responsive.hp(40),
          maxWidth: responsive.hp(95),
          minWidth: responsive.hp(85),
        ),
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: responsive.wp(4),
            vertical: responsive.hp(1.5),
          ),
          padding: EdgeInsets.all(responsive.wp(4)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.containerDark, AppColors.containerDark]
                  : [AppColorsLight.gradientColor1, AppColorsLight.gradientColor2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Image Container
            Container(
              width: double.infinity,
              height: responsive.hp(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                child: Image.asset(
                  AppImages.addCustomerIm,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            SizedBox(height: responsive.hp(1.5)),

            // Heading
            Align(
              alignment: Alignment.center,
              child: AppText.displayMedium2(
                '"$searchQuery" is not found in your contact list',
                color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
            SizedBox(height: responsive.hp(1)),

            // Description
            Align(
              alignment: Alignment.center,
              child: AppText.headlineLarge(
                'Check the name or click below to create a new customer',
                color: isDark
                    ? AppColors.white.withOpacity(0.7)
                    : AppColorsLight.textSecondary,
                fontWeight: FontWeight.w400,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
            SizedBox(height: responsive.hp(3)),

            // Button
            AppButton(
              text: 'Add Customer',
              onPressed: () {
                Get.toNamed(
                  AppRoutes.customerForm,
                  arguments: {
                    'contactName': '',
                    'contactPhone': searchQuery,
                  },
                );
              },
              gradientColors: [
                AppColors.splaceSecondary1,
                AppColors.splaceSecondary2,
              ],
              textColor: Colors.white,
              fontSize: responsive.fontSize(18),
              fontWeight: FontWeight.w600,
              iconSize: responsive.iconSizeSmall,
              padding: EdgeInsets.symmetric(
                horizontal: responsive.wp(6),
                vertical: responsive.hp(1.9),
              ),
              borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
              width: double.infinity,
            ),
            ],
          ),
        ),
      ),
    );
  }
}
