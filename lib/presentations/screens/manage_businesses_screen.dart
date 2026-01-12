import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../app/constants/app_icons.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_text.dart';
import '../../buttons/custom_floating_button.dart';
import '../../controllers/manage_businesses_controller.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/responsive_layout/padding_navigation.dart';
import '../../models/merchant_list_model.dart';
import '../widgets/custom_app_bar/custom_app_bar.dart';
import '../widgets/custom_app_bar/model/app_bar_config.dart';
import '../widgets/text_filed/custom_text_field.dart';
import 'business_detail_screen.dart';
import 'shop_detail_screen.dart';

class ManageBusinessesScreen extends StatefulWidget {
  const ManageBusinessesScreen({super.key});

  @override
  State<ManageBusinessesScreen> createState() => _ManageBusinessesScreenState();
}

class _ManageBusinessesScreenState extends State<ManageBusinessesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ManageBusinessesController _controller = Get.put(ManageBusinessesController());

  @override
  void dispose() {
    _searchController.dispose();
    Get.delete<ManageBusinessesController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.overlay : AppColorsLight.scaffoldBackground,
      appBar: CustomResponsiveAppBar(
        config: AppBarConfig(
          type: AppBarType.titleOnly,
          titleColor: isDark ? Colors.white : AppColorsLight.textPrimary,
          showBorder: true,
          customHeight: responsive.hp(12),
          customPadding: EdgeInsets.symmetric(horizontal: responsive.wp(2)),
          leadingWidget: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.arrow_back,
                  color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                  size: responsive.iconSizeLarge,
                ),
              ),
              SizedBox(width: responsive.wp(3)),
              AppText.custom(
                'My profile',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColorsLight.textPrimary,
                  fontSize: responsive.fontSize(20),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                minFontSize: 12,
                letterSpacing: 1.1,
              ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
              strokeWidth: 1,
            ),
          );
        }

        return RefreshIndicator(
          color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
          backgroundColor: isDark ? AppColors.containerDark : AppColorsLight.white,
          onRefresh: _controller.fetchMerchants,
          child: CustomScrollView(
            slivers: [
              // Business Stats Cards (Non-scrollable)
              SliverToBoxAdapter(
                child: _buildStatsCards(responsive, isDark),
              ),

              // Search Bar (Non-scrollable)
              SliverToBoxAdapter(
                child: _buildSearchBar(responsive, isDark),
              ),

              // Business Lists (Scrollable)
              _controller.filteredMerchants.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: AppText.custom(
                          'No businesses found',
                          style: TextStyle(
                            color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                            fontSize: responsive.fontSize(16),
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: EdgeInsets.all(responsive.wp(4)),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == 0) {
                              // All Businesses Section Header
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText.custom(
                                    'All Businesses',
                                    style: TextStyle(
                                      color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                                      fontSize: responsive.fontSize(14),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: responsive.hp(1)),
                                ],
                              );
                            } else if (index == _controller.filteredMerchants.length + 1) {
                              // Bottom spacing
                              return SizedBox(height: responsive.hp(10));
                            } else {
                              // Business Card
                              final merchant = _controller.filteredMerchants[index - 1];
                              return Column(
                                children: [
                                  _buildBusinessCard(
                                    merchant: merchant,
                                    responsive: responsive,
                                    isDark: isDark,
                                  ),
                                  if (index < _controller.filteredMerchants.length)
                                    Divider(
                                      color: isDark
                                          ? AppColors.white.withOpacity(0.1)
                                          : AppColorsLight.textSecondary.withOpacity(0.1),
                                      height: 1,
                                      thickness: 1,
                                      endIndent: responsive.wp(2),
                                      indent: responsive.wp(2),
                                    ),
                                ],
                              );
                            }
                          },
                          childCount: _controller.filteredMerchants.length + 2, // +2 for header and bottom spacing
                        ),
                      ),
                    ),
            ],
          ),
        );
      }),
      floatingActionButton: CustomFloatingActionButton(
        onPressed: () async {
          debugPrint('➕ Add Business tapped');
          final result = await Get.to(() => const ShopDetailScreen(isAddNewBusiness: true));
          // Refresh merchant list if new business was added
          if (result == true) {
            debugPrint('🔄 New business added - refreshing list');
            _controller.fetchMerchants();
          }
        },
        screenType: 'businesses',
        icon: Icons.add,
      ),
    );
  }

  Widget _buildStatsCards(AdvancedResponsiveHelper responsive, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: isDark
                ? AppColors.white.withOpacity(0.1)
                : AppColorsLight.splaceSecondary1.withOpacity(0.1),
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(responsive.wp(4)),
        child: Row(
          children: [
            // Total Businesses Card
            Expanded(
              child: Container(
                padding: EdgeInsets.all(responsive.wp(4)),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.containerLight : AppColorsLight.containerLight,
                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      AppIcons.shopDotBlueIc,
                      width: responsive.iconSizeLarge,
                      height: responsive.iconSizeLarge,
                    ),
                    SizedBox(height: responsive.hp(1)),
                    AppText.custom(
                      'Active businesses',
                      style: TextStyle(
                        color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                        fontSize: responsive.fontSize(14),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: responsive.hp(0.2)),
                    Obx(() => AppText.custom(
                      '${_controller.activeCount}',
                      style: TextStyle(
                        color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                        fontSize: responsive.fontSize(32),
                        fontWeight: FontWeight.w700,
                      ),
                    )),
                  ],
                ),
              ),
            ),

            SizedBox(width: responsive.wp(2)),

            // Inactive Businesses Card
            Expanded(
              child: Container(
                padding: EdgeInsets.all(responsive.wp(4)),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.containerLight : AppColorsLight.containerLight,
                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      AppIcons.shopDotIc,
                      width: responsive.iconSizeLarge,
                      height: responsive.iconSizeLarge,
                    ),
                    SizedBox(height: responsive.hp(1)),
                    AppText.custom(
                      'In-active businesses',
                      style: TextStyle(
                        color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                        fontSize: responsive.fontSize(14),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: responsive.hp(0.2)),
                    Obx(() => AppText.custom(
                      '${_controller.inactiveCount}',
                      style: TextStyle(
                        color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                        fontSize: responsive.fontSize(32),
                        fontWeight: FontWeight.w700,
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(AdvancedResponsiveHelper responsive, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(left: responsive.wp(4),right: responsive.wp(4),top: responsive.hp(2)),
      child: CustomTextField(
        controller: _searchController,
        hintText: 'Search for your businesses',
        prefixIcon: Padding(
          padding: EdgeInsets.all(responsive.wp(3)),
          child: SvgPicture.asset(
            AppIcons.searchIIc,
            width: responsive.iconSizeSmall,
            height: responsive.iconSizeSmall,
            colorFilter: ColorFilter.mode(
              isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
              BlendMode.srcIn,
            ),
          ),
        ),
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        onChanged: (value) {
          _controller.searchMerchants(value);
        },
      ),
    );
  }

  Widget _buildBusinessCard({
    required MerchantListModel merchant,
    required AdvancedResponsiveHelper responsive,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.containerLight : AppColorsLight.white,
        borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            debugPrint('🏢 Business tapped: ${merchant.businessName} (ID: ${merchant.merchantId})');
            debugPrint('   Address: ${merchant.formattedAddress}');
            debugPrint('   Phone: ${merchant.phone}');
            debugPrint('   isActive: ${merchant.isActive}');
            debugPrint('   isVerified: ${merchant.isVerified}');

            Get.to(() => BusinessDetailScreen(
              merchantId: merchant.merchantId,
              businessName: merchant.businessName,
              address: merchant.formattedAddress,
            ));
          },
          borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
          child: Padding(
            padding: EdgeInsets.all(responsive.wp(4)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.custom(
                        merchant.businessName,
                        style: TextStyle(
                          color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                          fontSize: responsive.fontSize(18),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: responsive.hp(0.3)),
                      AppText.custom(
                        merchant.formattedAddress.isNotEmpty
                            ? merchant.formattedAddress
                            : 'No address added',
                        style: TextStyle(
                          color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                          fontSize: responsive.fontSize(14),
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: responsive.wp(2)),
                Icon(
                  Icons.arrow_forward,
                  color: isDark ? AppColors.white : AppColorsLight.textSecondary,
                  size: responsive.iconSizeLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
