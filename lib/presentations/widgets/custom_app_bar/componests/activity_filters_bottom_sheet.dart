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

class ActivityFiltersBottomSheet extends StatefulWidget {
  final Map<String, String>? groupByOptions;
  final Function(Map<String, dynamic>)? onFiltersApplied;
  final String? initialGroupBy;
  final String? initialSortBy;
  final String? initialSortOrder;

  const ActivityFiltersBottomSheet({
    Key? key,
    this.groupByOptions,
    this.onFiltersApplied,
    this.initialGroupBy,
    this.initialSortBy,
    this.initialSortOrder,
  }) : super(key: key);

  @override
  State<ActivityFiltersBottomSheet> createState() => _ActivityFiltersBottomSheetState();
}

class _ActivityFiltersBottomSheetState extends State<ActivityFiltersBottomSheet> {
  String selectedFilter = 'Sort by';
  String selectedSortOption = 'activity_desc'; // ✅ Default: Latest activities first (Time: Newest First)
  String selectedGroupByOption = '';
  bool isLoadingState = false;

  late Map<String, String> groupByOptions;

  @override
  void initState() {
    super.initState();
    // Default group by options for activities
    groupByOptions = widget.groupByOptions ?? {
      'All': '',  // No icon for All
      'Create': AppIcons.editIc,
      'Delete': AppIcons.deleteIc,
      'Move': AppIcons.documentForwardIc,
      'Share': AppIcons.shareIc,
    };

    // Restore previous selections if provided
    if (widget.initialGroupBy != null) {
      selectedGroupByOption = _getGroupByKeyFromValue(widget.initialGroupBy!);
    } else if (selectedGroupByOption.isEmpty && groupByOptions.isNotEmpty) {
      selectedGroupByOption = groupByOptions.keys.first;
    }

    if (widget.initialSortBy != null && widget.initialSortOrder != null) {
      selectedSortOption = _getSortKeyFromValues(widget.initialSortBy!, widget.initialSortOrder!);
    }
  }

  // Convert API groupBy value to UI key
  String _getGroupByKeyFromValue(String apiValue) {
    switch (apiValue) {
      case 'all': return 'All';
      case 'create': return 'Create';
      case 'delete': return 'Delete';
      case 'move': return 'Move';
      case 'share': return 'Share';
      default: return 'All';
    }
  }

  // Convert API sortBy/sortOrder to UI key
  String _getSortKeyFromValues(String sortBy, String sortOrder) {
    if (sortBy == 'name' && sortOrder == 'asc') return 'name_az';
    if (sortBy == 'name' && sortOrder == 'desc') return 'name_za';
    if (sortBy == 'time' && sortOrder == 'asc') return 'activity_asc';
    if (sortBy == 'time' && sortOrder == 'desc') return 'activity_desc';
    return 'name_az';
  }

  // Get localized group by title
  String _getLocalizedGroupByTitle(BuildContext context, String groupByKey) {
    switch (groupByKey) {
      case 'All':
        return AppStrings.getLocalizedString(context, (localizations) => localizations.everything);
      case 'Create':
        return AppStrings.getLocalizedString(context, (localizations) => localizations.create);
      case 'Delete':
        return AppStrings.getLocalizedString(context, (localizations) => localizations.delete);
      case 'Move':
        return AppStrings.getLocalizedString(context, (localizations) => localizations.move);
      case 'Share':
        return AppStrings.getLocalizedString(context, (localizations) => localizations.share);
      default:
        return groupByKey;
    }
  }

