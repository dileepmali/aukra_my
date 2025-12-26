import 'package:flutter/material.dart';
import '../custom_app_bar.dart';
import '../model/app_bar_config.dart';

/// Helper class for creating CustomAppBar instances with common configurations
class CustomAppBarHelper {
  /// Creates a simple AppBar with optional title and widgets
  static PreferredSizeWidget createTitleOnlyAppBar({
    required BuildContext context,
    String? title,
    Widget? leadingWidget,
    Widget? trailingWidget,

    // Styling
    Color? gradientStartColor,
    Color? gradientEndColor,
    double? customHeight,
    EdgeInsets? customPadding,
    Color? titleColor,
    TextStyle? titleTextStyle,
    bool showBorder = false,
    Color? borderColor,
  }) {
    return CustomResponsiveAppBar(
      config: AppBarConfig(
        type: AppBarType.titleOnly,
        title: title,
        leadingWidget: leadingWidget,
        trailingWidget: trailingWidget,

        // Styling
        gradientStartColor: gradientStartColor,
        gradientEndColor: gradientEndColor,
        customHeight: customHeight,
        customPadding: customPadding,
        titleColor: titleColor,
        titleTextStyle: titleTextStyle,
        showBorder: showBorder,
        borderColor: borderColor,
      ),
    );
  }

  static PreferredSizeWidget createSearchOnlyAppBar({
    required BuildContext context,
    TextEditingController? searchController,
    Widget? customContent,
    Color? gradientStartColor,
    Color? gradientEndColor,
    double? customHeight,
    String? searchHint,
    Function(String)? onSearchChanged,
    VoidCallback? onSearchSubmitted,
    VoidCallback? onSearchTap,
    Widget? leadingWidget,
    Widget? trailingWidget,
    bool showBorder = true,
    Color? borderColor,
    EdgeInsets? customPadding,
    Function(String)? onViewChange,
    String? title,
    Color? titleColor,
    TextStyle? titleTextStyle,
    required bool enableSearchInput,
  }) {
    return CustomResponsiveAppBar(
      config: AppBarConfig(
        type: AppBarType.searchOnly,
        searchController: searchController,
        customContent: customContent,
        gradientStartColor: gradientStartColor,
        gradientEndColor: gradientEndColor,
        customHeight: customHeight,
        searchHint: searchHint,
        enableSearchInput: enableSearchInput,
        onSearchChanged: onSearchChanged,
        onSearchSubmitted: onSearchSubmitted,
        onSearchTap: onSearchTap,
        leadingWidget: leadingWidget,
        trailingWidget: trailingWidget,
        showBorder: showBorder,
        borderColor: borderColor,
        customPadding: customPadding,
        onViewChanged: onViewChange,
        title: title,
        titleColor: titleColor,
        titleTextStyle: titleTextStyle,
      ),
    );
  }

