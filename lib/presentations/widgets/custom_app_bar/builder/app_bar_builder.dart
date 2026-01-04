
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/responsive_layout/device_category.dart';
import '../../../../app/constants/app_icons.dart';
import '../../../../app/themes/app_colors.dart';
import '../../../../app/themes/app_colors_light.dart';
import '../../../../app/themes/app_fonts.dart';
import '../../../../app/themes/app_text.dart';
import '../../../../core/haptic_service.dart';
import '../../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../../core/responsive_layout/helper_class_2.dart';
import '../../../../core/responsive_layout/padding_navigation.dart';
import '../../custom_border_widget.dart';
import '../componests/search_selection.dart';
import '../componests/filters_bottom_sheet.dart';
import '../model/app_bar_config.dart';


class AppBarBuilder {
  static Widget build(AppBarConfig config, AdvancedResponsiveHelper responsive) {
    switch (config.type) {
      case AppBarType.titleOnly:
        return _buildTitleOnlyContent(config, responsive);
      case AppBarType.searchOnly:
        return _buildSearchOnlyContent(config, responsive);
      case AppBarType.searchWithFilter:
        return _buildSearchWithFilterContent(config, responsive);
      case AppBarType.filterOnly:
        return _buildFilterOnlyContent(config, responsive);
    }
  }

