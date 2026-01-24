import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/constants/app_icons.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_text.dart';
import '../../../controllers/ledger_controller.dart';
import '../../../core/api/ledger_detail_api.dart';
import '../../../core/api/ledger_transaction_api.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../../../models/ledger_detail_model.dart';
import '../../../models/transaction_list_model.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/balance_helper.dart';
import '../../widgets/list_item_widget_desktop.dart';
import '../../widgets/transaction_item_widget_desktop.dart';
import '../../../buttons/custom_floating_button_desktop.dart';
import '../../routes/app_routes.dart';

/// Desktop layout for Ledger Screen with Master-Detail pattern
/// Left (45%): Ledger list, Right (55%): Ledger detail
class LedgerDesktopContent extends StatefulWidget {
  final int selectedTabIndex; // 0=Customers, 1=Suppliers, 2=Employees

  const LedgerDesktopContent({
    Key? key,
    this.selectedTabIndex = 0,
  }) : super(key: key);

  @override
  State<LedgerDesktopContent> createState() => _LedgerDesktopContentState();
}

class _LedgerDesktopContentState extends State<LedgerDesktopContent> {
  int? _selectedLedgerId;

  // Get controller
  LedgerController get _ledgerController => Get.find<LedgerController>();

  void _onLedgerSelected(int ledgerId) {
    setState(() {
      _selectedLedgerId = ledgerId;
    });
    debugPrint('📋 Ledger selected: $ledgerId');
  }

