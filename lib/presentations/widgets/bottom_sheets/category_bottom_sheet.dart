import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_text.dart';
import '../../../app/themes/app_fonts.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../custom_single_border_color.dart';
import '../text_filed/custom_text_field.dart';

class CategoryBottomSheet extends StatefulWidget {
  final String? selectedCategory;

  const CategoryBottomSheet({
    Key? key,
    this.selectedCategory,
  }) : super(key: key);

  static Future<String?> show({
    required BuildContext context,
    String? selectedCategory,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: isDark ? Colors.black : AppColorsLight.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => CategoryBottomSheet(
        selectedCategory: selectedCategory,
      ),
    );
  }

  @override
  State<CategoryBottomSheet> createState() => _CategoryBottomSheetState();
}

class _CategoryBottomSheetState extends State<CategoryBottomSheet> {
  late String? _tempSelectedCategory;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _tempSelectedCategory = widget.selectedCategory;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final responsive = AdvancedResponsiveHelper(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final categories = [
      {'key': 'category1', 'title': 'Grocery Store'},
      {'key': 'category2', 'title': 'Hardware Store'},
      {'key': 'category3', 'title': 'Pet Store'},
      {'key': 'category4', 'title': 'Coffee Store'},
      {'key': 'category5', 'title': 'Book Store'},
      {'key': 'category6', 'title': 'Auto Repair'},
      {'key': 'category7', 'title': 'Laundromat '},
      {'key': 'category8', 'title': 'Lawyer '},
      {'key': 'category9', 'title': 'Accountant '},
      {'key': 'category10', 'title': 'Financial Advisor '},
      {'key': 'category11', 'title': 'Real Estate Agent '},
      {'key': 'category12', 'title': 'Insurance Agency'},
      {'key': 'category13', 'title': 'Marketing Agency '},
    ];

    final bottomSheetHeight = responsive.hp(80) + bottomPadding;

    return Stack(
      children: [
        Container(
          height: bottomSheetHeight,
          decoration: BoxDecoration(
            color: isDark ? AppColors.containerLight: AppColorsLight.scaffoldBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            bottom: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top spacing and drag handle
                SizedBox(height: responsive.hp(1.5)),
                Center(
                  child: Container(
                    width: responsive.wp(12),
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.white : AppColorsLight.textPrimary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(responsive.borderRadiusMedium),
                    ),
                  ),
                ),

                SizedBox(height: responsive.hp(2)),

                // Title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: responsive.wp(5)),
                  child: AppText.custom(
                    'Select business Category',
                    style: TextStyle(
                      color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                      fontSize: responsive.fontSize(20),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(height: responsive.hp(2)),

                // Search TextField
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: responsive.wp(5)),
                  child: CustomTextField(
                    controller: _searchController,
                    hintText: 'Search category...',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(responsive.spacing(12)),
                      child: SvgPicture.asset(
                        AppIcons.searchIIc,
                        colorFilter: ColorFilter.mode(
                          isDark ? AppColors.white.withOpacity(0.6) : AppColorsLight.textSecondary,
                          BlendMode.srcIn,
                        ),
                        width: responsive.iconSizeSmall,
                        height: responsive.iconSizeSmall,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        // Filter will be applied in the ListView
                      });
                    },
                    borderRadius: responsive.borderRadiusSmall,
                  ),
                ),

                SizedBox(height: responsive.hp(2)),

                // Divider line
                Divider(
                  color: isDark ? Colors.white.withOpacity(0.1) : AppColorsLight.textPrimary.withOpacity(0.2),
                  thickness: 0.9,
                  height: 1,
                ),

                // Category options with radio buttons
                Expanded(
                  child: Builder(
                    builder: (context) {
                      // Filter categories based on search
                      final searchQuery = _searchController.text.toLowerCase();
                      final filteredCategories = searchQuery.isEmpty
                          ? categories
                          : categories.where((category) {
                              final title = (category['title'] as String).toLowerCase();
                              return title.contains(searchQuery);
                            }).toList();

                      return ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: responsive.wp(1)),
                        itemCount: filteredCategories.length,
                        separatorBuilder: (context, index) => Divider(
                          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                          height: 1,
                          indent: responsive.wp(2),
                          endIndent: responsive.wp(2),
                        ),
                        itemBuilder: (context, index) {
                          final category = filteredCategories[index];
                          final title = category['title'] as String;
                          final key = category['key'] as String;
                          final isSelected = key == _tempSelectedCategory;

                          return _buildCategoryOption(
                            title: title,
                            key: key,
                            isSelected: isSelected,
                            responsive: responsive,
                            isDark: isDark,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _tempSelectedCategory = key;
                              });
                              // Auto close after selection
                              Future.delayed(const Duration(milliseconds: 300), () {
                                if (mounted) {
                                  Navigator.of(context).pop(title);
                                }
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Border widget
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
      ],
    );
  }

  Widget _buildCategoryOption({
    required String title,
    required String key,
    required bool isSelected,
    required AdvancedResponsiveHelper responsive,
    required bool isDark,
    required VoidCallback onTap,
  }) {
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
                  title,
                  style: AppFonts.appBarTitleMedium(
                    color: isDark ? AppColors.textWhite : AppColorsLight.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  maxLines: 2,
                  minFontSize: 10,
                ),
              ),
              SizedBox(width: responsive.spacing(5)),
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
}
