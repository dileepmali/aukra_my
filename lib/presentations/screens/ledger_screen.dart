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

    // Get initial tab from navigation arguments
    final args = Get.arguments as Map<String, dynamic>?;
    final initialTab = args?['initialTab'] as int?;
    if (initialTab != null && initialTab >= 0 && initialTab <= 2) {
      _selectedTabIndex = initialTab;
      debugPrint('📍 Opening ledger screen with tab: $initialTab');
    }

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

      // Notify parent about initial tab
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
        onSearchTap: () {
          debugPrint('🔍 Navigating to search screen...');
          Get.toNamed('/search-screen');
        },
        isGridView: _isGridView,
        onViewToggle: _handleViewToggle,
        enableSearchInput: false,
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
              AppText.searchbar2(
                merchantName,
                  color: isDark ? Colors.white : AppColorsLight.textPrimary,
                  fontWeight: FontWeight.w500,
                maxLines: 1,
                minFontSize: 10,
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
    final tabs = ['Customers', 'Suppliers', 'Employees'];

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
                    child: AppText.headlineLarge(
                      tabs[index],
                        color: isSelected
                            ? AppColors.white
                            : (isDark ? AppColors.textSecondary : AppColorsLight.textSecondary),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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

                    // Format last update date, time and address
                    String subtitle = '';
                    final displayDate = customer.updatedAt ?? customer.createdAt;
                    if (displayDate != null) {
                      // Convert UTC to local time
                      final localTime = displayDate.toLocal();
                      final dateFormat = DateFormat('d MMM yyyy');
                      final timeFormat = DateFormat('HH:mm');
                      final formattedDate = dateFormat.format(localTime);
                      final formattedTime = timeFormat.format(localTime);
                      subtitle = '$formattedDate, $formattedTime';
                    } else {
                      subtitle = 'No date available';
                    }

                    // Add address if available
                    debugPrint('📍 ${customer.name} - Address: "${customer.address}", Area: "${customer.area}"');
                    if (customer.address.isNotEmpty) {
                      subtitle += ' • ${customer.address}';
                    } else if (customer.area.isNotEmpty) {
                      subtitle += ' • ${customer.area}';
                    }

                    // Debug: Print balance and transaction type
                    debugPrint('💰 ${customer.name}: CurrentBalance=${customer.currentBalance}, Type=${customer.transactionType}');

                    // Format amount - use currentBalance instead of openingBalance
                    final amount = '₹${customer.currentBalance.abs().toStringAsFixed(2)}';
                    // 🔥 FIX: Color based on balance value, not transactionType
                    // Positive balance = Blue (they owe you)
                    // Negative balance = Red (you owe them)
                    final isPositive = customer.currentBalance >= 0;

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
                      onTap: () async {
                        debugPrint('Customer tapped: ${customer.name}');
                        await Get.toNamed('/ledger-detail', arguments: {
                          'ledgerId': customer.id,
                        });
                        // Refresh data when returning from detail screen
                        _ledgerController.refreshAll();
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

                    // Format last update date, time and address
                    String subtitle = '';
                    final displayDate = supplier.updatedAt ?? supplier.createdAt;
                    if (displayDate != null) {
                      // Convert UTC to local time
                      final localTime = displayDate.toLocal();
                      final dateFormat = DateFormat('d MMM yyyy');
                      final timeFormat = DateFormat('HH:mm');
                      final formattedDate = dateFormat.format(localTime);
                      final formattedTime = timeFormat.format(localTime);
                      subtitle = '$formattedDate, $formattedTime';
                    } else {
                      subtitle = 'No date available';
                    }

                    // Add address if available
                    if (supplier.address.isNotEmpty) {
                      subtitle += ' • ${supplier.address}';
                    } else if (supplier.area.isNotEmpty) {
                      subtitle += ' • ${supplier.area}';
                    }

                    // Format amount - use currentBalance instead of openingBalance
                    final amount = '₹${supplier.currentBalance.abs().toStringAsFixed(2)}';
                    // 🔥 FIX: Color based on balance value, not transactionType
                    // Positive balance = Blue (they owe you)
                    // Negative balance = Red (you owe them)
                    final isPositive = supplier.currentBalance >= 0;

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
                      onTap: () async {
                        debugPrint('Supplier tapped: ${supplier.name}');
                        await Get.toNamed('/ledger-detail', arguments: {
                          'ledgerId': supplier.id,
                        });
                        // Refresh data when returning from detail screen
                        _ledgerController.refreshAll();
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

                    // Format last update date, time and address
                    String subtitle = '';
                    final displayDate = employer.updatedAt ?? employer.createdAt;
                    if (displayDate != null) {
                      // Convert UTC to local time
                      final localTime = displayDate.toLocal();
                      final dateFormat = DateFormat('d MMM yyyy');
                      final timeFormat = DateFormat('HH:mm');
                      final formattedDate = dateFormat.format(localTime);
                      final formattedTime = timeFormat.format(localTime);
                      subtitle = '$formattedDate, $formattedTime';
                    } else {
                      subtitle = 'No date available';
                    }

                    // Add address if available
                    if (employer.address.isNotEmpty) {
                      subtitle += ' • ${employer.address}';
                    } else if (employer.area.isNotEmpty) {
                      subtitle += ' • ${employer.area}';
                    }

                    // Format amount - use currentBalance instead of openingBalance
                    final amount = '₹${employer.currentBalance.abs().toStringAsFixed(2)}';
                    // 🔥 FIX: Color based on balance value, not transactionType
                    // Positive balance = Blue (they owe you)
                    // Negative balance = Red (you owe them)
                    final isPositive = employer.currentBalance >= 0;

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
                      onTap: () async {
                        debugPrint('Employer tapped: ${employer.name}');
                        await Get.toNamed('/ledger-detail', arguments: {
                          'ledgerId': employer.id,
                        });
                        // Refresh data when returning from detail screen
                        _ledgerController.refreshAll();
                      },
                    );
                  },
                ),
        );
      }),
    );
  }
}
