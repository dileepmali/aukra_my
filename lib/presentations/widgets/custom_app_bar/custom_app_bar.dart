// custom_responsive_app_bar.dart - REFACTORED VERSION

import 'package:flutter/material.dart';
import '../../../../core/responsive_layout/device_category.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../custom_single_border_color.dart';
import 'builder/app_bar_builder.dart';
import 'model/app_bar_config.dart';


class CustomResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBarConfig config;

  const CustomResponsiveAppBar({
    Key? key,
    required this.config,
  }) : super(key: key);

  @override
  Size get preferredSize {
    switch (config.type) {
      case AppBarType.titleOnly:
        return const Size.fromHeight(140);
      case AppBarType.searchOnly:
        return const Size.fromHeight(140);
      case AppBarType.searchWithFilter:
        return const Size.fromHeight(140);
      case AppBarType.filterOnly:
        return const Size.fromHeight(140);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
          height: config.customHeight ?? _getResponsiveHeight(responsive),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      config.gradientStartColor ?? AppColors.containerDark,
                      config.gradientEndColor ?? AppColors.containerLight,
                      AppColors.containerLight,
                      AppColors.containerLight,
                      AppColors.containerLight,
                    ]
                  : [

                      AppColorsLight.background,
                      AppColorsLight.background,
                      AppColorsLight.background,
                    ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: config.customPadding ?? EdgeInsets.symmetric(
                horizontal: responsive.wp(5),
                vertical: responsive.wp(5),
              ),
              child: AppBarBuilder.build(config, responsive),
            ),
          ),
        ),
        if (config.showBorder)
          Positioned.fill(
            child: CustomSingleBorderWidget(
              position: BorderPosition.bottom,
              borderWidth: isDark ? 1.0 : 1.0,
            ),
          ),
      ],
    );
  }

  double _getResponsiveHeight(AdvancedResponsiveHelper responsive) {
    switch (config.type) {
      case AppBarType.titleOnly:
        return responsive.hp(12);
      case AppBarType.searchOnly:
        return responsive.hp(18);
      case AppBarType.searchWithFilter:
        return responsive.hp(18);
      case AppBarType.filterOnly:
        return responsive.hp(18);
    }
  }
}