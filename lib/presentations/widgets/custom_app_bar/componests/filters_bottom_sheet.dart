import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aukra_anantkaya_space/app/constants/app_icons.dart';
import 'package:aukra_anantkaya_space/app/themes/app_colors.dart';
import 'package:aukra_anantkaya_space/app/themes/app_colors_light.dart';
import 'package:aukra_anantkaya_space/app/themes/app_fonts.dart';
import 'package:aukra_anantkaya_space/app/themes/app_text.dart';
import 'package:aukra_anantkaya_space/app/localizations/l10n/app_strings.dart';
import 'package:aukra_anantkaya_space/core/responsive_layout/font_size_hepler_class.dart';
import 'package:aukra_anantkaya_space/core/responsive_layout/helper_class_2.dart';
import 'package:aukra_anantkaya_space/core/responsive_layout/padding_navigation.dart';
import '../../../../buttons/row_app_bar.dart';
import '../../../../core/responsive_layout/device_category.dart';
import '../../custom_single_border_color.dart';

class FiltersBottomSheet extends StatefulWidget {
  final Map<String, String>? filterOptions;
  final Function(Map<String, dynamic>)? onFiltersApplied;
  final String? initialFilter;
  final String? initialSortBy;
  final String? initialSortOrder;

  const FiltersBottomSheet({
    Key? key,
    this.filterOptions,
    this.onFiltersApplied,
    this.initialFilter,
    this.initialSortBy,
    this.initialSortOrder,
  }) : super(key: key);