  List<SortOption> get sortOptions => [
    SortOption(
      key: 'name_az',
      title: AppStrings.getLocalizedString(context, (localizations) => localizations.nameAZ),
    ),
    SortOption(
      key: 'name_za',
      title: AppStrings.getLocalizedString(context, (localizations) => localizations.nameZA),
    ),
    SortOption(
      key: 'activity_asc',
      title: AppStrings.getLocalizedString(context, (localizations) => localizations.activityAsc),
    ),
    SortOption(
      key: 'activity_desc',
      title: AppStrings.getLocalizedString(context, (localizations) => localizations.activityDesc),
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
                          onTap: () => setState(() => selectedFilter = 'Group by'),
                          child: _buildSidebarItem(
                            AppStrings.getLocalizedString(context, (localizations) => localizations.groupBy),
                            selectedFilter == 'Group by',
                            responsive
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main Content
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(responsive.spacing(20)),
                      child: _buildMainContent(responsive),
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
                  // Map group by options to API values
                  String groupByValue = 'all';
                  switch (selectedGroupByOption) {
                    case 'All':
                      groupByValue = 'all';
                      break;
                    case 'Create':
                      groupByValue = 'create';
                      break;
                    case 'Delete':
                      groupByValue = 'delete';
                      break;
                    case 'Move':
                      groupByValue = 'move';
                      break;
                    case 'Share':
                      groupByValue = 'share';
                      break;
                    default:
                      groupByValue = 'all';
                  }

                  // Map sort options to API values
                  String sortBy = 'name';
                  String sortOrder = 'asc';

                  switch (selectedSortOption) {
                    case 'name_az':
                      sortBy = 'name';
                      sortOrder = 'asc';
                      break;
                    case 'name_za':
                      sortBy = 'name';
                      sortOrder = 'desc';
                      break;
                    case 'activity_asc':
                      sortBy = 'time';
                      sortOrder = 'asc';
                      break;
                    case 'activity_desc':
                      sortBy = 'time';
                      sortOrder = 'desc';
                      break;
                    default:
                      sortBy = 'name';
                      sortOrder = 'asc';
                  }

                  final result = {
                    'groupBy': groupByValue,
                    'sortBy': sortBy,
                    'sortOrder': sortOrder,
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
      case 'Group by':
      default:
        return _buildGroupByOptions(responsive);
    }
  }

  Widget _buildSortOptions(AdvancedResponsiveHelper responsive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildSortOption(SortOption option, AdvancedResponsiveHelper responsive) {
    final isSelected = selectedSortOption == option.key;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            selectedSortOption = option.key;
          });
        },
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
                  option.title,
                  style: AppFonts.appBarTitleMedium(
                    color: isDark ? AppColors.textWhite : AppColorsLight.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  maxLines: 2,
                  minFontSize: 10,
                ),
              ),
              SizedBox(width: responsive.spacing(5)),
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

  Widget _buildGroupByOptions(AdvancedResponsiveHelper responsive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final entries = groupByOptions.entries.toList();

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for (int index = 0; index < entries.length; index++) ...[
            _buildGroupByOption(
              entries[index].key,
              entries[index].value,
              responsive,
            ),
            if (index < entries.length - 1)
              Divider(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                thickness: 1.0,
                height: 1,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildGroupByOption(String title, String iconPath, AdvancedResponsiveHelper responsive) {
    final isSelected = selectedGroupByOption == title;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            selectedGroupByOption = title;
          });
        },
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
              // Icon (if path is not empty)
              if (iconPath.isNotEmpty) ...[
                SvgPicture.asset(
                  iconPath,
                  width: responsive.fontSize(24),
                  height: responsive.fontSize(24),
                  colorFilter: ColorFilter.mode(
                    isDark ? AppColors.textGrey : AppColorsLight.textSecondary,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: responsive.spacing(15)),
              ],

              // Title
              Expanded(
                child: AppText.custom(
                  _getLocalizedGroupByTitle(context, title),
                  style: AppFonts.appBarTitleMedium(
                    color: isDark ? AppColors.textWhite : AppColorsLight.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  maxLines: 2,
                  minFontSize: 10,
                ),
              ),

              // Checkbox
              SizedBox(width: responsive.spacing(12)),
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
              ),
            ],
          ),
        ),
      ),
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