  static PreferredSizeWidget createSearchWithFilterAppBar({
    required BuildContext context,
    TextEditingController? searchController,

    // Filter options
    String? selectedFilter,
    List<String>? filterOptions,
    VoidCallback? onFilterTap,
    Function(String)? onFilterChanged,

    // View options
    List<String>? viewOptions,
    String? selectedView,
    Function(String)? onViewChanged,
    VoidCallback? onFirstViewTap,
    VoidCallback? onSecondViewTap,

    // Sort options
    String? selectedSortOption,
    String? selectedSortDisplayName,
    VoidCallback? onSortTap,
    Function(String)? onSortChanged,
    String? selectedGroupOption,
    String? selectedGroupDisplayName,
    List<String>? groupOptions,
    Function(String)? onGroupOptionChanged,
    VoidCallback? onGroupFilterTap,

    // Customization
    Widget? customContent,
    Color? gradientStartColor,
    Color? gradientEndColor,
    double? customHeight,
    String? searchHint,
    bool? enableSearchInput,
    Function(String)? onSearchChanged,
    VoidCallback? onSearchSubmitted,
    Widget? leadingWidget,
    Widget? trailingWidget,
    bool showBorder = true,
    Color? borderColor,
    EdgeInsets? customPadding,
    Function(String)? onViewChange,
    String? title,
    Color? titleColor,
    TextStyle? titleTextStyle,
  }) {
    return CustomResponsiveAppBar(
      config: AppBarConfig(
        type: AppBarType.searchWithFilter,
        searchController: searchController,

        // Filter
        selectedFilter: selectedFilter,
        filterOptions: filterOptions,
        onFilterTap: onFilterTap,
        onFilterChanged: onFilterChanged,

        // View controls
        viewOptions: viewOptions,
        selectedView: selectedView,
        onViewChanged: onViewChange,
        onFirstViewTap: onFirstViewTap,
        onSecondViewTap: onSecondViewTap,

        // Sort controls
        selectedSortOption: selectedSortOption,
        selectedSortDisplayName: selectedSortDisplayName,
        onSortTap: onSortTap,
        onSortChanged: onSortChanged,
        selectedGroupOption: selectedGroupOption,
        selectedGroupDisplayName: selectedGroupDisplayName,
        groupOptions: groupOptions,
        onGroupOptionChanged: onGroupOptionChanged,
        onGroupFilterTap: onGroupFilterTap,

        // Customization
        customContent: customContent,
        gradientStartColor: gradientStartColor,
        gradientEndColor: gradientEndColor,
        customHeight: customHeight,
        searchHint: searchHint,
        enableSearchInput: enableSearchInput,
        onSearchChanged: onSearchChanged,
        onSearchSubmitted: onSearchSubmitted,
        leadingWidget: leadingWidget,
        trailingWidget: trailingWidget,
        showBorder: showBorder,
        borderColor: borderColor,
        customPadding: customPadding,
        title: title,
        titleColor: titleColor,
        titleTextStyle: titleTextStyle,
      ),
    );
  }

  static PreferredSizeWidget createFilterOnlyAppBar({
    required BuildContext context,

    // Filter options
    String? selectedFilter,
    List<String>? filterOptions,
    VoidCallback? onFilterTap,
    Function(String)? onFilterChanged,

    // View options
    List<String>? viewOptions,
    String? selectedView,
    Function(String)? onViewChanged,
    VoidCallback? onFirstViewTap,
    VoidCallback? onSecondViewTap,

    // Sort options
    String? selectedSortOption,
    String? selectedSortDisplayName,
    VoidCallback? onSortTap,
    String? selectedGroupOption,
    String? selectedGroupDisplayName,
    List<String>? groupOptions,
    Function(String)? onGroupOptionChanged,
    VoidCallback? onGroupFilterTap,

    // Customization
    Widget? customContent,
    Color? gradientStartColor,
    Color? gradientEndColor,
    double? customHeight,
    Widget? leadingWidget,
    Widget? trailingWidget,
    bool showBorder = true,
    Color? borderColor,
    EdgeInsets? customPadding,
    Function(String)? onViewChange,
    String? title,
    Color? titleColor,
    TextStyle? titleTextStyle,

  }) {
    return CustomResponsiveAppBar(
      config: AppBarConfig(
        type: AppBarType.filterOnly,

        // Filter
        selectedFilter: selectedFilter,
        filterOptions: filterOptions,
        onFilterTap: onFilterTap,
        onFilterChanged: onFilterChanged,

        // View controls
        viewOptions: viewOptions,
        selectedView: selectedView,
        onViewChanged: onViewChange,
        onFirstViewTap: onFirstViewTap,
        onSecondViewTap: onSecondViewTap,

        // Sort controls
        selectedSortOption: selectedSortOption,
        selectedSortDisplayName: selectedSortDisplayName,
        onSortTap: onSortTap,
        selectedGroupOption: selectedGroupOption,
        selectedGroupDisplayName: selectedGroupDisplayName,
        groupOptions: groupOptions,
        onGroupOptionChanged: onGroupOptionChanged,
        onGroupFilterTap: onGroupFilterTap,

        // Customization
        customContent: customContent,
        gradientStartColor: gradientStartColor,
        gradientEndColor: gradientEndColor,
        customHeight: customHeight,
        leadingWidget: leadingWidget,
        trailingWidget: trailingWidget,
        showBorder: showBorder,
        borderColor: borderColor,
        customPadding: customPadding,
        title: title,
        titleColor: titleColor,
        titleTextStyle: titleTextStyle,
      ),
    );
  }
}