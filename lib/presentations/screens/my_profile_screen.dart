import 'package:flutter/material.dart';
import '../../app/localizations/l10n/app_localizations.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_text.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/helper_class_2.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AppText.headlineLarge(
          'My Profile',
          color: isDark ? AppColors.white : AppColorsLight.textPrimary,
        ),
      ),
      body: Center(
        child: AppText.headlineLarge(
          'My Profile Screen Content',
          color: isDark ? AppColors.white : AppColorsLight.textPrimary,
        ),
      ),
    );
  }
}