  /// Get summary data based on selected tab
  Map<String, dynamic> _getSummaryData() {
    List<dynamic> items;
    String label;

    switch (widget.selectedTabIndex) {
      case 0:
        items = _ledgerController.filteredCustomers;
        label = 'Customers';
        break;
      case 1:
        items = _ledgerController.filteredSuppliers;
        label = 'Suppliers';
        break;
      case 2:
        items = _ledgerController.filteredEmployers;
        label = 'Employees';
        break;
      default:
        items = [];
        label = 'Items';
    }

    int totalCount = items.length;
    double youWillGet = 0;
    double youWillGive = 0;

    for (var item in items) {
      final balance = item.currentBalance ?? 0.0;
      if (balance > 0) {
        youWillGet += balance;
      } else {
        youWillGive += balance.abs();
      }
    }

    return {
      'label': label,
      'totalCount': totalCount,
      'youWillGet': youWillGet,
      'youWillGive': youWillGive,
    };
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // LEFT SIDE (45%): Ledger List
        Expanded(
          flex: 45,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.black : AppColorsLight.scaffoldBackground,
              border: Border(
                right: BorderSide(
                  color: isDark ? AppColors.borderAccent : AppColorsLight.border,
                  width: 1,
                ),
              ),
            ),
            child: Padding(
              padding:  EdgeInsets.symmetric(horizontal: responsive.wp(1),),
              child: Column(
                children: [
                  // Summary cards (3 containers with different colors)
                  Padding(
                    padding: EdgeInsets.symmetric( vertical: responsive.hp(1)),
                    child: _buildSummaryCards(responsive, isDark),
                  ),
                  // Search bar
                  _buildSearchBar(responsive, isDark),
                  // Ledger list
                  Expanded(
                    child: _buildLedgerList(responsive, isDark),
                  ),
                ],
              ),
            ),
          ),
        ),

        // RIGHT SIDE (55%): Ledger Detail
        Expanded(
          flex: 55,
          child: _selectedLedgerId != null
              ? _DesktopLedgerDetailContent(
                  ledgerId: _selectedLedgerId!,
                  onBack: () {
                    setState(() {
                      _selectedLedgerId = null;
                    });
                  },
                )
              : _buildEmptyDetailState(responsive, isDark),
        ),
      ],
    );
  }

  /// Summary cards with 3 colored containers
  Widget _buildSummaryCards(AdvancedResponsiveHelper responsive, bool isDark) {
    return Obx(() {
      final data = _getSummaryData();
      final totalCount = data['totalCount'] as int;
      final youWillGet = data['youWillGet'] as double;
      final youWillGive = data['youWillGive'] as double;
      final label = data['label'] as String;

      return Container(
        padding: EdgeInsets.all(responsive.wp(1)),
        decoration: BoxDecoration(
          color: isDark ? AppColors.black : AppColorsLight.white,
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppColors.borderAccent : AppColorsLight.border,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Card 1: Total Count (Purple/Gradient)
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.wp(0.8),
                  vertical: responsive.hp(1.2),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.splaceSecondary1, AppColors.splaceSecondary2]
                        : [AppColorsLight.gradientColor1, AppColorsLight.gradientColor2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bodySmall(
                      'Total $label',
                      color: Colors.white.withOpacity(0.8),
                    ),
                    SizedBox(height: responsive.hp(0.3)),
                    AppText.headlineMedium(
                      '$totalCount',
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: responsive.wp(0.5)),
            // Card 2: You Will Get (Green/Blue)
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.wp(0.8),
                  vertical: responsive.hp(1.2),
                ),
                decoration: BoxDecoration(
                  color: AppColors.primeryamount.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                  border: Border.all(
                    color: AppColors.primeryamount.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bodySmall(
                      'You Will Get',
                      color: isDark ? AppColors.primeryamount : AppColors.primeryamount,
                    ),
                    SizedBox(height: responsive.hp(0.3)),
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.vectoeIc3,
                          width: 10,
                          height: 10,
                          colorFilter: ColorFilter.mode(
                            AppColors.primeryamount,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 3),
                        Expanded(
                          child: AppText.headlineMedium(
                            NumberFormat('#,##,##0.00', 'en_IN').format(youWillGet),
                            color: AppColors.primeryamount,
                            fontWeight: FontWeight.w700,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: responsive.wp(0.5)),
            // Card 3: You Will Give (Red)
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.wp(0.8),
                  vertical: responsive.hp(1.2),
                ),
                decoration: BoxDecoration(
                  color: AppColors.red500.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                  border: Border.all(
                    color: AppColors.red500.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bodySmall(
                      'You Will Give',
                      color: AppColors.red500,
                    ),
                    SizedBox(height: responsive.hp(0.3)),
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.vectoeIc3,
                          width: 10,
                          height: 10,
                          colorFilter: ColorFilter.mode(
                            AppColors.red500,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 3),
                        Expanded(
                          child: AppText.headlineMedium(
                            NumberFormat('#,##,##0.00', 'en_IN').format(youWillGive),
                            color: AppColors.red500,
                            fontWeight: FontWeight.w700,
                            maxLines: 1,
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
      );
    });
  }

  /// Search bar
  Widget _buildSearchBar(AdvancedResponsiveHelper responsive, bool isDark) {
    final tabNames = ['customers', 'suppliers', 'employees'];

    return Row(
      children: [
        // Search bar
        Expanded(
          child: GestureDetector(
            onTap: () {
              String partyType;
              String partyTypeLabel;
              switch (widget.selectedTabIndex) {
                case 0:
                  partyType = 'CUSTOMER';
                  partyTypeLabel = 'Customer';
                  break;
                case 1:
                  partyType = 'SUPPLIER';
                  partyTypeLabel = 'Supplier';
                  break;
                case 2:
                  partyType = 'EMPLOYEE';
                  partyTypeLabel = 'Employee';
                  break;
                default:
                  partyType = 'CUSTOMER';
                  partyTypeLabel = 'Customer';
              }
              Get.toNamed('/search-screen', arguments: {
                'partyType': partyType,
                'partyTypeLabel': partyTypeLabel,
              });
            },
            child: Container(

              padding: EdgeInsets.symmetric(
                horizontal: responsive.wp(1),
                vertical: responsive.hp(1.5),
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.containerLight : AppColorsLight.background,
                borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                border: Border.all(
                  color: isDark ? AppColors.borderAccent : AppColorsLight.shadowMedium,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppIcons.searchIIc,
                    width: responsive.iconSizeSmall,
                    height: responsive.iconSizeSmall,
                    colorFilter: ColorFilter.mode(
                      isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: responsive.wp(0.5)),
                  AppText.bodyMedium(
                    'Search ${tabNames[widget.selectedTabIndex]}...',
                    color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: responsive.wp(0.3)),
        // Filter button - same height as search bar
        Container(
          height: responsive.hp(5.5),
          width: responsive.wp(3),
          padding: EdgeInsets.symmetric(
            horizontal: responsive.wp(0.8),
            vertical: responsive.hp(1.2),
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.containerLight : AppColorsLight.shadowMedium,
            borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
            border: Border.all(
              color: isDark ? AppColors.borderAccent : AppColorsLight.border,
              width: 1,
            ),
          ),
          child: SvgPicture.asset(
            AppIcons.filtersIc,
            width: responsive.iconSizeSmall,
            height: responsive.iconSizeSmall,
            colorFilter: ColorFilter.mode(
              isDark ? AppColors.white : AppColorsLight.iconPrimary,
              BlendMode.srcIn,
            ),
          ),
        ),
        SizedBox(width: responsive.wp(1.5)),
        // Add Customer/Supplier/Employee button
        CustomFloatingActionButtonDesktop(
          onPressed: () {
            String partyType;
            switch (widget.selectedTabIndex) {
              case 0:
                partyType = 'customer';
                break;
              case 1:
                partyType = 'supplier';
                break;
              case 2:
                partyType = 'employee';
                break;
              default:
                partyType = 'customer';
            }
            debugPrint('🚀 FAB clicked - Navigating with partyType: $partyType');
            Get.toNamed(
              AppRoutes.addCustomer,
              arguments: {'partyType': partyType},
              preventDuplicates: false,
            )?.then((_) {
              debugPrint('🔄 Returned from Add Customer - Refreshing ledger...');
              _ledgerController.refreshAll();
            });
          },
          screenType: tabNames[widget.selectedTabIndex],
        ),
      ],
    );
  }

  /// Ledger list based on selected tab
  Widget _buildLedgerList(AdvancedResponsiveHelper responsive, bool isDark) {
    return Obx(() {
      if (_ledgerController.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
            strokeWidth: 2.0,
          ),
        );
      }

      List<dynamic> items;
      ScrollController scrollController;
      bool isLoadingMore;
      String emptyMessage;
      String defaultAvatar;

      switch (widget.selectedTabIndex) {
        case 0: // Customers
          items = _ledgerController.filteredCustomers;
          scrollController = _ledgerController.customersScrollController;
          isLoadingMore = _ledgerController.customersIsLoadingMore.value;
          emptyMessage = _ledgerController.customers.isEmpty ? 'No customers found' : 'No results match your filters';
          defaultAvatar = 'C';
          break;
        case 1: // Suppliers
          items = _ledgerController.filteredSuppliers;
          scrollController = _ledgerController.suppliersScrollController;
          isLoadingMore = _ledgerController.suppliersIsLoadingMore.value;
          emptyMessage = _ledgerController.suppliers.isEmpty ? 'No suppliers found' : 'No results match your filters';
          defaultAvatar = 'S';
          break;
        case 2: // Employees
          items = _ledgerController.filteredEmployers;
          scrollController = _ledgerController.employeesScrollController;
          isLoadingMore = _ledgerController.employeesIsLoadingMore.value;
          emptyMessage = _ledgerController.employers.isEmpty ? 'No employees found' : 'No results match your filters';
          defaultAvatar = 'E';
          break;
        default:
          return const SizedBox.shrink();
      }

      if (items.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => _ledgerController.refreshAll(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: responsive.hp(20)),
              Center(
                child: AppText.bodyLarge(
                  emptyMessage,
                  color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => _ledgerController.refreshAll(),
        child: ListView.builder(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric( vertical: responsive.hp(1)),
          itemCount: items.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == items.length) {
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

            final item = items[index];
            final isSelected = _selectedLedgerId == item.id;

            return _buildLedgerListItem(
              responsive,
              isDark,
              item,
              defaultAvatar,
              index,
              isSelected,
            );
          },
        ),
      );
    });
  }

  /// Individual ledger list item
  Widget _buildLedgerListItem(
    AdvancedResponsiveHelper responsive,
    bool isDark,
    dynamic item,
    String defaultAvatar,
    int index,
    bool isSelected,
  ) {
    // Format subtitle with date, time and area
    String subtitle = '';
    final displayDate = item.updatedAt ?? item.createdAt;
    if (displayDate != null) {
      final localTime = displayDate.toLocal();
      final dateFormat = DateFormat('d MMM yyyy');
      final timeFormat = DateFormat('HH:mm');
      final formattedDate = dateFormat.format(localTime);
      final formattedTime = timeFormat.format(localTime);
      subtitle = '$formattedDate, $formattedTime';
    } else {
      subtitle = 'No date available';
    }

    if (item.address != null && item.address.isNotEmpty) {
      subtitle += ' • ${item.address}';
    } else if (item.area.isNotEmpty) {
      subtitle += ' • ${item.area}';
    }

    final amount = '₹${item.currentBalance.abs().toStringAsFixed(2)}';
    final isPositive = BalanceHelper.isPositive(
      currentBalance: item.currentBalance,
      itemName: '${item.name}',
    );

    // Desktop ListItemWidget with desktop-appropriate sizing
    return ListItemWidgetDesktop(
      title: item.name.isNotEmpty
          ? Formatters.truncateName(item.name)
          : '$defaultAvatar #${index + 1}',
      subtitle: subtitle,
      amount: amount,
      isPositiveAmount: isPositive,
      showAvatar: true,
      backgroundColor: isDark ? AppColors.containerLight : AppColorsLight.background,
      avatarText: item.name.isNotEmpty
          ? item.name.substring(0, item.name.length >= 2 ? 2 : 1).toUpperCase()
          : defaultAvatar,
      avatarBackgroundGradient: LinearGradient(
        colors: [AppColors.splaceSecondary2, AppColors.splaceSecondary1],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      avatarTextColor: AppColors.white,
      showBorder: true,
      onTap: () => _onLedgerSelected(item.id),
    );
  }

  /// Empty detail state (when no ledger is selected)
  Widget _buildEmptyDetailState(AdvancedResponsiveHelper responsive, bool isDark) {
    final tabNames = ['customer', 'supplier', 'employee'];

    return Container(
      color: isDark ? AppColors.containerLight : AppColorsLight.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppIcons.folderIc,
              width: responsive.wp(8),
              height: responsive.wp(8),
              colorFilter: ColorFilter.mode(
                isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(height: responsive.hp(2)),
            AppText.headlineMedium(
              'Select a ${tabNames[widget.selectedTabIndex]}',
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
            SizedBox(height: responsive.hp(1)),
            AppText.bodyMedium(
              'Choose from the list to view details',
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Desktop Ledger Detail Content Widget
class _DesktopLedgerDetailContent extends StatefulWidget {
  final int ledgerId;
  final VoidCallback onBack;

  const _DesktopLedgerDetailContent({
    required this.ledgerId,
    required this.onBack,
  });

  @override
  State<_DesktopLedgerDetailContent> createState() => _DesktopLedgerDetailContentState();
}

class _DesktopLedgerDetailContentState extends State<_DesktopLedgerDetailContent> {
  late _DesktopLedgerDetailController _controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(_DesktopLedgerDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ledgerId != widget.ledgerId) {
      _initController();
    }
  }

  void _initController() {
    final tag = 'desktop_${widget.ledgerId}';

    // Delete existing controller with this tag if exists
    if (Get.isRegistered<_DesktopLedgerDetailController>(tag: tag)) {
      Get.delete<_DesktopLedgerDetailController>(tag: tag);
    }

    // Create desktop-specific controller with ledgerId via constructor
    _controller = Get.put(
      _DesktopLedgerDetailController(widget.ledgerId),
      tag: tag,
    );
  }

  @override
  void dispose() {
    // Clean up controller
    if (Get.isRegistered<_DesktopLedgerDetailController>(tag: 'desktop_${widget.ledgerId}')) {
      Get.delete<_DesktopLedgerDetailController>(tag: 'desktop_${widget.ledgerId}');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.containerLight : AppColorsLight.background,
      child: Column(
        children: [
          // Header with 4 containers: Avatar+Info, Balance, Icons, IN/OUT buttons
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: responsive.wp(1)),
            child: _buildHeader(responsive, isDark),
          ),

          // Transaction list
          Expanded(
            child: _buildTransactionList(responsive, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AdvancedResponsiveHelper responsive, bool isDark) {
    return Obx(() {
      final detail = _controller.ledgerDetail.value;
      final name = detail?.partyName ?? 'Loading...';
      final mobile = detail?.mobileNumber ?? '';
      final area = detail?.area ?? '';
      final balance = detail?.currentBalance ?? 0.0;
      final isZeroBalance = balance.abs() < 0.01;

      String getInitials(String name) {
        final parts = name.trim().split(' ');
        if (parts.isEmpty) return 'L';
        if (parts.length == 1) {
          return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'L';
        }
        return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
      }

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.wp(1),
          vertical: responsive.hp(1),
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.black : AppColorsLight.scaffoldBackground.withOpacity(0.3),
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppColors.borderAccent : AppColorsLight.border,
              width: 1,
            ),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Container 1: Avatar + Ledger Name + Subtitle (number, area)
              Expanded(
                child: Row(
                children: [
                  // Avatar
                  Container(
                    width: responsive.wp(3),
                    height: responsive.wp(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.splaceSecondary1, AppColors.splaceSecondary2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        getInitials(name),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: responsive.wp(0.5)),
                  // Name and details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (mobile.isNotEmpty || area.isNotEmpty)
                          Text(
                            [if (mobile.isNotEmpty) mobile, if (area.isNotEmpty) area].join(' • '),
                            style: TextStyle(
                              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Vertical Divider 1
            VerticalDivider(
              width: responsive.wp(1),
              thickness: 1,
              color: isDark ? AppColors.borderAccent : AppColorsLight.border,
            ),

            // Container 2: Closing Balance (no border)
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.wp(0.8),
                  vertical: responsive.hp(0.5),
                ),
                child: Row(
                  children: [
                    // Left side: Balance info
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Closing Balance',
                            style: TextStyle(
                              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                AppIcons.vectoeIc3,
                                width: 10,
                                height: 10,
                                colorFilter: ColorFilter.mode(
                                  isZeroBalance
                                      ? (isDark ? AppColors.white : AppColorsLight.textPrimary)
                                      : BalanceHelper.getBalanceColorFromValue(balance),
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  isZeroBalance
                                      ? '0.00'
                                      : NumberFormat('#,##,##0.00', 'en_IN').format(balance.abs()),
                                  style: TextStyle(
                                    color: isZeroBalance
                                        ? (isDark ? AppColors.white : AppColorsLight.textPrimary)
                                        : BalanceHelper.getBalanceColorFromValue(balance),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Right side: Stack with 3 SVG icons (like mobile)
                    if (!isZeroBalance)
                      SizedBox(
                        width: responsive.wp(3),
                        height: responsive.wp(3),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Base SVG icon - changes based on balance
                            SvgPicture.asset(
                              balance < 0 ? AppIcons.vectoeIc1 : AppIcons.vectoeIc4,
                              width: responsive.wp(2.0),
                              height: responsive.wp(2.0),
                            ),
                            // Center stacked icon (rupee)
                            SvgPicture.asset(
                              AppIcons.vectoeIc3,
                              width: responsive.wp(0.8),
                              height: responsive.wp(0.8),
                            ),
                            // Top right stacked icon - changes based on balance
                            Positioned(
                              top: 3,
                              right: 3,
                              child: SvgPicture.asset(
                                balance < 0 ? AppIcons.vectoeIc2 : AppIcons.vectoeIc6,
                                width: responsive.wp(1),
                                height: responsive.wp(1),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Vertical Divider 2
            VerticalDivider(
              width: responsive.wp(1),
              thickness: 1,
              color: isDark ? AppColors.borderAccent : AppColorsLight.border,
            ),

            // Container 3: 4 Action Icons (no border)
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.wp(0.2),
                  vertical: responsive.hp(0.8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionIcon(responsive, isDark, AppIcons.notificationLightIc, () {}),
                    _buildActionIcon(responsive, isDark, AppIcons.whatsappLightIc, () {}),
                    _buildActionIcon(responsive, isDark, AppIcons.reminderLightIc, () {}),
                    // More options icon (Material icon)
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.all(responsive.wp(0.7)),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.containerLight : AppColorsLight.white,
                          borderRadius: BorderRadius.circular(responsive.borderRadiusExtraLarge2),
                        ),
                        child: Icon(
                          Icons.more_vert,
                          size: responsive.iconSizeSmall,
                          color: isDark ? AppColors.white : AppColorsLight.iconPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Vertical Divider 3
            VerticalDivider(
              width: responsive.wp(1),
              thickness: 1,
              color: isDark ? AppColors.borderAccent : AppColorsLight.border,
            ),

            // Container 4: IN and OUT Buttons
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // IN Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final result = await Get.toNamed(
                          '/add-transaction',
                          arguments: {
                            'ledgerId': widget.ledgerId,
                            'customerName': detail?.partyName ?? 'Customer',
                            'customerLocation': detail?.area ?? '',
                            'closingBalance': detail?.currentBalance ?? 0.0,
                            'accountType': detail?.partyType ?? 'CUSTOMER',
                            'defaultTransactionType': 'IN',
                          },
                        );
                        if (result == true) {
                          await _controller.refreshAll();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: responsive.hp(0.8),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primeryamount,
                          borderRadius: BorderRadius.circular(responsive.borderRadiusExtraLarge1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppIcons.arrowInIc,
                              width: responsive.iconSizeSmall,
                              height: responsive.iconSizeSmall,
                              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                            ),
                            SizedBox(width: responsive.wp(0.3)),
                            Text(
                              'IN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: responsive.wp(0.3)),
                  // OUT Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final result = await Get.toNamed(
                          '/add-transaction',
                          arguments: {
                            'ledgerId': widget.ledgerId,
                            'customerName': detail?.partyName ?? 'Customer',
                            'customerLocation': detail?.area ?? '',
                            'closingBalance': detail?.currentBalance ?? 0.0,
                            'accountType': detail?.partyType ?? 'CUSTOMER',
                            'defaultTransactionType': 'OUT',
                          },
                        );
                        if (result == true) {
                          await _controller.refreshAll();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: responsive.hp(0.8),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.red500,
                          borderRadius: BorderRadius.circular(responsive.borderRadiusExtraLarge1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppIcons.arrowOutIc,
                              width: responsive.iconSizeSmall,
                              height: responsive.iconSizeSmall,
                              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                            ),
                            SizedBox(width: responsive.wp(0.3)),
                            Text(
                              'OUT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActionIcon(AdvancedResponsiveHelper responsive, bool isDark, String icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(responsive.wp(0.7)),
        decoration: BoxDecoration(
          color: isDark ? AppColors.containerLight : AppColorsLight.white,
          borderRadius: BorderRadius.circular(responsive.borderRadiusExtraLarge2),
        ),
        child: SvgPicture.asset(
          icon,
          width: responsive.iconSizeSmall,
          height: responsive.iconSizeSmall,
        ),
      ),
    );
  }

  Widget _buildTransactionList(AdvancedResponsiveHelper responsive, bool isDark) {
    return Obx(() {
      if (_controller.isTransactionsLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
            strokeWidth: 2.0,
          ),
        );
      }

      final history = _controller.transactionHistory.value;
      if (history == null || history.data.isEmpty) {
        return Center(
          child: AppText.bodyLarge(
            'No transactions found',
            color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
          ),
        );
      }

      return Column(
        children: [
          // Header Row with column titles
          const TransactionListHeaderDesktop(),
          // Transaction List
          Expanded(
            child: ListView.builder(
              controller: _controller.scrollController,
              itemCount: history.data.length,
              itemBuilder: (context, index) {
                final transaction = history.data[index];
                return TransactionItemWidgetDesktop(
                  transaction: transaction,
                  onTap: () {
                    // Handle transaction tap if needed
                  },
                );
              },
            ),
          ),
        ],
      );
    });
  }

}

/// Desktop-specific LedgerDetailController that accepts ledgerId via constructor
class _DesktopLedgerDetailController extends GetxController {
  final int ledgerId;

  _DesktopLedgerDetailController(this.ledgerId);

  final LedgerDetailApi _api = LedgerDetailApi();
  final LedgerTransactionApi _transactionApi = LedgerTransactionApi();

  // Observable states
  var isLoading = true.obs;
  var isTransactionsLoading = true.obs;

  // Pagination states
  var isLoadingMore = false.obs;
  var hasMoreData = true.obs;
  var currentOffset = 0.obs;
  final int _limit = 10;
  var totalTransactionCount = 0.obs;

  // ScrollController for infinite scrolling
  final ScrollController scrollController = ScrollController();

  // Ledger detail data
  Rx<LedgerDetailModel?> ledgerDetail = Rx<LedgerDetailModel?>(null);

  // Transaction history data
  Rx<TransactionListModel?> transactionHistory = Rx<TransactionListModel?>(null);

  // All loaded transactions
  RxList<TransactionItemModel> allTransactions = <TransactionItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('📋 DesktopLedgerDetailController initialized with ledger ID: $ledgerId');
    _setupScrollListener();

    if (ledgerId > 0) {
      refreshAll();
    } else {
      debugPrint('❌ Invalid ledger ID provided');
      isLoading.value = false;
      isTransactionsLoading.value = false;
    }
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.hasClients) {
        final maxScroll = scrollController.position.maxScrollExtent;
        final currentScroll = scrollController.position.pixels;
        final threshold = maxScroll * 0.8;

        if (currentScroll >= threshold && !isLoadingMore.value && hasMoreData.value) {
          loadMoreTransactions();
        }
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchLedgerDetails() async {
    try {
      isLoading.value = true;
      final detail = await _api.getLedgerDetails(ledgerId);
      ledgerDetail.value = detail;
    } catch (e) {
      debugPrint('❌ Error fetching ledger details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTransactions() async {
    try {
      isTransactionsLoading.value = true;
      currentOffset.value = 0;
      hasMoreData.value = true;
      allTransactions.clear();

      final history = await _transactionApi.getLedgerTransactions(
        ledgerId: ledgerId,
        skip: currentOffset.value,
        limit: _limit,
      );

      totalTransactionCount.value = history.totalCount;

      final sortedData = List.of(history.data);
      sortedData.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.transactionDate);
          final dateB = DateTime.parse(b.transactionDate);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });

      allTransactions.addAll(sortedData);
      hasMoreData.value = allTransactions.length < totalTransactionCount.value;

      transactionHistory.value = TransactionListModel(
        count: allTransactions.length,
        totalCount: totalTransactionCount.value,
        data: allTransactions.toList(),
      );
    } catch (e) {
      debugPrint('❌ Error fetching transactions: $e');
    } finally {
      isTransactionsLoading.value = false;
    }
  }

  Future<void> loadMoreTransactions() async {
    if (isLoadingMore.value || !hasMoreData.value) return;

    try {
      isLoadingMore.value = true;
      final nextOffset = currentOffset.value + _limit;

      final history = await _transactionApi.getLedgerTransactions(
        ledgerId: ledgerId,
        skip: nextOffset,
        limit: _limit,
      );

      if (history.data.isEmpty) {
        hasMoreData.value = false;
        return;
      }

      currentOffset.value = nextOffset;

      final sortedData = List.of(history.data);
      sortedData.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.transactionDate);
          final dateB = DateTime.parse(b.transactionDate);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });

      allTransactions.addAll(sortedData);
      hasMoreData.value = allTransactions.length < totalTransactionCount.value;

      transactionHistory.value = TransactionListModel(
        count: allTransactions.length,
        totalCount: totalTransactionCount.value,
        data: allTransactions.toList(),
      );
    } catch (e) {
      debugPrint('❌ Error loading more transactions: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([
      fetchLedgerDetails(),
      fetchTransactions(),
    ]);
  }
}