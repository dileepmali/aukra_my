import 'package:aukra_anantkaya_space/app/constants/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_text.dart';
import '../../../app/themes/app_fonts.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../../../controllers/ledger_controller.dart';
import '../../../buttons/app_button.dart';
import '../custom_single_border_color.dart';
import '../text_filed/custom_text_field.dart';

class ManagerBottomSheet extends StatefulWidget {
  final String? selectedManager;

  const ManagerBottomSheet({
    Key? key,
    this.selectedManager,
  }) : super(key: key);

  static Future<String?> show({
    required BuildContext context,
    String? selectedManager,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: isDark ? Colors.black : AppColorsLight.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => ManagerBottomSheet(
        selectedManager: selectedManager,
      ),
    );
  }

  @override
  State<ManagerBottomSheet> createState() => _ManagerBottomSheetState();
}

class _ManagerBottomSheetState extends State<ManagerBottomSheet> {
  late String? _tempSelectedManager;
  final TextEditingController _searchController = TextEditingController();
  LedgerController get _ledgerController => Get.find<LedgerController>();

  @override
  void initState() {
    super.initState();
    _tempSelectedManager = widget.selectedManager;

    // Ensure we have fresh employee data
    if (_ledgerController.employers.isEmpty) {
      _ledgerController.refreshAll();
    }
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
                  child: AppText.searchbar2(
                    'Select Manager',
                    color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: responsive.hp(2)),

                // Search TextField
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: responsive.wp(5)),
                  child: CustomTextField(
                    controller: _searchController,
                    hintText: 'Search manager...',
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

                // Manager options with radio buttons
                Expanded(
                  child: Obx(() {
                    // Show loading indicator
                    if (_ledgerController.isLoading.value) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
                          strokeWidth: 2.0,
                        ),
                      );
                    }

                    // Get employees from ledger controller
                    final employees = _ledgerController.employers;

                    // Filter employees based on search
                    final searchQuery = _searchController.text.toLowerCase();
                    final filteredEmployees = searchQuery.isEmpty
                        ? employees
                        : employees.where((employee) {
                            final name = employee.name.toLowerCase();
                            return name.contains(searchQuery);
                          }).toList();

                    // Show empty state if no employees
                    if (filteredEmployees.isEmpty) {
                      return _buildEmptyState(responsive, isDark);
                    }

                    return ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: responsive.wp(1)),
                      itemCount: filteredEmployees.length,
                      separatorBuilder: (context, index) => Divider(
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                        height: 1,
                        indent: responsive.wp(2),
                        endIndent: responsive.wp(2),
                      ),
                      itemBuilder: (context, index) {
                        final employee = filteredEmployees[index];
                        final isSelected = employee.name == _tempSelectedManager;

                        return _buildManagerOption(
                          title: employee.name,
                          key: employee.id.toString(),
                          isSelected: isSelected,
                          responsive: responsive,
                          isDark: isDark,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _tempSelectedManager = employee.name;
                            });
                            // Auto close after selection
                            Future.delayed(const Duration(milliseconds: 300), () {
                              if (mounted) {
                                Navigator.of(context).pop(employee.name);
                              }
                            });
                          },
                        );
                      },
                    );
                  }),
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

  Widget _buildManagerOption({
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
                child: AppText.searchbar1(
                  title,
                  color: isDark ? AppColors.textWhite : AppColorsLight.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildEmptyState(AdvancedResponsiveHelper responsive, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(top: responsive.wp(8),left: responsive.wp(8),right: responsive.wp(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Empty state icon
          Image.asset(
            AppImages.foundErrorIm,
            width: responsive.wp(45),
            height: responsive.wp(45),
            fit: BoxFit.contain,
          ),
          // Empty state title
          AppText.displayMedium3(
            'No Results found ',
            color: isDark ? AppColors.white : AppColorsLight.textPrimary,
            fontWeight: FontWeight.w500,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: responsive.hp(0.5)),

          // Empty state description
          AppText.searchbar1(
            'Try adjusting your search or filter to find what your looking for.',
            color: isDark
              ? AppColors.white.withOpacity(0.6)
              : AppColorsLight.textSecondary,
            fontWeight: FontWeight.w400,
            textAlign: TextAlign.start,
            maxLines: 3,
          ),

          SizedBox(height: responsive.hp(3)),

          // Add Employee Button
          AppButton(
            text: 'Create new Manager',
            onPressed: () async {
              debugPrint('🚀 Create new Manager button tapped');

              // Close the bottom sheet first
              Navigator.of(context).pop();

              // Navigate to customer form screen with partyType='employee'
              await Get.toNamed('/customer-form', arguments: {
                'partyType': 'employee',
                'isEditMode': false,
              });

              // Refresh employee data after returning from form
              _ledgerController.refreshAll();
            },
            width: double.infinity,
            height: responsive.hp(6),
            borderColor: isDark ? AppColors.driver : AppColorsLight.container,
            gradientColors:
            isDark
            ?
            [
              AppColors.containerLight,
              AppColors.containerDark,
            ]
            :
            [
              AppColors.containerDark,
              AppColors.containerLight,
            ],
            textColor: Colors.white,
            fontSize: responsive.fontSize(18),
            fontWeight: FontWeight.w600,
            borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
          ),
        ],
      ),
    );
  }
}
