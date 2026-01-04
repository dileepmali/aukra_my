import 'package:aukra_anantkaya_space/presentations/widgets/custom_single_border_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/constants/app_icons.dart';
import '../../app/localizations/l10n/app_localizations.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_text.dart';
import '../../buttons/custom_floating_button.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/responsive_layout/padding_navigation.dart';
import '../widgets/custom_app_bar/custom_app_bar.dart';
import '../widgets/custom_app_bar/model/app_bar_config.dart';
import '../widgets/list_item_widget.dart';
import '../../controllers/ledger_controller.dart';

class LedgerScreen extends StatefulWidget {
  final ValueChanged<int>? onTabChanged;

  const LedgerScreen({super.key, this.onTabChanged});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = true;
  String? _currentFilter;
  String? _currentSortBy;
  String? _currentSortOrder;
  int _selectedTabIndex = 0;

  // Use Get.find() to get controller from binding
  LedgerController get _ledgerController => Get.find<LedgerController>();

  @override
  void initState() {
    super.initState();
    // Add lifecycle observer to detect when screen becomes visible
    WidgetsBinding.instance.addObserver(this);

    // Controller is initialized by MainBinding, just ensure it's available
    try {
      final controller = Get.find<LedgerController>();
      debugPrint('✅ LedgerController found: ${controller.merchantName.value}');
    } catch (e) {
      debugPrint('⚠️ LedgerController not found, creating new instance');
      // If not found, initialize it (fallback)
      Get.put(LedgerController(), permanent: true);
    }

    // Don't call refreshAll here - let the controller's onInit handle the initial load
    // Only refresh if data is empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _ledgerController.allLedgers.isEmpty) {
        debugPrint('🔄 Initial load - fetching ledgers...');
        _ledgerController.refreshAll();
      }