  @override
  State<FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<FiltersBottomSheet> {
  String selectedFilter = 'Sort by';
  String selectedSortOption = 'default'; // ✅ Default: Default option
  String selectedDateOption = 'today'; // ✅ Default: Today
  String selectedTransactionOption = 'all_transaction'; // ✅ Default: All transaction
  List<String> selectedReminderOptions = ['all']; // ✅ Default: All (checkbox - single selection)
  List<String> selectedPlaceholderOptions = ['all']; // ✅ Default: All (checkbox - single selection)
  bool isLoadingState = false;

  @override
  void initState() {
    super.initState();

    // ✅ Restore sort option from initial values OR use default
    if (widget.initialSortBy != null && widget.initialSortOrder != null) {
      selectedSortOption = _getSortKeyFromValues(widget.initialSortBy!, widget.initialSortOrder!);
    }
  }

  // Convert API sortBy/sortOrder to UI key
  String _getSortKeyFromValues(String sortBy, String sortOrder) {
    if (sortBy == 'default') return 'default';
    if (sortBy == 'transaction_date' && sortOrder == 'desc') return 'transaction_date_desc';
    if (sortBy == 'name' && sortOrder == 'asc') return 'name_az';
    if (sortBy == 'name' && sortOrder == 'desc') return 'name_za';
    if (sortBy == 'amount' && sortOrder == 'asc') return 'amount_asc';
    if (sortBy == 'amount' && sortOrder == 'desc') return 'amount_desc';
    return 'default';
  }

  List<SortOption> get sortOptions => [
    SortOption(
      key: 'default',
      title: 'Default',
    ),
    SortOption(
      key: 'name_az',
      title: 'Name A-Z\n(Ascending)',
    ),
    SortOption(
      key: 'name_za',
      title: 'Name Z-A\n(Descending)',
    ),
    SortOption(
      key: 'amount_asc',
      title: 'Amount\n(Ascending)',
    ),
    SortOption(
      key: 'amount_desc',
      title: 'Amount\n(Descending)',
    ),
    SortOption(
      key: 'transaction_date_desc',
      title: 'Transaction Date\n(Descending)',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
        height: responsive.hp(70),
        decoration: BoxDecoration(
          color: isDark ? AppColors.overlay : AppColorsLight.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(responsive.borderRadiusExtraLarge),
            topRight: Radius.circular(responsive.borderRadiusExtraLarge),
          ),
        ),
        child: Column(
          children: [
            // Bottom sheet drag handle
            SizedBox(height: responsive.hp(1.5)),
            Center(
              child: Container(
                width: responsive.wp(12),
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.textWhite54 : AppColorsLight.textPrimary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(responsive.borderRadiusMedium),
                ),
              ),
            ),
            SizedBox(height: responsive.hp(1)),

            // Header
            Container(
              padding: EdgeInsets.all(responsive.spacing(20)),
              child: Row(
                children: [
                  AppText.appBarTitleLarge(
                    AppStrings.getLocalizedString(context, (localizations) => localizations.filters),
                    color: isDark ? AppColors.textWhite : AppColorsLight.textPrimary,
                    maxLines: 1,
                    minFontSize: 14,
                  ),
                ],
              ),
            ),

            Divider(
              color: isDark ? Colors.white.withOpacity(0.1) : AppColorsLight.textPrimary.withOpacity(0.2),
              thickness: 0.9,
              height: 1,
            ),

            // Content
            Expanded(
              child: Row(
                children: [
                  // Left Sidebar
                  Container(
                    width: responsive.wp(35),
                    color: isDark ? Colors.black : AppColorsLight.scaffoldBackground,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => selectedFilter = 'Sort by'),
                          child: _buildSidebarItem(
                            AppStrings.getLocalizedString(context, (localizations) => localizations.sortBy),
                            selectedFilter == 'Sort by',
                            responsive
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => selectedFilter = 'Date'),
                          child: _buildSidebarItem(
                            'Date',
                            selectedFilter == 'Date',
                            responsive
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => selectedFilter = 'Transaction'),
                          child: _buildSidebarItem(
                            'Transaction',
                            selectedFilter == 'Transaction',
                            responsive
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => selectedFilter = 'Reminder'),
                          child: _buildSidebarItem(
                            'Reminder',
                            selectedFilter == 'Reminder',
                            responsive
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => selectedFilter = 'User'),
                          child: _buildSidebarItem(
                            'User',
                            selectedFilter == 'User',
                            responsive
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main Content
                  Expanded(
                    child: SingleChildScrollView(
                      dragStartBehavior: DragStartBehavior.start,
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.all(responsive.spaceMD),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildMainContent(responsive),
                        ],
                      ),

    ),
                  ),
                ],
              ),
            ),


            // Bottom Action Bar
            BottomActionBar(
              gradientColors: [
                isDark ? AppColors.overlay : AppColorsLight.white,
                isDark ? AppColors.overlay : AppColorsLight.white,
              ],
              showBorder: true,
              primaryButtonText: AppStrings.getLocalizedString(context, (localizations) => localizations.goBack),
              onPrimaryPressed: isLoadingState ? null : () => Navigator.pop(context),
              secondaryButtonText: AppStrings.getLocalizedString(context, (localizations) => localizations.apply),
              buttonSpacing: responsive.spacing(16),
              containerPadding: EdgeInsets.symmetric(
                horizontal: responsive.spacing(16),
                vertical: responsive.spacing(16),
              ),
              isSecondaryLoading: isLoadingState,
              onSecondaryPressed: isLoadingState ? null : () async {
                HapticFeedback.lightImpact();

                setState(() => isLoadingState = true);

                try {
                  // Map sort options to API values
                  String sortBy = 'default';
                  String sortOrder = 'desc';

                  switch (selectedSortOption) {
                    case 'default':
                      sortBy = 'default';
                      sortOrder = 'desc';
                      break;
                    case 'transaction_date_desc':
                      sortBy = 'transaction_date';
                      sortOrder = 'desc';
                      break;
                    case 'name_az':
                      sortBy = 'name';
                      sortOrder = 'asc';
                      break;
                    case 'name_za':
                      sortBy = 'name';
                      sortOrder = 'desc';
                      break;
                    case 'amount_asc':
                      sortBy = 'amount';
                      sortOrder = 'asc';
                      break;
                    case 'amount_desc':
                      sortBy = 'amount';
                      sortOrder = 'desc';
                      break;
                    default:
                      sortBy = 'default';
                      sortOrder = 'desc';
                  }

                  final result = {
                    'sortBy': sortBy,
                    'sortOrder': sortOrder,
                    'dateFilter': selectedDateOption,
                    'transactionFilter': selectedTransactionOption,
                    'reminderFilter': selectedReminderOptions.isNotEmpty ? selectedReminderOptions.first : 'all',
                    'userFilter': selectedPlaceholderOptions.isNotEmpty ? selectedPlaceholderOptions.first : 'all',
                  };

                  widget.onFiltersApplied?.call(result);

                  // Small delay for smooth animation
                  await Future.delayed(const Duration(milliseconds: 300));

                  if (mounted) {
                    setState(() => isLoadingState = false);
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    setState(() => isLoadingState = false);
                  }
                }
              },
            ),
          ],
        ),
      ),
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

      ]
    );
  }

  Widget _buildSidebarItem(String title, bool isSelected, AdvancedResponsiveHelper responsive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(right: responsive.wp(2),top: responsive.wp(2),left: responsive.wp(2)),
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing(20),
        vertical: responsive.spacing(15),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSelected
              ? (isDark
                  ? [AppColors.containerLight, AppColors.containerDark]
                  : [AppColorsLight.textPrimary.withOpacity(0.2), AppColorsLight.textPrimary.withOpacity(0.1)])
              : (isDark
                  ? [Colors.black, Colors.black]
                  : [AppColorsLight.scaffoldBackground, AppColorsLight.scaffoldBackground]),
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        border: Border.all(
          color: isSelected
              ? (isDark ? AppColors.transparent : AppColorsLight.textPrimary.withOpacity(0.2))
              : Colors.transparent,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
      ),
      child: AppText.custom(
        title,
        style: AppFonts.appBarTitleMedium(
          color: isDark ? AppColors.textWhite : AppColorsLight.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        maxLines: 1,
        minFontSize: 10,
      ),
    );
  }

  Widget _buildMainContent(AdvancedResponsiveHelper responsive) {
    switch (selectedFilter) {
      case 'Sort by':
        return _buildSortOptions(responsive);
      case 'Date':
        return _buildDateOptions(responsive);
      case 'Transaction':
        return _buildTransactionOptions(responsive);
      case 'Reminder':
        return _buildReminderOptions(responsive);
      case 'User':
        return _buildPlaceholderOptions(responsive);
      default:
        return _buildSortOptions(responsive);
    }
  }

  Widget _buildDateOptions(AdvancedResponsiveHelper responsive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dateOptions = [
      {'key': 'today', 'title': 'Today'},
      {'key': 'yesterday', 'title': 'Yesterday'},
      {'key': 'older_week', 'title': 'Older than a week'},
      {'key': 'older_month', 'title': 'Older than a month'},
      {'key': 'all_time', 'title': 'All time'},
      {'key': 'custom', 'title': 'Custom'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        for (int index = 0; index < dateOptions.length; index++) ...[
          _buildDateOption(dateOptions[index], responsive),
          if (index < dateOptions.length - 1)
            Divider(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
              height: 1,
            ),
        ],
      ],
    );
  }

  Widget _buildDateOption(Map<String, String> option, AdvancedResponsiveHelper responsive) {
    return _buildCommonFilterOption(
      option: option,
      responsive: responsive,
      isSelected: selectedDateOption == option['key'],
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          selectedDateOption = option['key']!;
        });
      },
      isCheckboxStyle: false, // Radio button style
    );
  }

  Widget _buildTransactionOptions(AdvancedResponsiveHelper responsive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final transactionOptions = [
      {'key': 'all_transaction', 'title': 'All transaction'},
      {'key': 'in_transaction', 'title': 'In transaction'},
      {'key': 'old_transaction', 'title': 'Old transaction'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        for (int index = 0; index < transactionOptions.length; index++) ...[
          _buildTransactionOption(transactionOptions[index], responsive),
          if (index < transactionOptions.length - 1)
            Divider(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
              height: 1,
            ),
        ],
      ],
    );
  }

  Widget _buildTransactionOption(Map<String, String> option, AdvancedResponsiveHelper responsive) {
    return _buildCommonFilterOption(
      option: option,
      responsive: responsive,
      isSelected: selectedTransactionOption == option['key'],
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          selectedTransactionOption = option['key']!;
        });
      },
      isCheckboxStyle: false, // Radio button style
    );
  }

  Widget _buildReminderOptions(AdvancedResponsiveHelper responsive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final reminderOptions = [
      {'key': 'all', 'title': 'All'},
      {'key': 'overdue', 'title': 'Overdue'},
      {'key': 'today', 'title': 'Today'},
      {'key': 'upcoming', 'title': 'Upcoming'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        for (int index = 0; index < reminderOptions.length; index++) ...[
          _buildReminderOption(reminderOptions[index], responsive),
          if (index < reminderOptions.length - 1)
            Divider(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
              height: 1,
            ),
        ],
      ],
    );
  }

  Widget _buildReminderOption(Map<String, String> option, AdvancedResponsiveHelper responsive) {
    return _buildCommonFilterOption(
      option: option,
      responsive: responsive,
      isSelected: selectedReminderOptions.contains(option['key']),
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          // Clear all selections and select only this one
          selectedReminderOptions.clear();
          selectedReminderOptions.add(option['key']!);
        });
      },
      isCheckboxStyle: true, // Checkbox style
    );
  }

  Widget _buildPlaceholderOptions(AdvancedResponsiveHelper responsive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final placeholderOptions = [
      {'key': 'all', 'title': 'All'},
      {'key': 'customer', 'title': 'Customer'},
      {'key': 'supplier', 'title': 'Supplier'},
      {'key': 'employee', 'title': 'Employee'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        for (int index = 0; index < placeholderOptions.length; index++) ...[
          _buildPlaceholderOptionItem(placeholderOptions[index], responsive),
          if (index < placeholderOptions.length - 1)
            Divider(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
              height: 1,
            ),
        ],
      ],
    );
  }

  Widget _buildPlaceholderOptionItem(Map<String, String> option, AdvancedResponsiveHelper responsive) {
    return _buildCommonFilterOption(
      option: option,
      responsive: responsive,
      isSelected: selectedPlaceholderOptions.contains(option['key']),
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          // Clear all selections and select only this one
          selectedPlaceholderOptions.clear();
          selectedPlaceholderOptions.add(option['key']!);
        });
      },
      isCheckboxStyle: true, // Checkbox style
    );
  }

  Widget _buildSortOptions(AdvancedResponsiveHelper responsive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        for (int index = 0; index < sortOptions.length; index++) ...[
          _buildSortOption(sortOptions[index], responsive),
          if (index < sortOptions.length - 1)
            Divider(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
              height: 1,
            ),
        ],
      ],
    );
  }

  // ✅ Common method for all filter option items
  Widget _buildCommonFilterOption({
    required Map<String, String> option,
    required AdvancedResponsiveHelper responsive,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isCheckboxStyle, // true = checkbox (square), false = radio (circle)
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(responsive.borderRadiusMedium),
        child: Container(
          margin: EdgeInsets.only(bottom: responsive.spacing(10)),
          padding: EdgeInsets.symmetric(
            horizontal: responsive.spacing(16),
            vertical: responsive.spacing(16),
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(responsive.borderRadiusMedium),
          ),
          child: Row(
            children: [
              Expanded(
                child: AppText.custom(
                  option['title']!,
                  style: AppFonts.appBarTitleMedium(
                    color: isDark ? AppColors.textWhite : AppColorsLight.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  maxLines: 2,
                  minFontSize: 10,
                ),
              ),
              SizedBox(width: responsive.spacing(5)),
              // ✅ Conditional rendering: Checkbox vs Radio button
              if (isCheckboxStyle)
                // Checkbox style (square with checkmark)
                Container(
                  width: responsive.fontSize(25),
                  height: responsive.fontSize(25),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                    color: isSelected
                        ? (isDark ? AppColors.containerDark : AppColorsLight.textPrimary.withOpacity(0.2))
                        : AppColors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? (isDark ? AppColors.transparent : AppColorsLight.textPrimary.withOpacity(0.0))
                          : (isDark ? AppColors.white.withOpacity(0.2) : AppColorsLight.textPrimary.withOpacity(0.5)),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Icon(
                            Icons.check,
                            color: isDark ? AppColors.white : AppColorsLight.black,
                            size: responsive.fontSize(20),
                          ),
                        )
                      : null,
                )
              else
                // Radio button style (circle with dot)
                Container(
                  width: responsive.fontSize(20),
                  height: responsive.fontSize(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? (isDark ? AppColors.containerDark : AppColorsLight.textPrimary.withOpacity(0.2))
                        : AppColors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? (isDark ? AppColors.white : AppColorsLight.textPrimary.withOpacity(0.3))
                          : (isDark ? AppColors.white.withOpacity(0.2) : AppColorsLight.textPrimary.withOpacity(0.4)),
                      width: isSelected ? 4.5 : 2.0,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: responsive.fontSize(8),
                            height: responsive.fontSize(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? AppColors.backgroundDark : AppColorsLight.black,
                            ),
                          ),
                        )
                      : null,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(SortOption option, AdvancedResponsiveHelper responsive) {
    return _buildCommonFilterOption(
      option: {'key': option.key, 'title': option.title},
      responsive: responsive,
      isSelected: selectedSortOption == option.key,
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          selectedSortOption = option.key;
        });
      },
      isCheckboxStyle: false, // Radio button style
    );
  }

}

class SortOption {
  final String key;
  final String title;

  SortOption({
    required this.key,
    required this.title,
  });
}