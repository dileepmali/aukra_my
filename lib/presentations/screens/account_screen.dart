import 'package:aukra_anantkaya_space/presentations/widgets/custom_single_border_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../app/constants/app_icons.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_text.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/responsive_layout/padding_navigation.dart';
import '../widgets/custom_app_bar/custom_app_bar.dart';
import '../widgets/custom_app_bar/model/app_bar_config.dart';
import '../../controllers/ledger_controller.dart';
import '../../controllers/account_controller.dart';
import '../../core/utils/formatters.dart';
import '../widgets/bottom_sheets/business_bottom_sheet.dart';
import '../../core/utils/balance_helper.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late AccountController _accountController;

  @override
  void initState() {
    super.initState();
    // Initialize AccountController
    try {
      _accountController = Get.find<AccountController>();
    } catch (e) {
      _accountController = Get.put(AccountController());
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ledgerController = Get.find<LedgerController>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.overlay : AppColorsLight.scaffoldBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(responsive.hp(12)),
        child: CustomResponsiveAppBar(
          config: AppBarConfig(
            type: AppBarType.titleOnly,
            customHeight: responsive.hp(12),
            customPadding: EdgeInsets.symmetric(horizontal: responsive.wp(3)),
            leadingWidget: Obx(() {
              final merchantName = ledgerController.merchantName.value.isEmpty
                  ? 'Aukra'
                  : ledgerController.merchantName.value;

              return GestureDetector(
                onTap: () async {
                  final selectedMerchant = await BusinessBottomSheet.show(
                    context: context,
                  );
                  if (selectedMerchant != null) {
                    debugPrint('🏢 Selected business: ${selectedMerchant.businessName}');
                    // Update merchant name in controller
                    ledgerController.merchantName.value = selectedMerchant.businessName;
                    // Refresh data
                    ledgerController.refreshAll();
                    _accountController.refreshDashboard();
                  }
                },
                child: Row(
                  children: [
                    AppText.searchbar2(
                      merchantName,
                      color: isDark ? Colors.white : AppColorsLight.textPrimary,
                      fontWeight: FontWeight.w500,
                      maxLines: 1,
                      minFontSize: 12,
                      letterSpacing: 1.2,
                    ),
                    SizedBox(width: responsive.spacing(8)),
                    SvgPicture.asset(
                      AppIcons.dropdownIc,
                      colorFilter: ColorFilter.mode(
                        isDark ? Colors.white : AppColorsLight.iconPrimary,
                        BlendMode.srcIn,
                      ),
                      width: responsive.iconSizeLarge,
                      height: responsive.iconSizeLarge,
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
      body: Obx(() {
        if (_accountController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
              strokeWidth: 1.0,
            ),
          );
        }

        if (_accountController.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText.searchbar1(
                  'Error loading dashboard',
                  color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: responsive.hp(1)),
                AppText.headlineLarge1(
                  _accountController.errorMessage.value,
                  color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                ),
                SizedBox(height: responsive.hp(2)),
                ElevatedButton(
                  onPressed: () => _accountController.refreshDashboard(),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
          backgroundColor: isDark ? AppColors.containerDark : AppColorsLight.white,
          onRefresh: () => _accountController.refreshDashboard(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(responsive.wp(0)),
            child: Column(
              children: [
                // Header Card - Total Net Balance
                _buildHeaderCard(responsive, isDark),
                SizedBox(height: responsive.hp(2)),

                // Customer Account Card
                _buildAccountCard(
                  responsive: responsive,
                  isDark: isDark,
                  title: 'Customer account',
                  icon: AppIcons.customerIc,
                  count: _accountController.totalCustomers,
                  countLabel: 'Customers',
                  balance: _accountController.customerNetBalance,
                  balanceType: _accountController.customerBalanceType,
                  onViewAll: () => _navigateToLedger(0), // Tab 0 = Customers
                ),
                SizedBox(height: responsive.hp(1)),

                // Suppliers Account Card
                _buildAccountCard(
                  responsive: responsive,
                  isDark: isDark,
                  title: 'Suppliers account',
                  icon: AppIcons.supplierIc,
                  count: _accountController.totalSuppliers,
                  countLabel: 'Suppliers',
                  balance: _accountController.supplierNetBalance,
                  balanceType: _accountController.supplierBalanceType,
                  onViewAll: () => _navigateToLedger(1), // Tab 1 = Suppliers
                ),
                SizedBox(height: responsive.hp(1)),

                // Employees Account Card
                _buildAccountCard(
                  responsive: responsive,
                  isDark: isDark,
                  title: 'Employees account',
                  icon: AppIcons.employeeIc,
                  count: _accountController.totalEmployees,
                  countLabel: 'Employees',
                  balance: _accountController.employeeNetBalance,
                  balanceType: _accountController.employeeBalanceType,
                  onViewAll: () => _navigateToLedger(2), // Tab 2 = Employees
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeaderCard(AdvancedResponsiveHelper responsive, bool isDark) {
    // ✅ Use netBalanceType from Dashboard API (not balance sign)
    final isPositive = _accountController.totalBalanceType == 'IN';

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
                AppText.searchbar2(
                  'Net balance',
                  color: isDark ? AppColors.white : AppColorsLight.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                Flexible(
                  child: AppText.searchbar2(
                    '₹${Formatters.formatAmountWithCommas(_accountController.totalNetBalance.abs().toString())}',
                    color: isPositive
                        ? AppColors.primeryamount
                        : AppColors.red500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: responsive.hp(0.5)),
            AppText.headlineLarge1(
              '${_accountController.totalCustomers} customers, ${_accountController.totalSuppliers} suppliers, ${_accountController.totalEmployees} employees',
              color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
      ),]
    );
  }

  Widget _buildAccountCard({
    required AdvancedResponsiveHelper responsive,
    required bool isDark,
    required String title,
    required String icon,
    required int count,
    required String countLabel,
    required double balance,
    required String balanceType,
    required VoidCallback onViewAll,
  }) {
    // ✅ Use balanceType from Dashboard API (not balance sign)
    final isPositive = balanceType == 'IN';

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: responsive.wp(4)),
      padding: EdgeInsets.symmetric(horizontal: responsive.wp(4),vertical: responsive.hp(1.5)),
      decoration: BoxDecoration(
        color: isDark ? AppColors.containerLight : AppColorsLight.white,
        borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
        border: Border.all(
          color: isDark ? AppColors.containerLight : AppColorsLight.containerLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon, title and "View all"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    icon,
                    width: responsive.iconSizeMedium,
                    height: responsive.iconSizeMedium,
                    colorFilter: ColorFilter.mode(
                      isDark ? AppColors.white : AppColorsLight.iconPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: responsive.spacing(8)),
                  AppText.searchbar2(
                    title,
                    color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
              GestureDetector(
                onTap: onViewAll,
                child: AppText.headlineLarge(
                  'View all',
                  color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.hp(1)),
          // Divider line
          Padding(
            padding: EdgeInsets.symmetric(vertical: responsive.hp(1.5)),
            child: Divider(
              color: isDark ? AppColors.containerDark : AppColorsLight.containerLight,
              thickness: 1,
              height: 1,
            ),
          ),
          // Net balance and count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.searchbar1(
                    'Net balance',
                    color: isDark ? AppColors.white : AppColorsLight.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                  SizedBox(height: responsive.hp(0.1)),
                  AppText.headlineLarge1(
                    '$count $countLabel',
                    color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
              Flexible(
                child: AppText.searchbar1(
                  '₹${Formatters.formatAmountWithCommas(balance.abs().toString())}',
                  color: isPositive
                      ? AppColors.primeryamount
                      : AppColors.red500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToLedger(int tabIndex) {
    // Navigate to customer statement screen with specific party type
    String partyType;
    String partyTypeLabel;

    switch (tabIndex) {
      case 0: // Customers
        partyType = 'CUSTOMER';
        partyTypeLabel = 'Customer';
        break;
      case 1: // Suppliers
        partyType = 'SUPPLIER';
        partyTypeLabel = 'Supplier';
        break;
      case 2: // Employees
        partyType = 'EMPLOYEE';
        partyTypeLabel = 'Employee';
        break;
      default:
        partyType = 'CUSTOMER';
        partyTypeLabel = 'Customer';
    }

    Get.toNamed('/customer-statement', arguments: {
      'partyType': partyType,
      'partyTypeLabel': partyTypeLabel,
    });
  }

  // void _navigateToLedger(int tabIndex) {
  //   // Navigate to ledger screen with specific tab
  //   Get.toNamed('/ledger', arguments: {'initialTab': tabIndex});
  // }
}
