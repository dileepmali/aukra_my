import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/constants/app_images.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_fonts.dart';
import '../../../app/themes/app_text.dart';
import '../../../buttons/app_button.dart';
import '../../../controllers/localization_controller.dart';
import '../../../controllers/language_search_controller.dart';
import '../../../app/localizations/l10n/app_strings.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../../widgets/custom_border_widget.dart';


/// Desktop layout for Select Language Screen
/// Centered container with language grid and continue button
class SelectLanguageDesktopContent extends StatefulWidget {
  final LocalizationController localizationController;
  final LanguageSearchController searchController;
  final VoidCallback onContinuePressed;

  const SelectLanguageDesktopContent({
    Key? key,
    required this.localizationController,
    required this.searchController,
    required this.onContinuePressed,
  }) : super(key: key);

  @override
  State<SelectLanguageDesktopContent> createState() => _SelectLanguageDesktopContentState();
}

class _SelectLanguageDesktopContentState extends State<SelectLanguageDesktopContent> {
  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Initialize AppStrings for localization
    AppStrings.init(context);

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    AppColors.containerLight ?? Colors.black,
                    AppColors.containerLight ?? Colors.black,
                    AppColors.containerDark ?? Colors.grey.shade800,
                    AppColors.containerDark ?? Colors.grey.shade800,
                  ]
                : [
                    AppColorsLight.scaffoldBackground,
                    AppColorsLight.scaffoldBackground,
                    AppColorsLight.scaffoldBackground,
                    AppColorsLight.scaffoldBackground,
                  ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: responsive.wp(32),  // Minimum width: 25%
              maxWidth: responsive.wp(35),  // Maximum width: 35%
              minHeight: responsive.hp(78),  // Minimum height: 8%
              maxHeight: responsive.hp(80), // Maximum height: 15%
            ),
            child: Container(

              padding: EdgeInsets.all(responsive.wp(1.5)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                    AppColorsLight.white,
                    AppColorsLight.white,
                        ]
                      : [
                          AppColorsLight.white,
                          AppColorsLight.white,
                        ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
              ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo section at top
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // App Logo on the left
                    Image.asset(
                      AppImages.appLogoIm,
                      height: responsive.iconSizeExtraLarge,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(width: responsive.spacing(4)),
                    // Aukra Icon and Tagline
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Aukra SVG Icon (replacing AnantSpace text)
                          SvgPicture.asset(
                            AppIcons.aukraIc,
                            height: responsive.hp(1.8),
                          ),
                          SizedBox(height: responsive.space2XS),
                          // Tagline: Infinity Income Advance Income
                          AppText.bodyMedium(
                            'Infinity Income Advance Income',
                            color: AppColors.splaceSecondary1,
                            maxLines: 1,
                            minFontSize: 7,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: responsive.spaceMD),

                // Select Language Text
                Text(
                  AppStrings.getLocalizedString(
                    context,
                    (localizations) => localizations.selectLanguage ?? 'Select Language',
                  ),
                  style: AppFonts.headlineSmall1(
                    color: isDark ? AppColors.black : AppColorsLight.black,
                    fontWeight: AppFonts.medium,
                  ),
                ),
                SizedBox(height: responsive.spaceSM),

                // Search Bar
                _buildSearchBar(context, responsive, isDark),
                SizedBox(height: responsive.spaceSM),

                // Language Grid - Fixed Size: 500px height
                Expanded(child: _buildLanguageGridSection(context, responsive, isDark)),


                // Continue Button - Height: 72px
                Padding(
                  padding:  EdgeInsets.only(top: responsive.spaceMD),
                  child: _buildContinueButton(context, responsive, isDark),
                ),
              ],
            ),
                        ),
          ),
      ),
      ),
    );
  }

  Widget _buildLanguageGridSection(
    BuildContext context,
    AdvancedResponsiveHelper responsive,
    bool isDark,
  ) {
    return Obx(() {
      final languages = widget.searchController.currentLanguages;

      return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Fixed 3 columns
              crossAxisSpacing: responsive.hp(0.4),
              mainAxisSpacing: responsive.wp(0.4),
              childAspectRatio: 1.5, // Width to height ratio (higher = shorter height)
            ),
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final lang = languages[index];

              return _LanguageGridItem(
                lang: lang,
                localizationController: widget.localizationController,
                responsive: responsive,
                isDark: isDark,
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildSearchBar(
    BuildContext context,
    AdvancedResponsiveHelper responsive,
    bool isDark,
  ) {
    return TextField(
      controller: widget.searchController.searchController,
      style: AppFonts.bodyLarge(
        color: isDark ? AppColorsLight.textPrimary : AppColorsLight.textPrimary,
        fontWeight: AppFonts.regular,
      ),
      decoration: InputDecoration(
        hintText: 'Search language...',
        hintStyle: AppFonts.bodyLarge(
          color: isDark ? AppColorsLight.textSecondary : AppColorsLight.textSecondary,
          fontWeight: AppFonts.light,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: isDark ? AppColorsLight.textSecondary : AppColorsLight.textSecondary,
        ),
        suffixIcon: Obx(() => widget.searchController.searchQuery.value.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: isDark ? AppColorsLight.textSecondary : AppColorsLight.textSecondary,
                ),
                onPressed: () => widget.searchController.clearSearch(),
              )
            : SizedBox.shrink()),
        filled: true,
        fillColor: isDark
            ? AppColorsLight.inputBackground
            : AppColorsLight.inputBackground,
        contentPadding: EdgeInsets.symmetric(
          horizontal: responsive.wp(1),
          vertical: responsive.hp(1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
          borderSide: BorderSide(
            color: isDark
                ? AppColorsLight.border
                : AppColorsLight.border,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
          borderSide: BorderSide(
            color: isDark
                ? AppColorsLight.border
                : AppColorsLight.border,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
          borderSide: BorderSide(
            color: isDark
                ? AppColors.splaceSecondary2
                : AppColors.splaceSecondary2,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(
    BuildContext context,
    AdvancedResponsiveHelper responsive,
    bool isDark,
  ) {
    return AppButton(
      width: double.infinity,
      height: responsive.hp(8),
      gradientColors: [
        AppColors.splaceSecondary1,
        AppColors.splaceSecondary2,
      ],
      enableSweepGradient: true,
      borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: responsive.wp(1),
          offset: Offset(0, responsive.hp(0.3)),
        ),
      ],
      padding: EdgeInsets.symmetric(horizontal: responsive.wp(2)),
      onPressed: widget.onContinuePressed,
      child: Center(
        child: Text(
          AppStrings.getLocalizedString(
            context,
            (localizations) => localizations.continueText ?? 'Continue',
          ),
          textAlign: TextAlign.center,
          style: AppFonts.headlineSmall(
            color: Colors.white,
            fontWeight: AppFonts.regular,
          ),
        ),
      ),
    );
  }
}

/// Stateful widget for individual language grid item with hover support
class _LanguageGridItem extends StatefulWidget {
  final Map<String, String> lang;
  final LocalizationController localizationController;
  final AdvancedResponsiveHelper responsive;
  final bool isDark;

  const _LanguageGridItem({
    Key? key,
    required this.lang,
    required this.localizationController,
    required this.responsive,
    required this.isDark,
  }) : super(key: key);

  @override
  State<_LanguageGridItem> createState() => _LanguageGridItemState();
}

class _LanguageGridItemState extends State<_LanguageGridItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isCurrentLanguage = widget.localizationController
              .currentLanguageCode ==
          (widget.lang['code'] ?? '');
      final isSelected = isCurrentLanguage || _isHovered;

      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: BorderColor(
          isSelected: isSelected,
          borderRadius: widget.responsive.borderRadiusSmall,
          useCustomColors: true, // Use custom gradient colors
          child: AnimatedContainer(
            duration: Duration(milliseconds: 150),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isDark
                    ? [
                        AppColors.scaffoldBackground,
                        AppColors.scaffoldBackground,
                      ]
                    : [
                        AppColorsLight.scaffoldBackground,
                        AppColorsLight.scaffoldBackground,
                      ],
              ),
              borderRadius: BorderRadius.circular(
                math.max(0, widget.responsive.borderRadiusSmall - 2),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(
                  math.max(0, widget.responsive.borderRadiusSmall - 2),
                ),
                onTap: () {
                  // Change language
                  widget.localizationController.changeLocale(widget.lang['code'] ?? '');
                },
                child: Container(
                  padding: EdgeInsets.all(widget.responsive.spaceSM),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isCurrentLanguage) ...[
                          SvgPicture.asset(
                            AppIcons.checkmarkIc,
                            height: widget.responsive.iconSizeMedium,
                            width: widget.responsive.iconSizeMedium,
                            colorFilter: ColorFilter.mode(
                              widget.isDark
                                  ? AppColorsLight.textPrimary
                                  : AppColorsLight.textPrimary,
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(height: widget.responsive.space2XS),
                        ],
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.lang['name'] ?? '',
                              style: AppFonts.bodyLarge1(
                                color: widget.isDark
                                    ? AppColorsLight.textPrimary
                                    : AppColorsLight.textPrimary,
                                fontWeight: AppFonts.regular,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
