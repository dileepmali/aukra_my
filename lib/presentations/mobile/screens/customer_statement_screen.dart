import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_text.dart';
import '../../../buttons/app_button.dart';
import '../../../controllers/customer_statement_controller.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/ledger_transaction_dashboard_model.dart';
import '../../widgets/custom_app_bar/custom_app_bar.dart';
import '../../widgets/custom_app_bar/model/app_bar_config.dart';
import '../../widgets/custom_single_border_color.dart';
import '../../widgets/list_item_widget.dart';
import 'search_screen.dart';
import '../../../core/utils/balance_helper.dart';

class CustomerStatementScreen extends StatelessWidget {
  const CustomerStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🎯 CustomerStatementScreen build() called');
    debugPrint('   Arguments: ${Get.arguments}');

    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.put(CustomerStatementController());

    debugPrint('✅ CustomerStatementController created');

    return Scaffold(
      backgroundColor: isDark ? AppColors.overlay : AppColorsLight.scaffoldBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(responsive.hp(20)),
        // ✅ Wrap in Obx to make filter values reactive
        child: Obx(() => CustomResponsiveAppBar(
          config: AppBarConfig(
            type: AppBarType.searchWithFilter,
            customHeight: responsive.hp(19),
            enableSearchInput: false,
            showViewToggle: false,
            customPadding: EdgeInsets.symmetric(horizontal: responsive.wp(3)),
            // Search callback
            onSearchChanged: (query) {
              controller.searchQuery.value = query;
            },
            // ✅ Navigate to SearchScreen when search bar is tapped
            // Pass partyType so SearchScreen only shows relevant data
            onSearchTap: () {
              debugPrint('🔍 Search bar tapped - navigating to SearchScreen');
              debugPrint('   Party Type: ${controller.partyType}');
              Get.to(
                () => const SearchScreen(),
                arguments: {
                  'partyType': controller.partyType,
                  'partyTypeLabel': controller.partyTypeLabel,
                },
              );
            },
              // Filter callback - opens filter bottom sheet
            onFiltersApplied: (filters) => controller.handleFiltersApplied(filters),
            // 🔥 Pass current filter values to restore previous selections (same as search_screen.dart)
            currentSortBy: controller.sortByForUI,
            currentSortOrder: controller.sortOrder.value,
            currentDateFilter: controller.dateFilter.value,
            currentTransactionFilter: controller.transactionFilter.value,
            currentReminderFilter: 'all',
            currentUserFilter: controller.partyTypeFilter.value,
            currentCustomDateFrom: controller.customDateFrom.value,
            currentCustomDateTo: controller.customDateTo.value,
            // 🔥 Hide Reminder and User filters for customer statement
            hideFilters: ['Reminder', 'User'],
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
                SizedBox(width: responsive.wp(2)),
                AppText.searchbar2(
                  controller.screenTitle,
                  color: isDark ? Colors.white : AppColorsLight.textPrimary,
                  fontWeight: FontWeight.w500,
                  maxLines: 1,
                  minFontSize: 12,
                ),
              ],
            )
          ),
        )),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
          backgroundColor: isDark ? AppColors.containerDark : AppColorsLight.white,
          onRefresh: () => controller.refreshStatement(),
          child: Column(
            children: [
              // Header Card with Net Balance - Always visible (uses Dashboard API)
              Obx(() => _buildHeaderCardSafe(responsive, isDark, controller)),

              // Summary Section with Today IN/OUT - Always visible (uses Dashboard API)
              Obx(() => _buildSummarySectionSafe(responsive, isDark, controller)),

              SizedBox(height: responsive.hp(2)),

              // Customer List Section - Shows loading/error/empty states
              Expanded(
                child: _buildCustomerList(responsive, isDark, controller),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value || controller.transactionData.value == null) {
            return const SizedBox.shrink();
          }
          return _buildDownloadButton(responsive, isDark, controller);
        }),
      ),
    );
  }

  /// Safe Header Card - Always visible, uses Dashboard API data
  Widget _buildHeaderCardSafe(
    AdvancedResponsiveHelper responsive,
    bool isDark,
    CustomerStatementController controller,
  ) {
    // Use Dashboard API data: partyNetBalance and partyNetBalanceType
    final netBalance = controller.partyNetBalance;
    final netBalanceType = controller.partyNetBalanceType;
    final isPositive = netBalanceType == 'IN';

    return Stack(
      children: [
        Positioned.fill(child: CustomSingleBorderWidget(position: BorderPosition.bottom)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(responsive.wp(4)),
          decoration: BoxDecoration(
            color: isDark ? AppColors.overlay : AppColorsLight.white,
            borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText.searchbar(
                    'Net balance',
                    color: isDark ? AppColors.white : AppColorsLight.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                  Flexible(
                    child: AppText.amountRow(
                      amount: netBalance.abs(),
                      color: isPositive ? AppColors.primeryamount : AppColors.red500,
                      symbolSize: AmountSymbolSize.searchbar1,
                      amountSize: AmountTextSize.searchbar2,
                      spacing: responsive.wp(1),
                    ),
                  ),
                ],
              ),
              AppText.headlineLarge1(
                '${controller.partyTotal} ${controller.customerLabel}',
                color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Safe Summary Section - Always visible, uses Dashboard API data
  Widget _buildSummarySectionSafe(
    AdvancedResponsiveHelper responsive,
    bool isDark,
    CustomerStatementController controller,
  ) {
    // Use Dashboard API data for today IN/OUT
    final todayIn = controller.todayIn;
    final todayOut = controller.todayOut;

    return Stack(
      children: [
        Positioned.fill(child: CustomSingleBorderWidget(position: BorderPosition.bottom)),
        Container(
          margin: EdgeInsets.symmetric(horizontal: responsive.wp(1), vertical: responsive.hp(2)),
          child: Row(
            children: [
              // Total IN Today
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: responsive.wp(1)),
                  padding: EdgeInsets.symmetric(horizontal: responsive.wp(3), vertical: responsive.hp(1.5)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [AppColors.containerDark, AppColors.containerDark]
                          : [AppColorsLight.white, AppColorsLight.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: responsive.iconSizeExtraLarge,
                        height: responsive.iconSizeExtraLarge,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SvgPicture.asset(
                              AppIcons.vectoeIc1,
                              width: responsive.iconSizeLarge2,
                              height: responsive.iconSizeLarge2,
                            ),
                            SvgPicture.asset(
                              AppIcons.vectoeIc3,
                              width: responsive.iconSizeSmall + 5,
                              height: responsive.iconSizeSmall + 5,
                            ),
                            Positioned(
                              top: 3,
                              right: 2,
                              child: SvgPicture.asset(
                                AppIcons.vectoeIc2,
                                width: responsive.iconSizeSmall,
                                height: responsive.iconSizeSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: responsive.hp(0.5)),
                      AppText.headlineMedium(
                        'Total amount in today',
                        color: isDark ? AppColors.white : AppColorsLight.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                      SizedBox(height: responsive.hp(0.5)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: AppText.amountRow(
                              amount: todayIn,
                              color: AppColors.primeryamount,
                              symbolSize: AmountSymbolSize.headlineLarge1,
                              amountSize: AmountTextSize.searchbar2,
                              spacing: responsive.wp(1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Total OUT Today
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: responsive.wp(1)),
                  padding: EdgeInsets.symmetric(horizontal: responsive.wp(3), vertical: responsive.hp(1.5)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [AppColors.containerDark, AppColors.containerDark]
                          : [AppColorsLight.white, AppColorsLight.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: responsive.iconSizeExtraLarge,
                        height: responsive.iconSizeExtraLarge,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SvgPicture.asset(
                              AppIcons.vectoeIc4,
                              width: responsive.iconSizeLarge2,
                              height: responsive.iconSizeLarge2,
                            ),
                            SvgPicture.asset(
                              AppIcons.vectoeIc3,
                              width: responsive.iconSizeSmall + 5,
                              height: responsive.iconSizeSmall + 5,
                            ),
                            Positioned(
                              top: 4,
                              right: 3,
                              child: SvgPicture.asset(
                                AppIcons.vectoeIc5,
                                width: responsive.iconSizeSmall,
                                height: responsive.iconSizeSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: responsive.hp(0.5)),
                      AppText.headlineMedium(
                        'Total amount out today',
                        color: isDark ? AppColors.white : AppColorsLight.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                      SizedBox(height: responsive.hp(0.5)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: AppText.amountRow(
                              amount: todayOut,
                              color: AppColors.red500,
                              symbolSize: AmountSymbolSize.headlineLarge1,
                              amountSize: AmountTextSize.searchbar2,
                              spacing: responsive.wp(1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard(
    AdvancedResponsiveHelper responsive,
    bool isDark,
    LedgerTransactionDashboardModel statement,
    CustomerStatementController controller,
  ) {
    // ✅ Use Dashboard API data: partyNetBalance and partyNetBalanceType
    final netBalance = controller.partyNetBalance;
    final netBalanceType = controller.partyNetBalanceType;
    final isPositive = netBalanceType == 'IN';

    debugPrint('📊 Header Card - Net Balance: ₹$netBalance, Type: $netBalanceType, IsPositive: $isPositive');

    return Stack(
        children:[
          Positioned.fill(child: CustomSingleBorderWidget(position: BorderPosition.bottom)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(responsive.wp(4)),
            decoration: BoxDecoration(
              color: isDark ? AppColors.overlay : AppColorsLight.white,
              borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText.searchbar(
                      'Net balance',
                      color: isDark ? AppColors.white : AppColorsLight.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                    Flexible(
                      child: AppText.amountRow(
                        amount: netBalance.abs(),
                        color: isPositive ? AppColors.primeryamount : AppColors.red500,
                        symbolSize: AmountSymbolSize.searchbar1,
                        amountSize: AmountTextSize.searchbar2,
                        spacing: responsive.wp(1),
                      ),
                    ),
                  ],
                ),
                AppText.headlineLarge1(
                  '${controller.partyTotal} ${controller.customerLabel}',
                  color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          ),]
    );
  }

  /// Summary Section with Yesterday IN/OUT (from Dashboard API)
  Widget _buildSummarySection(
    AdvancedResponsiveHelper responsive,
    bool isDark,
    LedgerTransactionDashboardModel statement,
    CustomerStatementController controller,
    String? baseIconIn,
    String? topRightIconIn,
    String? baseIconOut,
    String? topRightIconOut,
  ) {
    // Use Dashboard API data for today IN/OUT
    final todayIn = controller.todayIn;
    final todayOut = controller.todayOut;

    return  Stack(
      children:[
        Positioned.fill(child: CustomSingleBorderWidget(position: BorderPosition.bottom)),
        Container(
        margin: EdgeInsets.symmetric(horizontal: responsive.wp(1),vertical: responsive.hp(2)),
        child: Row(
          children: [
            // Total IN Yesterday
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: responsive.wp(1)),
                padding: EdgeInsets.symmetric(horizontal: responsive.wp(3),vertical: responsive.hp(1.5)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.containerDark, AppColors.containerDark]
                        : [AppColorsLight.white, AppColorsLight.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),              borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: responsive.iconSizeExtraLarge,
                      height: responsive.iconSizeExtraLarge,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Base SVG icon
                          SvgPicture.asset(
                            baseIconIn ?? AppIcons.vectoeIc1,
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
                              topRightIconIn ?? AppIcons.vectoeIc2,
                              width: responsive.iconSizeSmall,
                              height: responsive.iconSizeSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: responsive.hp(0.5)),
                    AppText.headlineMedium(
                      'Total amount in today',
                      color: isDark ? AppColors.white : AppColorsLight.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                    SizedBox(height: responsive.hp(0.5)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: AppText.amountRow(
                            amount: todayIn,
                            color: AppColors.primeryamount,
                            symbolSize: AmountSymbolSize.headlineLarge1,
                            amountSize: AmountTextSize.searchbar2,
                            spacing: responsive.wp(1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Total OUT Yesterday
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: responsive.wp(1)),
                padding: EdgeInsets.symmetric(horizontal: responsive.wp(3),vertical: responsive.hp(1.5)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.containerDark, AppColors.containerDark]
                        : [AppColorsLight.white, AppColorsLight.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),              borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: responsive.iconSizeExtraLarge,
                      height: responsive.iconSizeExtraLarge,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Base SVG icon
                          SvgPicture.asset(
                            baseIconOut ?? AppIcons.vectoeIc4,
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
                            top: 4,
                            right: 3,
                            child: SvgPicture.asset(
                              topRightIconOut ?? AppIcons.vectoeIc5,
                              width: responsive.iconSizeSmall,
                              height: responsive.iconSizeSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: responsive.hp(0.5)),
                    AppText.headlineMedium(
                      'Total amount out today',
                      color: isDark ? AppColors.white : AppColorsLight.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                    SizedBox(height: responsive.hp(0.5)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: AppText.amountRow(
                            amount: todayOut,
                            color: AppColors.red500,
                            symbolSize: AmountSymbolSize.headlineLarge1,
                            amountSize: AmountTextSize.searchbar2,
                            spacing: responsive.wp(1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),]
    );
  }

  /// Customer List Section with Infinite Scrolling
  /// Shows loading/error/empty states only in this section
  Widget _buildCustomerList(
    AdvancedResponsiveHelper responsive,
    bool isDark,
    CustomerStatementController controller,
  ) {
    return Obx(() {
      // Show loading state only in list section
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
            strokeWidth: 1.0,
          ),
        );
      }

      // Show error state only in list section
      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText.searchbar1(
                'Error loading ${controller.customerLabel}',
                color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: responsive.hp(1)),
              AppText.headlineLarge1(
                controller.errorMessage.value,
                color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
              ),
              SizedBox(height: responsive.hp(2)),
              ElevatedButton(
                onPressed: () => controller.refreshStatement(),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      final customers = controller.filteredCustomers;
      final isLoadingMore = controller.isLoadingMore.value;

      // Show empty state
      if (customers.isEmpty) {
        return Center(
          child: AppText.headlineLarge1(
            controller.searchQuery.value.isEmpty
                ? 'No ${controller.customerLabel} found'
                : 'No results found for "${controller.searchQuery.value}"',
            color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
          ),
        );
      }

      return ListView.builder(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: responsive.hp(10)),
        itemCount: customers.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Show loading indicator at the end
          if (index == customers.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: responsive.hp(2)),
              child: Center(
                child: CircularProgressIndicator(
                  color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
                  strokeWidth: 2.0,
                ),
              ),
            );
          }

          final customer = customers[index];
          return _buildCustomerItem(responsive, isDark, customer, controller);
        },
      );
    });
  }

  /// Individual Transaction Item using ListItemWidget
  Widget _buildCustomerItem(
    AdvancedResponsiveHelper responsive,
    bool isDark,
    LedgerTransactionItem item,
    CustomerStatementController controller,
  ) {
    // Use signedBalance for color determination
    final bool? isPositive = item.currentBalance == 0
        ? true  // GREEN for zero balance (settled)
        : BalanceHelper.isPositive(
            currentBalance: item.signedBalance,
            itemName: 'Statement Item: ${item.partyName}',
          );

    return ListItemWidget(
      title: item.partyName,
      subtitle: _formatDateTime(item.transactionDate),
      amount: Formatters.formatAmountWithCommas(item.currentBalance.abs().toString()),
      isPositiveAmount: isPositive,
      subtitleColor: isDark ? AppColors.textDisabled : AppColorsLight.black,
      titlePrefixIcon: SvgPicture.asset(
        item.isInTransaction ? AppIcons.arrowInIc : AppIcons.arrowOutIc,
        width: responsive.iconSizeMedium,
        height: responsive.iconSizeMedium,
        color: isDark ? AppColors.white : AppColorsLight.textSecondary,
      ),
      showBorder: true,
      onTap: () {
        debugPrint('Tapped on ${item.partyName}');
      },
    );
  }

  /// Download Button using AppButton
  Widget _buildDownloadButton(
    AdvancedResponsiveHelper responsive,
    bool isDark,
    CustomerStatementController controller,
  ) {
    return Obx(() => Stack(
      children:[
        Positioned.fill(child: CustomSingleBorderWidget(position: BorderPosition.top)),
        Container(
        width: double.infinity,
        margin: EdgeInsets.all(responsive.wp(4)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.containerDark, AppColors.containerDark]
                : [AppColorsLight.gradientColor1, AppColorsLight.gradientColor2],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
        ),
        child: AppButton(
          text: controller.isDownloading.value ? 'Downloading...' : 'Download',
          onPressed: controller.isDownloading.value ? null : () => controller.downloadStatement(),
          textColor: Colors.white,
          fontSize: responsive.fontSize(16),
          fontWeight: FontWeight.w600,
          height: responsive.hp(6.5),
          gradientColors: isDark
              ? [
                AppColors.splaceSecondary1, AppColors.splaceSecondary2
          ]
              :
          [
            AppColors.splaceSecondary1, AppColors.splaceSecondary2
          ],
          cornerRadius: responsive.borderRadiusSmall,
          padding: EdgeInsets.symmetric(
            horizontal: responsive.wp(4),
            vertical: responsive.hp(1.8),
          ),
          isLoading: controller.isDownloading.value,
        ),
      ),]
    ));
  }

  /// Format DateTime for display
  /// ✅ Always show real date format (not Today/Yesterday)
  String _formatDateTime(DateTime dateTime) {
    // Always show actual date: "18 Jan 2026, 14:30"
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }
}
