import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_text.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../../widgets/custom_border_widget.dart';
import '../../../buttons/custom_radio_button.dart';
import '../../routes/app_routes.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../buttons/app_button.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../widgets/custom_app_bar/app_bar.dart';
import '../../widgets/custom_app_bar/model/app_bar_config.dart';

class MyPlanScreen extends StatefulWidget {
  const MyPlanScreen({Key? key}) : super(key: key);

  @override
  State<MyPlanScreen> createState() => _MyPlanScreenState();
}

class _MyPlanScreenState extends State<MyPlanScreen> {
  int _selectedPlanIndex = 0; // 0 = Basic, 1 = Gold, 2 = Platinum

  @override
  void initState() {
    super.initState();
    debugPrint('📋 MyPlanScreen initialized');
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
                  debugPrint('🔙 Back button tapped in MyPlanScreen');
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
                      'My Plan',
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
              // Warning Container
              _buildWarningContainer(responsive, isDark),
              SizedBox(height: responsive.hp(2)),

              // Plan 1 - Basic
              _buildPlanCard(
                responsive: responsive,
                isDark: isDark,
                planIndex: 0,
                planName: 'Basic',
                planPrice: '75',
                planDuration: '/30 Days',
                planDescription: 'Perfect for getting started',
                planColor: isDark ? AppColors.white : Colors.grey.shade600,
                features: [
                  '2 Mobile phone access + 2 Desktop ',
                  '1 Shops',
                  '1 year Images backup',
                  '1 year data backup',
                  'Customers limit up-to 1000',
                  'Manual Whatsapp reminders',
                  'Standard support',
                ],
                isCurrentPlan: _selectedPlanIndex == 0,
              ),
              SizedBox(height: responsive.hp(2)),

              // Plan 2 - Gold
              _buildPlanCard(
                responsive: responsive,
                isDark: isDark,
                planIndex: 1,
                planName: 'Gold',
                planPrice: '199',
                planDuration: '/30 Days',
                planDescription: 'Best for growing businesses',
                planColor: isDark ? AppColors.white : Colors.grey.shade600,
                features: [
                  '5 Mobile phone access + 2 Desktop ',
                  '10 Shops',
                  '2 year Images backup',
                  '2 year data backup',
                  'Customers limit up-to 2499',
                  'Ai call reminders (60 per month)',
                  'Ai whatsapp reminders (100 per month)',
                  'Priority support',
                ],
                isCurrentPlan: _selectedPlanIndex == 1,
              ),
              SizedBox(height: responsive.hp(2)),

              // Plan 3 - Platinum
              _buildPlanCard(
                responsive: responsive,
                isDark: isDark,
                planIndex: 2,
                planName: 'Platinum',
                planPrice: '599',
                planDuration: '/30 Days',
                planDescription: 'For enterprise level businesses',
                planColor: isDark ? AppColors.white : Colors.grey.shade600,
                features: [
                  'Unlimited mobile & desktop access',
                  'Unlimited shops',
                  'Unlimited images backup',
                  'Unlimited data backup',
                  'Unlimited customers',
                  'Ai call reminders (300 per month)',
                  'Ai whatsapp reminders (999 per month)',
                  'Priority support',
                ],
                isCurrentPlan: _selectedPlanIndex == 2,
              ),
              SizedBox(height: responsive.hp(4)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required AdvancedResponsiveHelper responsive,
    required bool isDark,
    required int planIndex,
    required String planName,
    required String planPrice,
    required String planDuration,
    required String planDescription,
    required Color planColor,
    required List<String> features,
    required bool isCurrentPlan,
    bool isPopular = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        BorderColor(
          isSelected: true,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(responsive.wp(4)),
            decoration: BoxDecoration(
              color: isDark ? AppColors.containerLight : AppColorsLight.white,
              borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan Header - Icon and Radio button row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // SVG icon on left
                    SvgPicture.asset(
                      AppIcons.boxIc,
                      width: responsive.iconSizeLarge1,
                      height: responsive.iconSizeLarge1,
                    ),
                    // Radio button on right side
                    CustomRadioButton(isSelected: isCurrentPlan),
                  ],
                ),
                SizedBox(height: responsive.hp(1.5)),

                // Plan Title and Price in same row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Plan name on left
                    AppText.searchbar(
                      planName,
                      color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    // Plan price on right with rupee icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Rupee SVG icon
                        SvgPicture.asset(
                          AppIcons.vectoeIc3,
                          width: responsive.iconSizeSmall,
                          height: responsive.iconSizeSmall,
                        ),
                        SizedBox(width: responsive.wp(1)),
                        // Price amount
                        AppText.searchbar2(
                          planPrice,
                          color: planColor,
                          fontWeight: FontWeight.w600,
                        ),
                        // Duration
                        SizedBox(width: responsive.wp(0.5)),
                        if (planDuration.isNotEmpty)
                          AppText.searchbar2(
                            planDuration,
                            color: isDark ? AppColors.white : AppColorsLight.textSecondary,
                          ),
                        SizedBox(width: responsive.wp(0.5)),

                      ],
                    ),
                  ],
                ),
                SizedBox(height: responsive.hp(1.5)),

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

                // Features List
                ...features.map((feature) => Padding(
                  padding: EdgeInsets.symmetric(vertical: responsive.hp(0.8)),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: responsive.wp(5),
                      ),
                      SizedBox(width: responsive.wp(1.5)),
                      Expanded(
                        child: AppText.headlineMedium(
                          feature,
                          color: isDark ? AppColors.textDisabled : AppColorsLight.textPrimary,
                          fontWeight: FontWeight.w500,
                          maxLines: 2,
                          minFontSize: 10,
                        ),
                      ),
                    ],
                  ),
                )),
                SizedBox(height: responsive.hp(2)),

                // Action Button
                AppButton(
                  text: isCurrentPlan ? 'Current Plan' : 'Buy Now ',
                  width: double.infinity,
                  height: responsive.hp(6),
                  // Only Basic and Gold have borderColor, Platinum does not
                  borderColor: planIndex == 2
                      ? null
                      : (isDark ? AppColors.driver : AppColorsLight.textPrimary),
                  gradientColors: planIndex == 2
                      // Platinum ALWAYS uses gradient colors (even when current plan)
                      ? (isDark
                          ? [AppColors.splaceSecondary1, AppColors.splaceSecondary2]
                          : [AppColorsLight.gradientColor1, AppColorsLight.gradientColor2])
                      : isCurrentPlan
                          // Basic/Gold current plan - grey colors
                          ? [
                              isDark ? AppColors.containerDark : Colors.grey.shade400,
                              isDark ? AppColors.containerLight : Colors.grey.shade500,
                            ]
                          // Basic/Gold not current - other colors
                          : [
                              isDark ? AppColors.containerLight : AppColorsLight.textSecondary,
                              isDark ? AppColors.containerDark : AppColorsLight.textSecondary,
                            ],
                  textColor: Colors.white,
                  fontSize: responsive.fontSize(15),
                  fontWeight: FontWeight.w600,

                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                  enabled: !isCurrentPlan,
                  onPressed: isCurrentPlan
                      ? null
                      : () {
                          debugPrint('🎯 Selected plan: $planName');
                          setState(() {
                            _selectedPlanIndex = planIndex;
                          });
                          // Navigate to Payment Screen
                          Get.toNamed(
                            AppRoutes.payment,
                            arguments: {
                              'planName': planName,
                              'planPrice': planPrice,
                              'planDuration': planDuration,
                            },
                          );
                        },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getPlanIcon(int planIndex) {
    switch (planIndex) {
      case 0:
        return Icons.rocket_launch_outlined;
      case 1:
        return Icons.workspace_premium_outlined;
      case 2:
        return Icons.diamond_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  Widget _buildWarningContainer(AdvancedResponsiveHelper responsive, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.wp(4)),
      decoration: BoxDecoration(
        color: AppColors.red800,
        borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SVG Icon on left top
          SvgPicture.asset(
            AppIcons.warningIc,
            width: responsive.iconSizeLarge1,
            height: responsive.iconSizeLarge1,
          ),
          SizedBox(width: responsive.wp(3)),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: responsive.hp(0.5)),
                AppText.searchbar1(
                  'Your trial plan is going to end in 82 days,upgrade  Now to continue running your business operations smoothly',
                  color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                  maxLines: 5,
                  minFontSize: 10,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPlanSelectedDialog(String planName, String planPrice) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final responsive = AdvancedResponsiveHelper(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.containerLight : AppColorsLight.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.wp(4)),
        ),
        title: AppText.searchbar(
          'Plan Selected',
          color: isDark ? AppColors.white : AppColorsLight.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: responsive.wp(15),
            ),
            SizedBox(height: responsive.hp(2)),
            AppText.bodyMedium(
              'You have selected the $planName plan ($planPrice)',
              color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsive.hp(1)),
            AppText.bodySmall(
              'Payment integration coming soon!',
              color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          AppButton(
            text: 'OK',
            width: double.infinity,
            height: responsive.hp(5),
            gradientColors: [
              AppColorsLight.splaceSecondary1,
              AppColorsLight.splaceSecondary1.withOpacity(0.8),
            ],
            textColor: Colors.white,
            fontSize: responsive.fontSize(14),
            fontWeight: FontWeight.w600,
            borderRadius: BorderRadius.circular(responsive.wp(2)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}