      // Notify parent about initial tab (default is 0 - Customers)
      widget.onTabChanged?.call(_selectedTabIndex);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh data when app returns to foreground
    if (state == AppLifecycleState.resumed && mounted) {
      debugPrint('📱 App resumed - refreshing ledger data...');
      _ledgerController.refreshAll();
    }
  }

  @override
  void dispose() {
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  void _handleFiltersApplied(Map<String, dynamic> filters) {
    setState(() {
      _currentFilter = filters['filter'];
      _currentSortBy = filters['sortBy'];
      _currentSortOrder = filters['sortOrder'];
    });

    // TODO: Implement filter logic here
    debugPrint('Filters applied: $filters');
  }

  void _handleSearchChanged(String query) {
    // TODO: Implement search logic here
    debugPrint('Search query: $query');
  }

  void _handleViewToggle(bool isGrid) {
    setState(() {
      _isGridView = isGrid;
    });
    // TODO: Implement view toggle logic here
    debugPrint('View changed to: ${isGrid ? "Grid" : "List"}');
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.overlay : AppColorsLight.scaffoldBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(responsive.hp(20)),
        child: _buildAppBar(context, responsive),
      ),
      body: Column(
        children: [
          _buildTabBar(responsive, isDark),
          Expanded(
            child: _buildTabContent(responsive, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AdvancedResponsiveHelper responsive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomResponsiveAppBar(
      config: AppBarConfig(
        type: AppBarType.searchWithFilter,
        searchController: _searchController,
        searchHint: 'Search ledger...',
        onSearchChanged: _handleSearchChanged,
        isGridView: _isGridView,
        onViewToggle: _handleViewToggle,
        enableSearchInput: true,
        showViewToggle: false,
        onFiltersApplied: _handleFiltersApplied,
        currentFilter: _currentFilter,
        currentSortBy: _currentSortBy,
        currentSortOrder: _currentSortOrder,
        customHeight: responsive.hp(19),
        customPadding: EdgeInsets.symmetric(horizontal: responsive.wp(3)),
        leadingWidget: Obx(() {
          final merchantName = _ledgerController.merchantName.value.isEmpty
              ? 'Aukra'
              : _ledgerController.merchantName.value;

          debugPrint('🏢 Displaying merchant name: $merchantName');

          return Row(
            children: [
              AppText.custom(
                merchantName,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColorsLight.textPrimary,
                  fontSize: responsive.fontSize(20),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                minFontSize: 13,
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
          );
        }),
      ),
    );
  }

  Widget _buildTabBar(AdvancedResponsiveHelper responsive, bool isDark) {
    final tabs = ['Customers', 'Suppliers', 'Employers'];

    return Stack(
      children: [
        Container(
        color: isDark ? AppColors.black : AppColorsLight.background,
        padding: EdgeInsets.symmetric(
          horizontal: responsive.wp(2),
          vertical: responsive.hp(1.5),
        ),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = _selectedTabIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                  // Notify parent about tab change
                  widget.onTabChanged?.call(index);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: responsive.spacing(4)),
                  padding: EdgeInsets.symmetric(vertical: responsive.hp(1.4)),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? (isDark
                            ? LinearGradient(
                                colors: [AppColors.containerDark, AppColors.containerLight],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              )
                            : AppColorsLight.brandGradient)
                        : null,
                    color: !isSelected
                        ? (isDark ? AppColors.transparent : AppColorsLight.transparent)
                        : null,
                    borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                  ),
                  child: Center(
                    child: AppText.custom(
                      tabs[index],
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.white
                            : (isDark ? AppColors.textSecondary : AppColorsLight.textSecondary),
                        fontSize: responsive.fontSize(15),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      maxLines: 1,
                      minFontSize: 10,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
        Positioned.fill(
            child: CustomSingleBorderWidget(
                position: BorderPosition.bottom,
              borderWidth: 1.5,
            ))
      ]
    );
  }

  Widget _buildTabContent(AdvancedResponsiveHelper responsive, bool isDark) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildCustomersTab(responsive, isDark);
      case 1:
        return _buildSuppliersTab(responsive, isDark);
      case 2:
        return _buildEmployersTab(responsive, isDark);
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildCustomersTab(AdvancedResponsiveHelper responsive, bool isDark) {
    return Container(
      color: isDark ? AppColors.containerLight : AppColorsLight.background,
      child: Obx(() {
        if (_ledgerController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
              strokeWidth: 1.0,

            ),
          );
        }

        return RefreshIndicator(
          color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
          backgroundColor: isDark ? AppColors.containerDark : AppColorsLight.white,
          onRefresh: () async {
            await _ledgerController.refreshAll();
          },
          child: _ledgerController.customers.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: responsive.hp(30)),
                    Center(
                      child: AppText.custom(
                        'No customers found',
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                          fontSize: responsive.fontSize(16),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: responsive.wp(1),
                    right: responsive.wp(1),
                    top: responsive.hp(2),
                    bottom: responsive.hp(30), // Add bottom padding for better scrolling
                  ),
                  itemCount: _ledgerController.customers.length,
                  itemBuilder: (context, index) {
                    final customer = _ledgerController.customers[index];

                    // Format creation date and time
                    String subtitle = '';
                    if (customer.createdAt != null) {
                      // Convert UTC to local time
                      final localTime = customer.createdAt!.toLocal();
                      final timeFormat = DateFormat('hh:mm a');
                      final dateFormat = DateFormat('d MMM yyyy');
                      final formattedTime = timeFormat.format(localTime);
                      final formattedDate = dateFormat.format(localTime);
                      subtitle = '$formattedTime, $formattedDate';
                    } else {
                      subtitle = 'No date available';
                    }

                    // Debug: Print balance and transaction type
                    debugPrint('💰 ${customer.name}: Balance=${customer.openingBalance}, Type=${customer.transactionType}');

                    // Format amount
                    final amount = '₹${customer.openingBalance.abs().toStringAsFixed(2)}';
                    // For customers:
                    // OUT = You gave them goods/money, they owe you = Blue (Receivable)
                    // IN = They gave you money/returned goods, you owe them = Red (Payable/Credit)
                    final isPositive = customer.transactionType == 'OUT';

                    return ListItemWidget(
                      title: customer.name.isNotEmpty ? customer.name : 'Customer #${index + 1}',
                      subtitle: subtitle,
                      amount: amount,
                      isPositiveAmount: isPositive,
                      showAvatar: true,
                      avatarText: customer.name.isNotEmpty
                          ? customer.name.substring(0, customer.name.length >= 2 ? 2 : 1).toUpperCase()
                          : 'C',
                      avatarBackgroundGradient: isDark
                          ? LinearGradient(
                              colors: [AppColors.splaceSecondary2, AppColors.splaceSecondary1],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [AppColorsLight.splaceSecondary1, AppColorsLight.gradientColor2],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      avatarTextColor: AppColors.white,
                      onTap: () {
                        debugPrint('Customer tapped: ${customer.name}');
                        Get.toNamed('/ledger-detail', arguments: {
                          'ledgerId': customer.id,
                        });
                      },
                    );
                  },
                ),
        );
      }),
    );
  }

  Widget _buildSuppliersTab(AdvancedResponsiveHelper responsive, bool isDark) {
    return Container(
      color: isDark ? AppColors.containerLight : AppColorsLight.background,
      child: Obx(() {
        if (_ledgerController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
              strokeWidth: 1.0,
            ),
          );
        }

        return RefreshIndicator(
          color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
          backgroundColor: isDark ? AppColors.containerDark : AppColorsLight.white,
          onRefresh: () async {
            await _ledgerController.refreshAll();
          },
          child: _ledgerController.suppliers.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: responsive.hp(30)),
                    Center(
                      child: AppText.custom(
                        'No suppliers found',
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                          fontSize: responsive.fontSize(16),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: responsive.wp(1),
                    right: responsive.wp(1),
                    top: responsive.hp(2),
                    bottom: responsive.hp(20), // Add bottom padding for better scrolling
                  ),
                  itemCount: _ledgerController.suppliers.length,
                  itemBuilder: (context, index) {
                    final supplier = _ledgerController.suppliers[index];

                    // Format creation date and time
                    String subtitle = '';
                    if (supplier.createdAt != null) {
                      // Convert UTC to local time
                      final localTime = supplier.createdAt!.toLocal();
                      final timeFormat = DateFormat('hh:mm a');
                      final dateFormat = DateFormat('d MMM yyyy');
                      final formattedTime = timeFormat.format(localTime);
                      final formattedDate = dateFormat.format(localTime);
                      subtitle = '$formattedTime, $formattedDate';
                    } else {
                      subtitle = 'No date available';
                    }

                    // Format amount
                    final amount = '₹${supplier.openingBalance.abs().toStringAsFixed(2)}';
                    // For suppliers:
                    // OUT = You gave them money, they owe you = Blue (Receivable)
                    // IN = They gave you goods, you owe them = Red (Payable)
                    final isPositive = supplier.transactionType == 'OUT';

                    return ListItemWidget(
                      title: supplier.name.isNotEmpty ? supplier.name : 'Supplier #${index + 1}',
                      subtitle: subtitle,
                      amount: amount,
                      isPositiveAmount: isPositive,
                      showAvatar: true,
                      avatarText: supplier.name.isNotEmpty
                          ? supplier.name.substring(0, supplier.name.length >= 2 ? 2 : 1).toUpperCase()
                          : 'S',
                      avatarBackgroundGradient: isDark
                          ? LinearGradient(
                        colors: [AppColors.splaceSecondary2, AppColors.splaceSecondary1],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                          : LinearGradient(
                        colors: [AppColorsLight.splaceSecondary1, AppColorsLight.gradientColor2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      avatarTextColor: AppColors.white,
                      onTap: () {
                        debugPrint('Supplier tapped: ${supplier.name}');
                        Get.toNamed('/ledger-detail', arguments: {
                          'ledgerId': supplier.id,
                        });
                      },
                    );
                  },
                ),
        );
      }),
    );
  }

  Widget _buildEmployersTab(AdvancedResponsiveHelper responsive, bool isDark) {
    return Container(
      color: isDark ? AppColors.containerLight : AppColorsLight.background,
      child: Obx(() {
        if (_ledgerController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
              strokeWidth: 1.0,

            ),
          );
        }

        return RefreshIndicator(
          color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
          backgroundColor: isDark ? AppColors.containerDark : AppColorsLight.white,
          onRefresh: () async {
            await _ledgerController.refreshAll();
          },
          child: _ledgerController.employers.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: responsive.hp(30)),
                    Center(
                      child: AppText.custom(
                        'No employers found',
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                          fontSize: responsive.fontSize(16),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: responsive.wp(1),
                    right: responsive.wp(1),
                    top: responsive.hp(2),
                    bottom: responsive.hp(30), // Add bottom padding for better scrolling
                  ),
                  itemCount: _ledgerController.employers.length,
                  itemBuilder: (context, index) {
                    final employer = _ledgerController.employers[index];

                    // Format creation date and time
                    String subtitle = '';
                    if (employer.createdAt != null) {
                      // Convert UTC to local time
                      final localTime = employer.createdAt!.toLocal();
                      final timeFormat = DateFormat('hh:mm a');
                      final dateFormat = DateFormat('d MMM yyyy');
                      final formattedTime = timeFormat.format(localTime);
                      final formattedDate = dateFormat.format(localTime);
                      subtitle = '$formattedTime, $formattedDate';
                    } else {
                      subtitle = 'No date available';
                    }

                    // Format amount
                    final amount = '₹${employer.openingBalance.abs().toStringAsFixed(2)}';
                    // For employers:
                    // OUT = You gave them salary/advance, they owe you work = Blue (Receivable)
                    // IN = They worked, you owe them salary = Red (Payable)
                    final isPositive = employer.transactionType == 'OUT';

                    return ListItemWidget(
                      title: employer.name.isNotEmpty ? employer.name : 'Employer #${index + 1}',
                      subtitle: subtitle,
                      amount: amount,
                      isPositiveAmount: isPositive,
                      showAvatar: true,
                      avatarText: employer.name.isNotEmpty
                          ? employer.name.substring(0, employer.name.length >= 2 ? 2 : 1).toUpperCase()
                          : 'E',
                      avatarBackgroundGradient: isDark
                          ? LinearGradient(
                        colors: [AppColors.splaceSecondary2, AppColors.splaceSecondary1],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                          : LinearGradient(
                        colors: [AppColorsLight.splaceSecondary1, AppColorsLight.gradientColor2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      avatarTextColor: AppColors.white,
                      onTap: () {
                        debugPrint('Employer tapped: ${employer.name}');
                        Get.toNamed('/ledger-detail', arguments: {
                          'ledgerId': employer.id,
                        });
                      },
                    );
                  },
                ),
        );
      }),
    );
  }
}
