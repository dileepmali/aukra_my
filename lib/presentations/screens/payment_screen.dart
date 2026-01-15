import 'dart:math' as math;
import 'package:aukra_anantkaya_space/app/constants/app_images.dart';
import 'package:aukra_anantkaya_space/app/themes/app_text.dart';
import 'package:aukra_anantkaya_space/presentations/widgets/custom_border_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../app/constants/app_icons.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../buttons/app_button.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/responsive_layout/padding_navigation.dart';
import '../widgets/custom_app_bar/app_bar.dart';
import '../widgets/custom_app_bar/model/app_bar_config.dart';
import '../../buttons/custom_radio_button.dart';
import '../widgets/bottom_sheets/payment_qr_bottom_sheet.dart';
import 'payment_success_screen.dart';
import 'payment_error_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String planName;
  final String planPrice;
  final String planDuration;

  const PaymentScreen({
    Key? key,
    required this.planName,
    required this.planPrice,
    required this.planDuration,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPaymentMethod = 0; // 0 = UPI, 1 = Card, 2 = Net Banking
  int _selectedDuration = 0; // 0 = Month, 1 = Year

  @override
  void initState() {
    super.initState();
    debugPrint('💳 PaymentScreen initialized for ${widget.planName}');
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.overlay : AppColorsLight.scaffoldBackground,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(responsive.hp(12)),
          child: CustomResponsiveAppBar(
            config: AppBarConfig(
              type: AppBarType.titleOnly,
              customPadding: EdgeInsets.symmetric(horizontal: responsive.wp(2.5)),
              leadingWidget: InkWell(
                onTap: () {
                  debugPrint('🔙 Back button tapped in PaymentScreen');
                  Navigator.of(context).pop();
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back,
                      color: isDark ? Colors.white : AppColorsLight.textPrimary,
                      size: 25,
                    ),
                    SizedBox(width: 8),
                    AppText.searchbar2(
                      'Payment',
                      color: isDark ? Colors.white : AppColorsLight.textPrimary,
                      fontWeight: FontWeight.w500,
                      maxLines: 1,
                      minFontSize: 12,
                      letterSpacing: 1.1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(responsive.wp(4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan Summary Card
              _buildPlanSummaryCard(responsive, isDark),
              SizedBox(height: responsive.hp(2)),

              // Month and Year Package Selection
              _buildDurationSelection(responsive, isDark),
              SizedBox(height: responsive.hp(3)),

              // Payment Methods Container
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(responsive.wp(3)),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.containerDark : AppColorsLight.white,
                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Payment Methods Section Title
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.cardPostIc,
                          width: responsive.iconSizeLarge1,
                          height: responsive.iconSizeLarge1,
                        ),
                        SizedBox(width: responsive.wp(2)),
                        AppText.searchbar(
                          'Select Payment ',
                          color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                    SizedBox(height: responsive.hp(2)),

                    // Payment Method Options
                    _buildPaymentMethodCard(
                      responsive: responsive,
                      isDark: isDark,
                      index: 0,
                      title: 'GPay',
                    ),
                    SizedBox(height: responsive.hp(0.5)),

                    _buildPaymentMethodCard(
                      responsive: responsive,
                      isDark: isDark,
                      index: 1,
                      title: 'Cred',
                      imageIcon: AppImages.credIm,
                    ),
                    SizedBox(height: responsive.hp(0.5)),

                    _buildPaymentMethodCard(
                      responsive: responsive,
                      isDark: isDark,
                      index: 2,
                      title: 'BHIM',
                      imageIcon: AppImages.bhimIm,
                    ),
                    SizedBox(height: responsive.hp(0.5)),

                    _buildPaymentMethodCard(
                      responsive: responsive,
                      isDark: isDark,
                      index: 3,
                      title: 'Paytm',
                      imageIcon: AppImages.paytmIm,
                    ),
                    SizedBox(height: responsive.hp(0.5)),

                    _buildPaymentMethodCard(
                      responsive: responsive,
                      isDark: isDark,
                      index: 4,
                      title: 'Scan & pay using QR',
                      svgIcon: AppIcons.scanIc,
                    ),
                  ],
                ),
              ),
              SizedBox(height: responsive.hp(4)),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.wp(4),
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.overlay : AppColorsLight.scaffoldBackground,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pay Button
                AppButton(
                  text: 'Pay ₹${widget.planPrice}',
                  width: double.infinity,
                  height: responsive.hp(7),
                  gradientColors: isDark
                      ? [AppColors.splaceSecondary1, AppColors.splaceSecondary2]
                      : [AppColorsLight.gradientColor1, AppColorsLight.gradientColor2],
                  textColor: Colors.white,
                  fontSize: responsive.fontSize(16),
                  fontWeight: FontWeight.w600,
                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                  onPressed: () {
                    debugPrint('💰 Pay button tapped for ${widget.planName}');
                    // Open QR Payment Bottom Sheet
                    PaymentQRBottomSheet.show(
                      context,
                      planName: widget.planName,
                      planPrice: widget.planPrice,
                      planDuration: widget.planDuration,
                    );
                  },
                ),
                SizedBox(height: responsive.hp(1)),


              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanSummaryCard(AdvancedResponsiveHelper responsive, bool isDark) {
    // Calculate yearly price (monthly price * 12 with 20% discount)
    final monthlyPrice = int.tryParse(widget.planPrice) ?? 0;
    final yearlyPrice = (monthlyPrice * 12 * 0.8).round(); // 20% discount

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.wp(4)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: isDark
              ? [
                  AppColors.containerLight,
                  AppColors.containerLight,
                ]
              : [
                AppColorsLight.gradientColor1,
                AppColorsLight.gradientColor1,
          ],
        ),
        borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SVG icon on top
          SvgPicture.asset(
            AppIcons.boxIc,
            width: responsive.iconSizeLarge1,
            height: responsive.iconSizeLarge1,
          ),
          SizedBox(height: responsive.hp(1.5)),

          // Plan name and price in same row below icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Plan name on left
              AppText.searchbar(
                '${widget.planName} Plan',
                color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              // Price on right with rupee icon and duration
              Row(
                children: [
                  SvgPicture.asset(
                    AppIcons.vectoeIc3,
                    width: responsive.iconSizeSmall,
                    height: responsive.iconSizeSmall,
                  ),
                  SizedBox(width: responsive.wp(1)),
                  AppText.searchbar2(
                    _selectedDuration == 0 ? widget.planPrice : yearlyPrice.toString(),
                    color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  AppText.searchbar2(
                    _selectedDuration == 0 ? '/30 Days' : '/1 Year',
                    color: isDark ? AppColors.white : AppColorsLight.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSelection(AdvancedResponsiveHelper responsive, bool isDark) {
    // Calculate yearly price (monthly price * 12 with 20% discount)
    final monthlyPrice = int.tryParse(widget.planPrice) ?? 0;
    final yearlyPrice = (monthlyPrice * 12 ).round();

    return Row(
      children: [
        // Month Package Container
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDuration = 0;
              });
            },
            child: BorderColor(
              isSelected: _selectedDuration == 0,
              child: Container(
                padding: EdgeInsets.all(responsive.wp(3)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [AppColors.containerLight, AppColors.containerDark]
                        : [AppColorsLight.gradientColor1, AppColorsLight.gradientColor2],
                  ),
                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                ),
              child: Column(
                children: [
                  // Title row with text on left and radio button on right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.searchbar2(
                        'Monthly',
                        color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                        fontWeight: FontWeight.w500,
                        maxLines: 1,
                        minFontSize: 12,
                      ),
                      // Radio button
                      CustomRadioButton(
                        isSelected: _selectedDuration == 0,
                        size: responsive.fontSize(18),
                        innerSize: responsive.fontSize(6),
                        selectedBorderWidth: 4.0,
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.hp(1.5)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        AppIcons.vectoeIc3,
                        width: responsive.iconSizeSmall,
                        height: responsive.iconSizeSmall,
                      ),
                      SizedBox(width: responsive.wp(0.5)),
                      AppText.displayMedium3(
                        widget.planPrice,
                        color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.hp(1.5)),
                  // Duration text

                  // Gradient Divider Line
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: isDark
                            ? [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.6),
                                Colors.white.withOpacity(0.8),
                                Colors.white.withOpacity(0.6),
                                Colors.white.withOpacity(0.1),
                              ]
                            : [
                                AppColorsLight.splaceSecondary1.withOpacity(0.1),
                                AppColorsLight.splaceSecondary1.withOpacity(0.6),
                                AppColorsLight.splaceSecondary1.withOpacity(0.8),
                                AppColorsLight.splaceSecondary1.withOpacity(0.6),
                                AppColorsLight.splaceSecondary1.withOpacity(0.1),
                              ],
                        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                      ),
                    ),
                  ),
                  SizedBox(height: responsive.hp(1.5)),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppText.searchbar1(
                      '30 Days',
                      color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              ),
            ),
          ),
        ),
        SizedBox(width: responsive.wp(3)),
        // Year Package Container
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDuration = 1;
              });
            },
            child: BorderColor(
              isSelected: _selectedDuration == 1,
              child: Container(
                padding: EdgeInsets.all(responsive.wp(3)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [AppColors.splaceSecondary1, AppColors.splaceSecondary2]
                        : [AppColorsLight.gradientColor1, AppColorsLight.gradientColor2],
                  ),
                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                ),
              child: Column(
                children: [
                  // Title row with radio button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.searchbar2(
                        'Annual',
                        color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                        fontWeight: FontWeight.w500,
                        maxLines: 1,
                        minFontSize: 12,
                      ),
                      // Radio button
                      CustomRadioButton(
                        isSelected: _selectedDuration == 1,
                        size: responsive.fontSize(18),
                        innerSize: responsive.fontSize(6),
                        selectedBorderWidth: 4.0,
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.hp(1.5)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        AppIcons.vectoeIc3,
                        width: responsive.iconSizeSmall,
                        height: responsive.iconSizeSmall,
                      ),
                      SizedBox(width: responsive.wp(0.5)),
                      AppText.displayMedium3(
                        yearlyPrice.toString(),
                        color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.hp(1.5)),
                  // Duration text

                  // Gradient Divider Line
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: isDark
                            ? [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.6),
                                Colors.white.withOpacity(0.8),
                                Colors.white.withOpacity(0.6),
                                Colors.white.withOpacity(0.1),
                              ]
                            : [
                                AppColorsLight.splaceSecondary1.withOpacity(0.1),
                                AppColorsLight.splaceSecondary1.withOpacity(0.6),
                                AppColorsLight.splaceSecondary1.withOpacity(0.8),
                                AppColorsLight.splaceSecondary1.withOpacity(0.6),
                                AppColorsLight.splaceSecondary1.withOpacity(0.1),
                              ],
                        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                      ),
                    ),
                  ),
                  SizedBox(height: responsive.hp(1.5)),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '12 Months',
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              decorationColor: isDark ? AppColors.white : AppColorsLight.textSecondary,
                              color: isDark ? AppColors.white : AppColorsLight.textSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: responsive.fontSize(14),
                            ),
                          ),
                          TextSpan(
                            text: ' 13 Months',
                            style: TextStyle(
                              color: isDark ? AppColors.white : AppColorsLight.textSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: responsive.fontSize(14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard({
    required AdvancedResponsiveHelper responsive,
    required bool isDark,
    required int index,
    required String title,
    String? imageIcon,
    String? svgIcon,
  }) {
    final isSelected = _selectedPaymentMethod == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = index;
        });
        debugPrint('💳 Selected payment method: $title');
      },
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: responsive.hp(7),
        padding: EdgeInsets.symmetric(
          horizontal: responsive.wp(3),
        ),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.containerLight
              : AppColorsLight.blue,
          borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon container - fixed width for all cards to align titles
            SizedBox(
              width: responsive.wp(15),
              child: svgIcon != null
                  ? SvgPicture.asset(
                      svgIcon,
                      width: responsive.wp(13),
                      height: responsive.hp(4),
                      fit: BoxFit.contain,
                    )
                  : imageIcon != null
                      ? Image.asset(
                          imageIcon,
                          width: responsive.wp(15),
                          height: responsive.hp(5),
                          fit: BoxFit.contain,
                        )
                      : null, // Empty space for cards without icons
            ),
            SizedBox(width: responsive.wp(2)),
            // Title
            Expanded(
              child: AppText.searchbar1(
                title,
                color: AppColors.white,
                fontWeight: FontWeight.w500,
                maxLines: 1,
                minFontSize: 10,
                letterSpacing: 1.0,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            SizedBox(width: responsive.wp(2)),

            // Right side: Radio button
            CustomRadioButton(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}