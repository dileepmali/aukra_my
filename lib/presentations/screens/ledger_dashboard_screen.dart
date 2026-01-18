import 'package:aukra_anantkaya_space/presentations/widgets/custom_single_border_color.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/constants/app_icons.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_text.dart';
import '../../controllers/ledger_dashboard_controller.dart';
import '../../controllers/privacy_setting_controller.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/responsive_layout/padding_navigation.dart';
import '../../core/utils/formatters.dart';
import '../widgets/custom_app_bar/custom_app_bar.dart';
import '../widgets/custom_app_bar/model/app_bar_config.dart';
import '../widgets/animated_pie_chart.dart';
import '../widgets/list_item_widget.dart';
import '../widgets/account_statement_widget.dart';
import '../../controllers/account_statement_controller.dart';
import '../widgets/dialogs/pin_verification_dialog.dart';

class LedgerDashboardScreen extends StatelessWidget {
  const LedgerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LedgerDashboardController());
    final statementController = Get.put(AccountStatementController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final responsive = AdvancedResponsiveHelper(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.overlay : AppColorsLight.scaffoldBackground,
      appBar: CustomResponsiveAppBar(
        config: AppBarConfig(
          type: AppBarType.titleOnly,
          customPadding: EdgeInsets.symmetric(horizontal: responsive.wp(1)),
          titleColor: isDark ? AppColors.white : AppColorsLight.textPrimary,
          leadingWidget: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: isDark ? AppColors.white : AppColorsLight.textPrimary),
                onPressed: () => Get.back(),
              ),
          AppText.searchbar2(
            'Ledger Dashboard',
            color: isDark ? Colors.white : AppColorsLight.textPrimary,
            fontWeight: FontWeight.w500,
            maxLines: 1,
            minFontSize: 12,
            letterSpacing: 1.2,
          ),
            ],
          ),
          showBorder: true,
        ),
      ),
      body: Obx(() {
        // Update statement controller with transactions reactively
        if (controller.transactions.value != null) {
          statementController.setTransactions(controller.transactions.value!.data);
        }

        if (controller.isLoading.value && controller.dashboardData.value == null) {
          return Center(
            child: CircularProgressIndicator(
              color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
              strokeWidth: 1.0,
            ),
          );
        }

        if (controller.errorMessage.isNotEmpty && controller.dashboardData.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.red500),
                SizedBox(height: responsive.hp(2)),
                AppText.headlineLarge1(
                  controller.errorMessage.value,
                  color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                ),
                SizedBox(height: responsive.hp(2)),
                TextButton(
                  onPressed: controller.fetchDashboard,
                  child: AppText.headlineLarge1(
                    'Retry',
                    color: AppColorsLight.splaceSecondary1,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshDashboard,
          color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: responsive.hp(10)),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Details Section
                _buildBasicDetailsSection(context, controller, isDark, responsive),
                // New Container Section
                _buildNewContainerSection(context, controller, isDark, responsive),

                SizedBox(height: responsive.hp(2)),

                // Summary Cards Section (Today IN/OUT, Overall Given/Received)
                _buildSummarySection(context, controller, isDark, responsive),

                SizedBox(height: responsive.hp(2)),

                // Recent Transactions Section
                _buildRecentTransactionsSection(context, controller, isDark, responsive),

                SizedBox(height: responsive.hp(2)),

                // Account Statement Header
                Stack(
                  children: [
                    Positioned.fill(child: CustomSingleBorderWidget(position: BorderPosition.top)),
                    Padding(
                    padding: EdgeInsets.symmetric(horizontal: responsive.wp(4)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText.searchbar1(
                          'Account Statement',
                          color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        TextButton(
                          onPressed: () {
                            debugPrint('View Details tapped');
                            // TODO: Navigate to detailed statement screen
                          },
                          child: AppText.searchbar1(
                            'View Details',
                            color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),]
                ),

                SizedBox(height: responsive.hp(1)),

                // Account Statement Section
                AccountStatementWidget(
                  isDark: isDark,
                  onViewDetails: () {
                    debugPrint('View Details tapped');
                    // TODO: Navigate to detailed statement screen
                  },
                ),

                SizedBox(height: responsive.hp(3)),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Basic Details Section
  Widget _buildBasicDetailsSection(BuildContext context, LedgerDashboardController controller, bool isDark, AdvancedResponsiveHelper responsive) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.wp(4)),
      decoration: BoxDecoration(
        color: isDark ? AppColors.overlay : AppColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Details Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.headlineLarge(
                'Basic Details',
                color: isDark ? AppColors.textDisabled : AppColorsLight.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              GestureDetector(
                onTap: () async {
                  // Use global PIN check - skip if PIN is disabled
                  String? pin;
                  try {
                    final privacyController = Get.find<PrivacySettingController>();
                    final result = await privacyController.requirePinIfEnabled(
                      context,
                      title: 'Enter Security PIN',
                      subtitle: 'Enter your 4-digit PIN to edit ledger details',
                    );

                    if (result == null) {
                      return; // User cancelled or PIN validation failed
                    }

                    pin = result == 'SKIP' ? '' : result;
                  } catch (e) {
                    // Controller not registered, show PIN dialog as fallback
                    debugPrint('⚠️ PrivacySettingController not found, using fallback PIN dialog');
                    final dialogResult = await PinVerificationDialog.show(context: context);
                    if (dialogResult == null || dialogResult['pin'] == null) {
                      return;
                    }
                    pin = dialogResult['pin'];
                  }

                  // PIN verified or skipped, navigate to edit form
                  debugPrint('✅ PIN verified or skipped');

                  // Get complete ledger data
                  final ledgerData = {
                    'isEditMode': true,
                    'ledgerId': controller.ledgerDetail.value?.id,
                    'partyType': controller.partyType,
                    'partyName': controller.partyName,
                    'mobileNumber': controller.ledgerDetail.value?.mobileNumber,
                    'area': controller.ledgerDetail.value?.area,
                    'pinCode': controller.ledgerDetail.value?.pinCode,
                    'address': controller.ledgerDetail.value?.address,
                    'city': controller.ledgerDetail.value?.city,
                    'country': controller.ledgerDetail.value?.country,
                    'creditDay': controller.ledgerDetail.value?.creditDay,
                    'creditLimit': controller.ledgerDetail.value?.creditLimit,
                    'interestRate': controller.ledgerDetail.value?.interestRate,
                    'interestType': controller.ledgerDetail.value?.interestType,
                    'openingBalance': controller.ledgerDetail.value?.openingBalance,
                    'transactionType': controller.ledgerDetail.value?.transactionType,
                  };

                  debugPrint('📝 Navigating to edit form with data: $ledgerData');

                  Get.toNamed('/customer-form', arguments: ledgerData);
                },
                child: AppText.searchbar1(
                  'Edit',
                  color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          SizedBox(height: responsive.hp(1.5)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar and Party Name Column (left side) - wrapped in Expanded to prevent overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Circular Avatar with Gradient
                    Container(
                      width: responsive.wp(15),
                      height: responsive.wp(15),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.containerDark,
                            AppColors.containerDark,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Center(
                        child: AppText.displaySmall(
                          _getInitials(controller.partyName ?? 'Party'),
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: responsive.hp(0.8)),

                    // Party Name (just below avatar) - with overflow handling
                    AppText.searchbar(
                      controller.partyName ?? 'Party',
                      color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                      fontWeight: FontWeight.w700,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: responsive.hp(0.1)),

                    // Party Type and Area Row - with Flexible for overflow handling
                    Row(
                      children: [
                        AppText.headlineMedium(
                          controller.getPartyTypeDisplay(),
                          color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                        // Use area field directly from API response
                        if (controller.ledgerDetail.value?.area != null &&
                            controller.ledgerDetail.value!.area!.isNotEmpty) ...[
                          AppText.headlineMedium(
                            ' • ',
                            color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                          ),
                          Flexible(
                            child: AppText.headlineMedium(
                              controller.ledgerDetail.value!.area!,
                              color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                              fontWeight: FontWeight.w400,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: responsive.hp(1)),


                  ],
                ),
              ),

              // Two Pie Charts side by side on right
              Row(
                children: [
                  // Credit Limit Usage Pie Chart
                  _buildCreditLimitPieChart(controller, isDark),
                  SizedBox(width: responsive.wp(3)),
                  // Closing Balance Pie Chart
                  _buildCreditPieChart(controller, isDark),
                ],
              ),
            ],
          ),
          SizedBox(height: responsive.hp(0.5)),
          // Credit Info Tabs - Row 1
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                // Credit Date Tab
                Expanded(
                  child: _buildInfoTab(
                    context: context,
                    label: 'Credit Days',
                    value: '${controller.ledgerDetail.value?.creditDay ?? 0} days',
                    isDark: isDark,
                    responsive: responsive,
                    iconPath: AppIcons.calendarMonthIc,
                  ),
                ),
                SizedBox(width: responsive.wp(2)),
                // Credit Limit Tab
                Expanded(
                  child: _buildInfoTab(
                    context: context,
                    label: 'Credit Limit',
                    value: '₹${Formatters.formatAmountWithCommas((controller.ledgerDetail.value?.creditLimit ?? 0).toString())}',
                    isDark: isDark,
                    responsive: responsive,
                    iconPath: AppIcons.clockLoaderIc,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: responsive.hp(1)),

          // Credit Info Tabs - Row 2
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                // Interest Rate Tab
                Expanded(
                  child: _buildInfoTab(
                    context: context,
                    label: 'Interest Rate',
                    value: '${controller.ledgerDetail.value?.interestRate.toStringAsFixed(1) ?? '0'}%',
                    isDark: isDark,
                    responsive: responsive,
                    iconPath: AppIcons.percentIc,
                  ),
                ),
                SizedBox(width: responsive.wp(2)),
                // Civil Score Tab (Placeholder)
                Expanded(
                  child: _buildInfoTab(
                    context: context,
                    label: 'Civil Score',
                    value: '---', // Placeholder - data will be passed later
                    isDark: isDark,
                    responsive: responsive,
                    iconPath: AppIcons.CircleIc,
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  /// New Container Section
  Widget _buildNewContainerSection(BuildContext context, LedgerDashboardController controller, bool isDark, AdvancedResponsiveHelper responsive) {
    // Get current month name
    final now = DateTime.now();
    final monthNames = ['January', 'February', 'March', 'April', 'May', 'June',
                        'July', 'August', 'September', 'October', 'November', 'December'];
    final currentMonthName = monthNames[now.month - 1];

    return Stack(
      children: [
        Positioned.fill(child: CustomSingleBorderWidget(position: BorderPosition.top)),
        Positioned.fill(child: CustomSingleBorderWidget(position: BorderPosition.bottom)),

        Container(
        width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: responsive.hp(2),vertical: responsive.hp(1.5)),
        decoration: BoxDecoration(
          color: isDark ? AppColors.overlay : AppColorsLight.scaffoldBackground,
          borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: responsive.hp(1.0)),
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    colors: [
                      AppColors.containerDark,
                      AppColors.containerDark,
                      AppColors.containerLight,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : LinearGradient(
                    colors: [
                      AppColorsLight.gradientColor1,
                      AppColorsLight.gradientColor1,
                      AppColorsLight.gradientColor2,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
            borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month Statement Header (Top Left inside gradient)
              Padding(
                padding: EdgeInsets.only(left: responsive.wp(5), bottom: responsive.hp(1)),
                child: AppText.headlineMedium(
                  '$currentMonthName Statement',
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.0,
                ),
              ),

              // IN/OUT Row
              _buildMonthlyInOutRow(context, controller, isDark, responsive),
            ],
          ),
        ),
      ),]
    );
  }

  /// Monthly IN/OUT Row Widget
  Widget _buildMonthlyInOutRow(BuildContext context, LedgerDashboardController controller, bool isDark, AdvancedResponsiveHelper responsive) {
    // Calculate current month's IN and OUT
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);

    double monthlyIn = 0;
    double monthlyOut = 0;

    if (controller.transactions.value != null) {
      for (var transaction in controller.transactions.value!.data) {
        if (transaction.isDelete) continue;

        final transactionDate = DateTime.parse(transaction.transactionDate);

        // Check if transaction is in current month
        if (transactionDate.isAfter(currentMonth.subtract(Duration(days: 1))) &&
            transactionDate.isBefore(nextMonth)) {
          if (transaction.transactionType == 'IN') {
            monthlyIn += transaction.amount;
          } else {
            monthlyOut += transaction.amount;
          }
        }
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.wp(3)),
      child: Row(
        children: [
          // Monthly OUT
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  AppIcons.arrowOutIc,
                  width: responsive.iconSizeLarge,
                  height: responsive.iconSizeLarge,
                  colorFilter: ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: responsive.wp(2)),
                Flexible(
                  child: AppText.displaySmall(
                    null,
                    amount: monthlyOut,
                    prefix: '₹ ',
                    minFontSize: 10,
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          // Monthly IN
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  AppIcons.arrowInIc,
                  width: responsive.iconSizeLarge,
                  height: responsive.iconSizeLarge,
                  colorFilter: ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: responsive.wp(2)),
                Flexible(
                  child: AppText.displaySmall(
                    null,
                    amount: monthlyIn,
                    prefix: '₹ ',
                    minFontSize: 10,
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Summary Section (Today IN/OUT, Overall Given/Received)
  Widget _buildSummarySection(BuildContext context, LedgerDashboardController controller, bool isDark, AdvancedResponsiveHelper responsive) {
    final dashboard = controller.dashboardData.value;
    if (dashboard == null) return const SizedBox.shrink();

    return Container(
    padding: EdgeInsets.symmetric(horizontal: responsive.wp(4)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.searchbar1(
          'Dashboard & Report',
          color: isDark ? AppColors.white : AppColorsLight.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        SizedBox(height: responsive.hp(1.5)),

        // Today IN/OUT Row
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context: context,
                title: 'Amount in today',
                amount: dashboard.todayIn,
                icon: Icons.arrow_downward,
                iconColor: AppColors.successPrimary,
                isDark: isDark,
                responsive: responsive,
              ),
            ),
            SizedBox(width: responsive.wp(2)),
            Expanded(
              child: _buildSummaryCard(
                context: context,
                title: 'Amount out today',
                amount: dashboard.todayOut,
                icon: Icons.arrow_upward,
                iconColor: AppColors.red500,
                isDark: isDark,
                responsive: responsive,
                baseIcon: AppIcons.vectoeIc4,
                topRightIcon: AppIcons.vectoeIc5,
              ),
            ),
          ],
        ),

        SizedBox(height: responsive.hp(1.0)),

        // Overall Given/Received Row
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context: context,
                title: 'You will receive',
                amount: dashboard.overallGiven,
                icon: Icons.trending_up,
                iconColor: AppColors.warning,
                isDark: isDark,
                responsive: responsive,
              ),
            ),
            SizedBox(width: responsive.wp(2)),
            Expanded(
              child: _buildSummaryCard(
                context: context,
                title: 'You will give',
                amount: dashboard.overallReceived,
                icon: Icons.trending_down,
                iconColor: AppColors.blue,
                isDark: isDark,
                responsive: responsive,
                baseIcon: AppIcons.vectoeIc4,
                topRightIcon: AppIcons.vectoeIc5,
              ),
            ),
          ],
        ),
      ],
    ),
          );
  }

  /// Summary Card Widget
  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    required double amount,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required AdvancedResponsiveHelper responsive,
    String? baseIcon,
    String? topRightIcon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: responsive.wp(3), vertical: responsive.hp(1)),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                colors: [
                  AppColors.containerDark,
                  AppColors.containerDark,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : LinearGradient(
                colors: [
                  AppColorsLight.gradientColor1,
                  AppColorsLight.gradientColor2,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
        borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: AppText.headlineMedium(
                  title,
                  color: isDark ? AppColors.white : AppColorsLight.textSecondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: responsive.iconSizeExtraLarge,
                height: responsive.iconSizeExtraLarge,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Base SVG icon
                    SvgPicture.asset(
                      baseIcon ?? AppIcons.vectoeIc1,
                      width: responsive.iconSizeLarge2,
                      height: responsive.iconSizeLarge2,
                    ),
                    // Center icon
                    SvgPicture.asset(
                      AppIcons.vectoeIc3,
                      width: responsive.iconSizeSmall + 5,
                      height: responsive.iconSizeSmall + 5,
                    ),
                    // Top right icon
                    Positioned(
                      top: 3,
                      right: 2,
                      child: SvgPicture.asset(
                        topRightIcon ?? AppIcons.vectoeIc2,
                        width: responsive.iconSizeSmall + 2,
                        height: responsive.iconSizeSmall + 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.hp(0.5)),
          // Use AppText for auto-scaling amount
          AppText.displaySmall(
            null,
            amount: amount,
            prefix: '₹ ',
            minFontSize: 12,
            color: isDark ? AppColors.white : AppColorsLight.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  /// Dashboard & Reports Section


  /// Recent Transactions Section
  Widget _buildRecentTransactionsSection(BuildContext context, LedgerDashboardController controller, bool isDark, AdvancedResponsiveHelper responsive) {
    return Obx(() {
      final transactionList = controller.transactions.value;

      // If no transactions, hide entire section
      if (transactionList == null || transactionList.data.isEmpty) {
        return const SizedBox.shrink();
      }

      // Filter out deleted transactions and get top 5 recent ones
      final activeTransactions = transactionList.data
          .where((t) => !t.isDelete)
          .toList();

      // Take only top 5 (newest first)
      final recentTransactions = activeTransactions.take(5).toList();

      // If no active transactions, hide entire section
      if (recentTransactions.isEmpty) {
        return const SizedBox.shrink();
      }

      // Show section only when there are transactions
      return Stack(
        children: [
          Positioned.fill(child: CustomSingleBorderWidget(position: BorderPosition.top)),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: responsive.wp(3), right: responsive.wp(2)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.searchbar1(
                        'Recent Transactions',
                        color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to all transactions
                          Get.back(); // Go back to ledger detail which shows all transactions
                        },
                        child: AppText.searchbar1(
                          'View All',
                          color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                          fontWeight: FontWeight.w500,

                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: responsive.hp(1)),

                // Show transaction list
                Column(
                  children: recentTransactions.map((transaction) {
                    return _buildTransactionItem(
                      transaction,
                      controller.partyName ?? '',
                      responsive,
                      isDark,
                      context,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
  
  /// Build Credit Limit Usage Pie Chart - Shows how much credit limit is used
  Widget _buildCreditLimitPieChart(LedgerDashboardController controller, bool isDark) {
    final ledgerDetail = controller.ledgerDetail.value;
    final dashboard = controller.dashboardData.value;

    // Get credit limit and current balance
    final double creditLimit = ledgerDetail?.creditLimit ?? 0.0;
    final double closingBalance = ledgerDetail?.currentBalance.abs() ??
                                  (controller.creditAmount ?? 0.0).abs();

    // Calculate credit used and remaining
    final double creditUsed = closingBalance;
    final double creditRemaining = (creditLimit - creditUsed).clamp(0.0, creditLimit);

    // Calculate percentage used (can exceed 100% if over-limit)
    final double usagePercentage = creditLimit > 0
        ? ((creditUsed / creditLimit) * 100)
        : 0.0;

    debugPrint('💳 Credit Limit Chart - Limit: ₹$creditLimit, Used: ₹$creditUsed, Remaining: ₹$creditRemaining, Usage: ${usagePercentage.toStringAsFixed(1)}%');

    // For pie chart visualization, use percentage values (not amounts)
    // If usage > 100%, show full pie (100%) but center text will show actual percentage
    final double displayUsedPercent = usagePercentage.clamp(0.0, 100.0);
    final double displayRemainingPercent = (100.0 - displayUsedPercent).clamp(0.0, 100.0);

    return AnimatedPieChart(
      usedValue: displayUsedPercent,
      remainingValue: displayRemainingPercent,
      centerSubText: 'Credit Used',
      centerText: '${usagePercentage.toStringAsFixed(0)}%',
      usedColor: AppColors.primeryamount, // Orange/Yellow for used credit
      remainingColor: AppColors.containerDark, // Green for remaining credit
      chartSize: 92,
      centerSpaceRadius: 38,
      usedRadius: 11,
      remainingRadius: 11,
      isDark: isDark,
    );
  }

  /// Build Credit Pie Chart Widget - Shows closing balance based on credit limit
  Widget _buildCreditPieChart(LedgerDashboardController controller, bool isDark) {
    final ledgerDetail = controller.ledgerDetail.value;

    // Get credit limit and closing balance
    final double creditLimit = ledgerDetail?.creditLimit ?? 0.0;
    final double closingBalance = ledgerDetail?.currentBalance.abs() ??
                                  (controller.creditAmount ?? 0.0).abs();

    // Calculate used and remaining based on credit limit
    final double creditUsed = closingBalance;
    final double creditRemaining = (creditLimit - creditUsed).clamp(0.0, creditLimit);

    debugPrint('📊 Closing Balance Pie Chart - Credit Limit: ₹$creditLimit, Used: ₹$creditUsed, Remaining: ₹$creditRemaining');

    // For pie chart visualization
    // If credit limit is 0, show full used (closing balance as 100%)
    double displayUsed;
    double displayRemaining;

    if (creditLimit <= 0) {
      // No credit limit set - show closing balance as full pie
      displayUsed = closingBalance > 0 ? 100.0 : 1.0;
      displayRemaining = closingBalance > 0 ? 0.0 : 1.0;
    } else {
      // Calculate percentage of credit limit used
      displayUsed = creditUsed;
      displayRemaining = creditRemaining;

      // If both are 0, show placeholder
      if (displayUsed == 0 && displayRemaining == 0) {
        displayUsed = 1.0;
        displayRemaining = 1.0;
      }
    }

    return AnimatedPieChart(
      usedValue: displayUsed,
      remainingValue: displayRemaining,
      centerSubText: 'Closing Bal.',
      centerText: '₹${closingBalance.toStringAsFixed(0)}',
      usedColor: AppColors.primeryamount, // Orange/Yellow for used credit
      remainingColor: AppColors.red500, // Dark for remaining credit
      chartSize: 92,
      centerSpaceRadius: 38,
      usedRadius: 11,
      remainingRadius: 11,
      isDark: isDark,
    );
  }

  /// Build Info Tab Widget
  Widget _buildInfoTab({
    required BuildContext context,
    required String label,
    required String value,
    required bool isDark,
    required AdvancedResponsiveHelper responsive,
    String? iconPath,
  }) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: responsive.wp(0.5),
        vertical: responsive.hp(1.0),
      ),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                colors: [
                  AppColors.containerDark,
                  AppColors.containerDark,
                  AppColors.containerLight,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : LinearGradient(
                colors: [
                  AppColorsLight.gradientColor1,
                  AppColorsLight.gradientColor1,
                  AppColorsLight.gradientColor2,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon on the left (if provided)
          if (iconPath != null) ...[
            SvgPicture.asset(
              iconPath,
              width: responsive.iconSizeMedium,
              height: responsive.iconSizeMedium,
            ),
            SizedBox(width: responsive.wp(1.5)),
          ],

          // Label : Value (centered format) - Auto-scaling text
          Flexible(
            child: AutoSizeText(
              '$label : $value',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              maxFontSize: 14,
              minFontSize: 9,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to get initials from name
  String _getInitials(String name) {
    if (name.isEmpty) return '';

    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, words[0].length > 1 ? 2 : 1).toUpperCase();
    }

    // Take first letter of first two words
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  /// Build Transaction Item Widget (Reused from ledger_detail_screen.dart)
  Widget _buildTransactionItem(
    dynamic transaction,
    String partyName,
    AdvancedResponsiveHelper responsive,
    bool isDark,
    BuildContext context,
  ) {
    // Determine if transaction is positive (IN) or negative (OUT)
    final isPositive = transaction.transactionType == 'IN';

    // Format amount - remove currency symbol as ListItemWidget adds it
    final formattedAmount = transaction.amount.toStringAsFixed(2);

    // Format date for subtitle using Formatters utility (time first, then date)
    final formattedDate = Formatters.formatStringToTimeAndDate(transaction.transactionDate);

    // Use note/description as title, fallback to "No note added" if empty (same as ledger_detail_screen.dart)
    final noteTitle = (transaction.description != null && transaction.description.toString().trim().isNotEmpty)
        ? transaction.description.toString()
        : 'No note added';

    return ListItemWidget(
      itemMargin: EdgeInsets.symmetric(horizontal: responsive.wp(4), vertical: responsive.hp(0.2)),
      title: noteTitle,
      subtitle: formattedDate,
      subtitleColor: AppColors.white,
      backgroundColor: isDark
          ? AppColors.containerDark
          : AppColorsLight.containerLight,
      titlePrefixIcon: SvgPicture.asset(
        isPositive ? AppIcons.arrowInIc : AppIcons.arrowOutIc,
        width: responsive.iconSizeMedium,
        height: responsive.iconSizeMedium,
        colorFilter: ColorFilter.mode(
          isPositive
              ? AppColors.white
              : Colors.white,
          BlendMode.srcIn,
        ),
      ),
      // Use AutoSizeText for balance to prevent overflow
      subtitleSuffix: AutoSizeText(
        'Bal. - ${NumberFormat('#,##,##0.00', 'en_IN').format(transaction.lastBalance)}',
        style: TextStyle(
          color: AppColors.white,
          fontWeight: isPositive ? FontWeight.w600 : FontWeight.w400,
          fontSize: 12,
        ),
        maxFontSize: 12,
        minFontSize: 8,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitleFontWeight: isPositive ? FontWeight.w600 : FontWeight.w400,
      amount: formattedAmount,
      isPositiveAmount: isPositive,
      showBorder: false,
      titleDecoration: null,
      titleColor: null,
      onTap: null,
    );
  }

  /// Format Date for Bottom Sheet

}