  static Widget _buildTitleOnlyContent(AppBarConfig config, AdvancedResponsiveHelper responsive) {
    return Padding(
      padding: config.customPadding ?? EdgeInsets.symmetric(
        horizontal: responsive.spacing(16),
        vertical: responsive.spacing(8),
      ),
      child: Row(
        children: [
          // Leading widget (back button, etc.)
          if (config.leadingWidget != null) ...[
            config.leadingWidget!,
            SizedBox(width: responsive.spacing(12)),
          ],

          // Title (only show if title is provided)
          if (config.title != null && config.title!.isNotEmpty)
            Expanded(
              child: AppText.custom(
                config.title!,
                style: config.titleTextStyle ?? TextStyle(
                  color: config.titleColor ?? Colors.white,
                  fontSize: responsive.fontSize(18),
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                minFontSize: 12,
              ),
            )
          else if (config.leadingWidget == null && config.trailingWidget == null)
          // Empty spacer if no title and no widgets
            Expanded(child: SizedBox.shrink())
          else
          // Flexible spacer when there are widgets but no title
            Spacer(),

          // Trailing widget (menu, etc.)
          if (config.trailingWidget != null) ...[
            SizedBox(width: responsive.spacing(12)),
            config.trailingWidget!,
          ],
        ],
      ),
    );
  }

  static Widget _buildSearchOnlyContent(AppBarConfig config, AdvancedResponsiveHelper responsive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (config.title != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: AppText.custom(
              config.title!,
              style: config.titleTextStyle ??
                  AppFonts.appBarTitle(
                    color: config.titleColor ?? AppColors.textWhite,
                  ),
              maxLines: 1,
              minFontSize: 12,
            ),
          ),
          SizedBox(height: responsive.hp(1)),
        ],

        if (config.leadingWidget != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              config.leadingWidget!,
              if (config.trailingWidget != null) config.trailingWidget!,
            ],
          ),
          SizedBox(height: responsive.hp(2)),
        ],

        if (config.customContent != null) ...[
          config.customContent!,
          SizedBox(height: responsive.hp(1)),
        ],

        SearchSection(
          searchController: config.searchController,
          searchFocusNode: config.searchFocusNode, // 🔥 NEW: Pass FocusNode
          searchHint: config.searchHint,
          enableSearchInput: config.enableSearchInput,
          forceEnableSearch: config.forceEnableSearch, // 🔧 NEW: Pass forceEnableSearch
          onSearchChanged: config.onSearchChanged,
          onSearchSubmitted: config.onSearchSubmitted,
          onSearchTap: config.onSearchTap,
        ),

        SizedBox(height: responsive.hp(1.2)),
      ],
    );
  }

  static Widget _buildSearchWithFilterContent(AppBarConfig config, AdvancedResponsiveHelper responsive) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isGridView = config.isGridView ?? true;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (config.title != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: AppText.custom(
                  config.title!,
                  style: config.titleTextStyle ??
                      AppFonts.appBarTitle(
                        color: config.titleColor ?? AppColors.textWhite,
                      ),
                  maxLines: 1,
                  minFontSize: 12,
                ),
              ),
              SizedBox(height: responsive.hp(1)),
            ],

            if (config.leadingWidget != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  config.leadingWidget!,
                  if (config.trailingWidget != null) config.trailingWidget!,
                ],
              ),
              SizedBox(height: responsive.hp(2)),
            ],

            if (config.customContent != null) ...[
              config.customContent!,
              SizedBox(height: responsive.hp(1)),
            ],

            Row(
              children: [
                Expanded(
                  child: SearchSection(
                    searchController: config.searchController,
                    searchFocusNode: config.searchFocusNode, // 🔥 NEW: Pass FocusNode
                    searchHint: config.searchHint,
                    enableSearchInput: config.enableSearchInput,
                    forceEnableSearch: config.forceEnableSearch, // 🔧 NEW: Pass forceEnableSearch
                    onSearchChanged: config.onSearchChanged,
                    onSearchSubmitted: config.onSearchSubmitted,
                    onSearchTap: config.onSearchTap,
                  ),
                ),
                SizedBox(width: responsive.spacing(12)),

                // Filter icon
                Builder(
                  builder: (context) {
                    // 🔥 NEW: Check if filter is active (not 'all' or empty)
                    final isFilterActive = config.currentFilter != null &&
                                          config.currentFilter != 'all' &&
                                          config.currentFilter!.isNotEmpty;

                    return GestureDetector(
                      onTap: () {
                        // ✅ Haptic feedback on filter icon tap
                        HapticService.mediumImpact();

                        // ✅ Use custom onFilterTap if provided, otherwise use default
                        if (config.onFilterTap != null) {
                          config.onFilterTap!();
                        } else {
                          _showFiltersBottomSheet(
                            context,
                            config.onFiltersApplied,
                            config.currentFilter,
                            config.currentSortBy,
                            config.currentSortOrder,
                          );
                        }
                      },
                      child: BorderColor(
                        isSelected: isFilterActive, // ✅ Only show border if filter is active
                        child: Container(
                          height: responsive.hp(6.5),
                          width: responsive.wp(15),
                          padding: EdgeInsets.symmetric(horizontal: responsive.spacing(15)),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.containerDark : AppColorsLight.scaffoldBackground,
                            borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                          ),
                          child: SvgPicture.asset(
                            // Show plus icon when no filter is active, filter icon when active
                            isFilterActive ? AppIcons.filtersIc : AppIcons.plusIc,
                            color: isDark ? Colors.white : AppColorsLight.iconPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Only show Grid/List toggle if showViewToggle is true (default: true)
                if (config.showViewToggle ?? true) ...[
                  SizedBox(width: responsive.spacing(5)),
                  GestureDetector(
                    onTap: () {
                      // ✅ Haptic feedback on grid/list toggle tap
                      HapticService.mediumImpact();

                      setState(() {
                        config.isGridView = !isGridView;
                        if (config.onViewToggle != null) {
                          config.onViewToggle!(!isGridView);
                        }
                      });
                    },
                    child: Container(
                      height: responsive.hp(6.5),
                      padding: EdgeInsets.symmetric(horizontal: responsive.spacing(15)),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.containerDark : AppColorsLight.scaffoldBackground,
                        borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                      ),
                      child: SvgPicture.asset(
                        isGridView ? AppIcons.gridIc : AppIcons.listIc,
                        color: isDark ? Colors.white : AppColorsLight.iconPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            SizedBox(height: responsive.hp(1.5)),
          ],
        );
      }
    );
  }

  static Widget _buildFilterOnlyContent(AppBarConfig config, AdvancedResponsiveHelper responsive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: responsive.hp(1)),

        if (config.title != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: AppText.custom(
              config.title!,
              style: config.titleTextStyle ??
                  AppFonts.appBarTitle(
                    color: config.titleColor ?? AppColors.textWhite,
                  ),
              maxLines: 1,
              minFontSize: 12,
            ),
          ),
          SizedBox(height: responsive.hp(1)),
        ],

        if (config.leadingWidget != null || config.trailingWidget != null) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.wp(3.5)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                config.leadingWidget ?? const SizedBox.shrink(),
                config.trailingWidget ?? const SizedBox.shrink(),
              ],
            ),
          ),
          SizedBox(height: responsive.hp(0.5)),
        ],

        if (config.customContent != null) ...[
          config.customContent!,
          SizedBox(height: responsive.hp(1)),
        ],
      ],
    );
  }

  static void _showFiltersBottomSheet(
    BuildContext? context,
    Function(Map<String, dynamic>)? onFiltersApplied,
    String? currentFilter,
    String? currentSortBy,
    String? currentSortOrder,
  ) {
    if (context == null) return;

    // ✅ Don't show bottom sheet if onFiltersApplied is null (disabled for that screen)
    if (onFiltersApplied == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FiltersBottomSheet(
        onFiltersApplied: onFiltersApplied,
        initialFilter: currentFilter,
        initialSortBy: currentSortBy,
        initialSortOrder: currentSortOrder,
      ),
    );
  }
}