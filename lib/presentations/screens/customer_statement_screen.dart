import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/constants/app_icons.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_text.dart';
import '../../buttons/app_button.dart';
import '../../controllers/customer_statement_controller.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/responsive_layout/padding_navigation.dart';
import '../../core/utils/formatters.dart';
import '../../models/customer_statement_model.dart';
import '../widgets/custom_app_bar/custom_app_bar.dart';
import '../widgets/custom_app_bar/model/app_bar_config.dart';
import '../widgets/custom_single_border_color.dart';
import '../widgets/list_item_widget.dart';

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
        child: CustomResponsiveAppBar(
          config: AppBarConfig(
            type: AppBarType.searchWithFilter,
            customHeight: responsive.hp(19),
            enableSearchInput: true,
            showViewToggle: false,
            customPadding: EdgeInsets.symmetric(horizontal: responsive.wp(3)),
            // Search callback
            onSearchChanged: (query) {
              controller.searchQuery.value = query;
            },
            // Filter callback - opens filter bottom sheet
            onFiltersApplied: (filters) {
              debugPrint('🔍 Filters applied: $filters');
              // TODO: Implement filter logic for customer statement
              // You can add sorting and filtering logic here
            },
            // 🔥 NEW: Hide Reminder and User filters for customer statement
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
                SizedBox(width: responsive.spacing(2)),
                AppText.searchbar2(
                  controller.screenTitle,
                  color: isDark ? Colors.white : AppColorsLight.textPrimary,
                  fontWeight: FontWeight.w500,
                  maxLines: 1,
                  minFontSize: 13,
                  letterSpacing: 1.2,
                ),
              ],
            )
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
                strokeWidth: 1.0,
              ),
            );
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText.searchbar1(
                    'Error loading statement',
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

          final statement = controller.statementData.value;
          if (statement == null) {
            return Center(
              child: AppText.searchbar1(
                'No data available',
                color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
              ),
            );
          }

          return RefreshIndicator(
            color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
            backgroundColor: isDark ? AppColors.containerDark : AppColorsLight.white,
            onRefresh: () => controller.refreshStatement(),
            child: Column(
              children: [
                // Header Card with Net Balance
                _buildHeaderCard(responsive, isDark, statement, controller),
                // Summary Section with Yesterday IN/OUT
                _buildSummarySection(
                  responsive,
                  isDark,
                  statement,
                  controller,
                  null, // baseIconIn - can be customized
                  null, // topRightIconIn - can be customized
                  null, // baseIconOut - can be customized
                  null, // topRightIconOut - can be customized
                ),

                SizedBox(height: responsive.hp(2)),

                // Customer List Section
                Expanded(
                  child: _buildCustomerList(responsive, isDark, controller),
                ),
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value || controller.statementData.value == null) {
            return const SizedBox.shrink();
          }
          return _buildDownloadButton(responsive, isDark, controller);
        }),
      ),
    );
  }


  Widget _buildHeaderCard(
    AdvancedResponsiveHelper responsive,
    bool isDark,
    CustomerStatementModel statement,
    CustomerStatementController controller,
  ) {
    final isPositive = statement.netBalance >= 0;

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
                    AppText.displaySmall(
                      '₹${Formatters.formatAmountWithCommas(statement.netBalance.abs().toString())}',
                      color: isPositive
                          ? AppColors.primeryamount
                          : AppColors.red500,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
                AppText.headlineLarge1(
                  '${statement.totalCustomers} ${controller.customerLabel}',
                  color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          ),]
    );
  }

  /// Summary Section with Yesterday IN/OUT
  Widget _buildSummarySection(
    AdvancedResponsiveHelper responsive,
    bool isDark,
    CustomerStatementModel statement,
    CustomerStatementController controller,
    String? baseIconIn,
    String? topRightIconIn,
    String? baseIconOut,
    String? topRightIconOut,
  ) {
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
                        : [AppColorsLight.gradientColor1, AppColorsLight.gradientColor2],
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
                      'Total amount in yesterday',
                      color: isDark ? AppColors.white : AppColorsLight.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                    SizedBox(height: responsive.hp(0.5)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 6.0),
                          child: SvgPicture.asset(
                            AppIcons.vectoeIc3,
                            width: responsive.iconSizeSmall,
                            height: responsive.iconSizeSmall,
                          ),
                        ),
                        SizedBox(width: responsive.wp(0.8)),
                        AppText.displaySmall(
                          Formatters.formatAmountWithCommas(statement.yesterdayTotalIn.toString()),
                          color: AppColors.primeryamount,
                          fontWeight: FontWeight.w600,
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
                        : [AppColorsLight.gradientColor1, AppColorsLight.gradientColor2],
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
                      'Total amount out yesterday',
                      color: isDark ? AppColors.white : AppColorsLight.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                    SizedBox(height: responsive.hp(0.5)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding:  EdgeInsets.only(top: 6.0),
                          child: SvgPicture.asset(
                            AppIcons.vectoeIc3,
                            width: responsive.iconSizeSmall,
                            height: responsive.iconSizeSmall,
                          ),
                        ),
                        SizedBox(width: responsive.wp(0.9)),
                        AppText.displaySmall(
                          Formatters.formatAmountWithCommas(statement.yesterdayTotalOut.toString()),
                          color: AppColors.red500,
                          fontWeight: FontWeight.w600,
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

  /// Customer List Section
  Widget _buildCustomerList(
    AdvancedResponsiveHelper responsive,
    bool isDark,
    CustomerStatementController controller,
  ) {
    return Obx(() {
      final customers = controller.filteredCustomers;

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
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];
          return _buildCustomerItem(responsive, isDark, customer, controller);
        },
      );
    });
  }

  /// Individual Customer Item using ListItemWidget
  Widget _buildCustomerItem(
    AdvancedResponsiveHelper responsive,
    bool isDark,
    CustomerStatementItem customer,
    CustomerStatementController controller,
  ) {
    final isPositive = customer.balanceType == 'IN';

    return ListItemWidget(
      title: customer.name,
      subtitle: _formatDateTime(customer.lastTransactionDate),
      amount: Formatters.formatAmountWithCommas(customer.balance.toString()),
      isPositiveAmount: isPositive,
      subtitleColor: isDark ? AppColors.textDisabled : AppColorsLight.black,
      titlePrefixIcon: SvgPicture.asset(
        isPositive ? AppIcons.arrowInIc : AppIcons.arrowOutIc,
        width: responsive.iconSizeMedium,
        height: responsive.iconSizeMedium,
      ),
      showBorder: true,
      onTap: () {
        debugPrint('Tapped on ${customer.name}');
      },
    );
  }

  /// Download Button using AppButton
  Widget _buildDownloadButton(
    AdvancedResponsiveHelper responsive,
    bool isDark,
    CustomerStatementController controller,
  ) {
    return Stack(
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
          text: 'Download',
          onPressed: () => controller.downloadStatement(),
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
            AppColorsLight.gradientColor1, AppColorsLight.gradientColor2
          ],
          cornerRadius: responsive.borderRadiusSmall,
          padding: EdgeInsets.symmetric(
            horizontal: responsive.wp(4),
            vertical: responsive.hp(1.8),
          ),
        ),
      ),]
    );
  }

  /// Format DateTime for display
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (transactionDate == today) {
      return 'Today, ${DateFormat('HH:mm').format(dateTime)}';
    } else if (transactionDate == yesterday) {
      return 'Yesterday, ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    }
  }
}
