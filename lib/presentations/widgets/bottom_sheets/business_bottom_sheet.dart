import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_text.dart';
import '../../../core/api/merchant_list_api.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../../../models/merchant_list_model.dart';
import '../custom_single_border_color.dart';
import '../text_filed/custom_text_field.dart';

class BusinessBottomSheet extends StatefulWidget {
  final int? selectedMerchantId;

  const BusinessBottomSheet({
    Key? key,
    this.selectedMerchantId,
  }) : super(key: key);

  static Future<MerchantListModel?> show({
    required BuildContext context,
    int? selectedMerchantId,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet<MerchantListModel>(
      context: context,
      backgroundColor: isDark ? Colors.black : AppColorsLight.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => BusinessBottomSheet(
        selectedMerchantId: selectedMerchantId,
      ),
    );
  }

  @override
  State<BusinessBottomSheet> createState() => _BusinessBottomSheetState();
}

class _BusinessBottomSheetState extends State<BusinessBottomSheet> {
  int? _tempSelectedMerchantId;
  final TextEditingController _searchController = TextEditingController();
  final MerchantListApi _merchantApi = MerchantListApi();

  List<MerchantListModel> _merchants = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tempSelectedMerchantId = widget.selectedMerchantId;
    _fetchMerchants();
  }

  Future<void> _fetchMerchants() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final merchants = await _merchantApi.getAllMerchants();

      if (mounted) {
        setState(() {
          _merchants = merchants;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error fetching merchants: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load businesses';
          _isLoading = false;
        });
      }
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

    final bottomSheetHeight = responsive.hp(70) + bottomPadding;

    return Stack(
      children: [
        Container(
          height: bottomSheetHeight,
          decoration: BoxDecoration(
            color: isDark ? AppColors.containerLight : AppColorsLight.scaffoldBackground,
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
                    width: responsive.wp(20),
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.containerDark : AppColorsLight.textPrimary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(responsive.borderRadiusMedium),
                    ),
                  ),
                ),
                SizedBox(height: responsive.hp(2)),

                // Title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: responsive.wp(5)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.searchbar2(
                        'Select Business',
                        color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.1,
                      ),
                      // Business count
                      if (!_isLoading)
                        AppText.headlineLarge1(
                          '${_merchants.length} Businesses',
                          color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                    ],
                  ),
                ),

                SizedBox(height: responsive.hp(2)),

                // Search TextField
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: responsive.wp(5)),
                  child: CustomTextField(
                    controller: _searchController,
                    hintText: 'Search business...',
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

                // Business options with radio buttons
                Expanded(
                  child: _buildContent(responsive, isDark),
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

  Widget _buildContent(AdvancedResponsiveHelper responsive, bool isDark) {
    // Show loading state
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: isDark ? AppColors.white : AppColorsLight.textPrimary,
            ),
            SizedBox(height: responsive.hp(2)),
            AppText.searchbar1(
              'Loading businesses...',
              color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
            ),
          ],
        ),
      );
    }

    // Show error state
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: responsive.iconSizeExtraLarge * 2,
              color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
            ),
            SizedBox(height: responsive.hp(2)),
            AppText.searchbar1(
              _errorMessage!,
              color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
            ),
            SizedBox(height: responsive.hp(2)),
            TextButton(
              onPressed: _fetchMerchants,
              child: AppText.searchbar1(
                'Retry',
                color: isDark ? AppColors.white : AppColorsLight.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    // Filter businesses based on search
    final searchQuery = _searchController.text.toLowerCase();
    final filteredMerchants = searchQuery.isEmpty
        ? _merchants
        : _merchants.where((merchant) {
            final name = merchant.businessName.toLowerCase();
            final address = merchant.formattedAddress.toLowerCase();
            final type = (merchant.businessType ?? '').toLowerCase();
            return name.contains(searchQuery) ||
                address.contains(searchQuery) ||
                type.contains(searchQuery);
          }).toList();

    // Show empty state
    if (filteredMerchants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: responsive.iconSizeExtraLarge * 2,
              color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
            ),
            SizedBox(height: responsive.hp(2)),
            AppText.searchbar1(
              searchQuery.isEmpty
                  ? 'No businesses found'
                  : 'No results for "$searchQuery"',
              color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: responsive.wp(1)),
      itemCount: filteredMerchants.length,
      separatorBuilder: (context, index) => Divider(
        color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
        height: 1,
        indent: responsive.wp(2),
        endIndent: responsive.wp(2),
      ),
      itemBuilder: (context, index) {
        final merchant = filteredMerchants[index];
        final isSelected = merchant.merchantId == _tempSelectedMerchantId;

        return _buildBusinessOption(
          merchant: merchant,
          isSelected: isSelected,
          responsive: responsive,
          isDark: isDark,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _tempSelectedMerchantId = merchant.merchantId;
            });
            // Auto close after selection
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                Navigator.of(context).pop(merchant);
              }
            });
          },
        );
      },
    );
  }

  Widget _buildBusinessOption({
    required MerchantListModel merchant,
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
              // Business details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.searchbar1(
                      merchant.businessName,
                      color: isDark ? AppColors.textWhite : AppColorsLight.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      maxLines: 1,
                      minFontSize: 10,
                    ),
                    if (merchant.formattedAddress.isNotEmpty) ...[
                      SizedBox(height: responsive.spacing(4)),
                      AppText.headlineLarge1(
                        merchant.formattedAddress,
                        color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                        fontWeight: FontWeight.w400,
                        maxLines: 2,
                        minFontSize: 10,
                      ),
                    ],
                  ],
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
