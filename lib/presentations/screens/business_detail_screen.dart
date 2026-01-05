import 'package:flutter/material.dart';
import '../../app/constants/app_icons.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_text.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/responsive_layout/padding_navigation.dart';
import '../widgets/custom_app_bar/custom_app_bar.dart';
import '../widgets/custom_app_bar/model/app_bar_config.dart';
import '../widgets/list_item_widget.dart';

class BusinessDetailScreen extends StatelessWidget {
  final int merchantId;
  final String businessName;

  const BusinessDetailScreen({
    super.key,
    required this.merchantId,
    required this.businessName,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.overlay : AppColorsLight.scaffoldBackground,
      appBar: CustomResponsiveAppBar(
        config: AppBarConfig(
          type: AppBarType.titleOnly,
          titleColor: isDark ? Colors.white : AppColorsLight.textPrimary,
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
              AppText.custom(
                businessName,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColorsLight.textPrimary,
                  fontSize: responsive.fontSize(20),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                minFontSize: 12,
                letterSpacing: 1.1,
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildBusinessDetails(responsive, isDark),
            SizedBox(height: responsive.hp(10)),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessDetails(AdvancedResponsiveHelper responsive, bool isDark) {
    final businessDetails = [
      {
        'icon': AppIcons.documentIc,
        'title': 'Business Name',
        'subtitle': businessName.isNotEmpty ? businessName : 'Not provided',
      },
      {
        'icon': AppIcons.mobileIc,
        'title': 'Master mobile',
        'subtitle': '+91 90****26',
      },
      {
        'icon': AppIcons.locationIc,
        'title': 'Address',
        'subtitle': 'Business address will be shown here',
      },
      {
        'icon': AppIcons.shopIc,
        'title': 'Business Type',
        'subtitle': 'Retail Store',
      },
      {
        'icon': AppIcons.shopIc,
        'title': 'Category',
        'subtitle': 'General',
      },
      {
        'icon': AppIcons.personIc,
        'title': 'Manager',
        'subtitle': 'Manager name',
      },
      {
        'icon': AppIcons.deleteIc,
        'title': 'Deactivate business',
        'subtitle': 'This action leads to archive entries',
      },
    ];

    return Padding(
      padding: EdgeInsets.all(responsive.wp(3)),
      child: Column(
        children: List.generate(businessDetails.length, (index) {
          final detail = businessDetails[index];
          return Column(
            children: [
              ListItemWidget(
                backgroundColor: isDark ? AppColors.containerLight : AppColorsLight.containerLight,
                title: detail['title'] as String,
                subtitle: detail['subtitle'] as String,
                leadingIcon: detail['icon'] as String,
                trailingIcon: AppIcons.arrowRightIc,
                onTap: () {
                  debugPrint('${detail['title']} tapped');
                },
                showBorder: false,
              ),
              if (index < businessDetails.length - 1)
                SizedBox(height: responsive.hp(0.8)),
            ],
          );
        }),
      ),
    );
  }
}
