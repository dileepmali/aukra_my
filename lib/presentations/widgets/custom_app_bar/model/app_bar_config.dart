import 'package:flutter/material.dart';

enum AppBarType {
  titleOnly,       // Sirf title ke saath (no search)
  searchOnly,      // Sirf search bar ke saath
  searchWithFilter, // Search bar + Filter controls ke saath
  filterOnly       // Only filter controls (no search bar)
}

class AppBarConfig {
  final AppBarType type;
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode; // 🔥 NEW: FocusNode for auto-focus

  // Filter ke liye dynamic options
  final String? selectedFilter;
  final List<String>? filterOptions;
  final VoidCallback? onFilterTap;
  final Function(String)? onFilterChanged;

  // View controls ke liye external callbacks
  final List<String>? viewOptions;
  final String? selectedView;
  final Function(String)? onViewChanged;

  // Individual view button callbacks
  final VoidCallback? onFirstViewTap;
  final VoidCallback? onSecondViewTap;

  // Sort controls
  final String? selectedSortOption;
  final String? selectedSortDisplayName;
  final VoidCallback? onSortTap;
  final Function(String)? onSortChanged;
  final String? selectedGroupOption;
  final String? selectedGroupDisplayName;
  final List<String>? groupOptions;
  final Function(String)? onGroupOptionChanged;
  final VoidCallback? onGroupFilterTap;

  // Styling options
  final Color? gradientStartColor;
  final Color? gradientEndColor;
  final Widget? customContent;
  final double? customHeight;
  final EdgeInsets? customPadding;

  // Search bar customization
  final String? searchHint;
  final bool? enableSearchInput;
  final bool? forceEnableSearch; // 🔧 NEW: Force enable search for contact_screen
  final Function(String)? onSearchChanged;
  final VoidCallback? onSearchSubmitted;
  final VoidCallback? onSearchTap;

  // Advanced customization
  final bool showBorder;
  final Color? borderColor;
  final Widget? leadingWidget;
  final Widget? trailingWidget;
  final String? title;
  final Color? titleColor;
  final TextStyle? titleTextStyle;
  final BuildContext? context;

  // Grid/List view toggle
  bool? isGridView;
  final Function(bool)? onViewToggle;
  final bool? showViewToggle;

  // Filters applied callback
  final Function(Map<String, dynamic>)? onFiltersApplied;

  // Current filter values (to restore previous selections)
  final String? currentFilter;
  final String? currentSortBy;
  final String? currentSortOrder;

  // ✅ Breadcrumb navigation for nested folders (Desktop)
  final List<String>? breadcrumbs;  // List of parent folder names
  final String? currentFolderName;  // Current folder name
  final VoidCallback? onBreadcrumbBack; // Callback when navigating back

  // Theme support for breadcrumbs
  final bool? isDark; // Theme mode for breadcrumb styling

  // ✅ Folder context for action buttons (nested folder upload)
  final String? folderId; // Current folder ID (for nested folder uploads)
  final String? folderName; // Current folder name

  AppBarConfig({
    required this.type,
    this.searchController,
    this.searchFocusNode, // 🔥 NEW: FocusNode parameter

    // Filter options
    this.selectedFilter,
    this.filterOptions,
    this.onFilterTap,
    this.onFilterChanged,

    // View options
    this.viewOptions,
    this.selectedView,
    this.onViewChanged,
    this.onFirstViewTap,
    this.onSecondViewTap,

    // Sort options
    this.selectedSortOption,
    this.selectedSortDisplayName,
    this.onSortTap,
    this.onSortChanged,
    this.selectedGroupOption,
    this.selectedGroupDisplayName,
    this.groupOptions,
    this.onGroupOptionChanged,
    this.onGroupFilterTap,

    // Styling
    this.gradientStartColor,
    this.gradientEndColor,
    this.customContent,
    this.customHeight,
    this.customPadding,

    // Search customization
    this.searchHint,
    this.enableSearchInput,
    this.forceEnableSearch, // 🔧 NEW: Force enable search parameter
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onSearchTap,

    // Advanced
    this.showBorder = true,
    this.borderColor,
    this.leadingWidget,
    this.trailingWidget,
    this.title,
    this.titleColor,
    this.titleTextStyle,
    this.context,

    // Grid/List view toggle
    this.isGridView,
    this.onViewToggle,
    this.showViewToggle,

    // Filters callback
    this.onFiltersApplied,

    // Current filter values
    this.currentFilter,
    this.currentSortBy,
    this.currentSortOrder,

    // Breadcrumb navigation
    this.breadcrumbs,
    this.currentFolderName,
    this.onBreadcrumbBack,

    // Theme
    this.isDark,

    // Folder context
    this.folderId,
    this.folderName,
  });
}