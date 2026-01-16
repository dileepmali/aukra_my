import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../app/constants/app_icons.dart';
import '../../app/constants/app_images.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_text.dart';
import '../../controllers/search_controller.dart' as app;
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/responsive_layout/padding_navigation.dart';
import '../../core/services/recent_searches_service.dart';
import '../../core/utils/formatters.dart';
import '../../models/search_model.dart';
import '../widgets/custom_app_bar/custom_app_bar.dart';
import '../widgets/custom_app_bar/model/app_bar_config.dart';
import '../widgets/custom_single_border_color.dart';
import '../widgets/list_item_widget.dart';
import '../widgets/recent_searches_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late app.SearchController _controller;

  // Key to rebuild recent searches widget when updated
  int _recentSearchesKey = 0;

  @override
  void initState() {
    super.initState();
    // Use existing controller if available, otherwise create new one
    if (Get.isRegistered<app.SearchController>()) {
      _controller = Get.find<app.SearchController>();
    } else {
      _controller = Get.put(app.SearchController());
    }

    // Auto-focus search field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleSearchChanged(String query) {
    _controller.performSearch(query);

    // Save search to recent searches when query has content
    if (query.trim().isNotEmpty && query.trim().length >= 2) {
      RecentSearchesService.saveSearch(query.trim());
    }
  }

  /// Handle tap on recent search item
  void _handleRecentSearchTap(String query) {
    // Set the search text
    _searchController.text = query;
    // Perform the search
    _controller.performSearch(query);
  }

  /// Rebuild recent searches widget
  void _updateRecentSearches() {
    setState(() {
      _recentSearchesKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final responsive = AdvancedResponsiveHelper(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.overlay : AppColorsLight.scaffoldBackground,
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(responsive.hp(20)),
        child: Obx(() => CustomResponsiveAppBar(
          config: AppBarConfig(
            type: AppBarType.searchWithFilter,
            searchController: _searchController,
            searchFocusNode: _searchFocusNode,
            searchHint: _controller.isInitialLoading.value
                ? 'Loading...'
                : _controller.searchHint,
            enableSearchInput: true,
            forceEnableSearch: true,
            showViewToggle: false,
            onSearchChanged: _handleSearchChanged,
            onFiltersApplied: (filters) => _controller.handleFiltersApplied(filters),
            // 🔥 Pass current filter values to restore previous selections
            currentSortBy: _getSortByString(_controller.sortBy.value),
            currentSortOrder: _controller.sortOrder.value == SearchSortOrder.ascending ? 'asc' : 'desc',
            currentDateFilter: _controller.dateFilter.value,
            currentTransactionFilter: _controller.transactionFilter.value,
            currentReminderFilter: _controller.reminderFilter.value,
            currentUserFilter: _controller.userFilter.value,
            currentCustomDateFrom: _controller.customDateFrom.value,
            currentCustomDateTo: _controller.customDateTo.value,
            customHeight: responsive.hp(19),
            customPadding: EdgeInsets.symmetric(horizontal: responsive.wp(3)),
            leadingWidget: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    // Unfocus keyboard before navigating back
                    FocusScope.of(context).unfocus();
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                    size: responsive.iconSizeLarge,
                  ),
                ),
                SizedBox(width: responsive.wp(3)),
                AppText.searchbar2(
                  _controller.isInitialLoading.value
                      ? 'Search'
                      : _controller.screenTitle,
                  color: isDark ? Colors.white : AppColorsLight.textPrimary,
                  fontWeight: FontWeight.w500,
                  maxLines: 1,
                  minFontSize: 12,
                  letterSpacing: 1.1,
                ),
              ],
            ),
          ),
        )),
      ),
      body: Obx(() {
        // Show initial loading ONLY if we don't have any cached data
        // This prevents showing loading on every navigation
        if (_controller.isInitialLoading.value && _controller.allLedgers.isEmpty) {
          return _buildLoadingState(responsive, isDark);
        }

        // Show error state (only if no cached data available)
        if (_controller.errorMessage.value.isNotEmpty && _controller.allLedgers.isEmpty) {
          return _buildErrorState(responsive, isDark);
        }

        // Show search results if we have any (from search or filters)
        // This check comes FIRST to show results even when default filter is applied
        if (_controller.searchResults.isNotEmpty) {
          return _buildSearchResults(responsive, isDark);
        }

        // Show recent searches when not searching AND no filters active AND no results
        if (_controller.searchQuery.value.isEmpty && !_controller.hasActiveFilters.value) {
          return RecentSearchesWidget(
            key: ValueKey(_recentSearchesKey),
            onSearchTap: _handleRecentSearchTap,
            onUpdate: _updateRecentSearches,
          );
        }

        // Show no results (for search or filters)
        return _buildNoResultsState(responsive, isDark);
      }),
    );
  }

  /// Build loading state
  Widget _buildLoadingState(AdvancedResponsiveHelper responsive, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
            strokeWidth: 1.5,
          ),
          SizedBox(height: responsive.hp(2)),
          AppText.bodyMedium(
            'Loading data...',
            color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
          ),
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(AdvancedResponsiveHelper responsive, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: responsive.iconSizeLarge * 2,
            color: AppColors.red500,
          ),
          SizedBox(height: responsive.hp(2)),
          AppText.bodyMedium(
            _controller.errorMessage.value,
            color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.hp(2)),
          TextButton(
            onPressed: () => _controller.refresh(),
            child: AppText.bodyMedium(
              'Retry',
              color: isDark ? AppColors.splaceSecondary1 : AppColorsLight.splaceSecondary1,
            ),
          ),
        ],
      ),
    );
  }

  /// Build no results state (same style as manager_bottom_sheet.dart)
  Widget _buildNoResultsState(AdvancedResponsiveHelper responsive, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(
        top: responsive.wp(28),
        left: responsive.wp(5),
        right: responsive.wp(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Empty state image
          Image.asset(
            AppImages.foundErrorIm,
            width: responsive.wp(45),
            height: responsive.wp(45),
            fit: BoxFit.contain,
          ),

          // Empty state title
          Padding(
            padding:  EdgeInsets.only(left: responsive.wp(8)),
            child: AppText.displayMedium2(
              'No Results found',
              color: isDark ? AppColors.white : AppColorsLight.textPrimary,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: responsive.hp(0.5)),

          // Empty state description
          Padding(
            padding:  EdgeInsets.only(left: responsive.wp(8)),
            child: AppText.searchbar1(
              'Try adjusting your search or filter to find what you\'re looking for.',
              color: isDark
                  ? AppColors.white.withOpacity(0.6)
                  : AppColorsLight.textSecondary,
              fontWeight: FontWeight.w400,
              textAlign: TextAlign.start,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  /// Build search results list
  Widget _buildSearchResults(AdvancedResponsiveHelper responsive, bool isDark) {
    return Column(
      children: [
        // Results count header - centered
        Stack(
          children: [
            Positioned.fill(child: CustomSingleBorderWidget(position: BorderPosition.bottom)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.wp(4),
                vertical: responsive.hp(1.5),
              ),
              child: Center(
                child: AppText.searchbar1(
                  _controller.searchQuery.value.isNotEmpty
                      ? '${_controller.searchResults.length} search result "${_controller.searchQuery.value}"'
                      : _controller.resultCountText,
                  color: isDark ? AppColors.white.withOpacity(0.6) : AppColorsLight.textSecondary,
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        // Results list
        Expanded(
          child: ListView.builder(
            itemCount: _controller.searchResults.length,
            itemBuilder: (context, index) {
              final result = _controller.searchResults[index];
              return _buildResultItem(responsive, isDark, result);
            },
          ),
        ),
      ],
    );
  }

  /// Build individual result item
  Widget _buildResultItem(
    AdvancedResponsiveHelper responsive,
    bool isDark,
    SearchResultItem result,
  ) {
    final isPositive = result.isPositiveBalance;

    return ListItemWidget(
      title: result.name,
      subtitle: result.subtitle,
      showAvatar: true,
      avatarText: result.initials,
      // Avatar gradient same as LedgerScreen
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
      onTap: () => _handleResultTap(result),
      // Amount display
      amount: Formatters.formatAmountWithCommas(result.balance.toStringAsFixed(0)),
      isPositiveAmount: isPositive,
      // Subtitle suffix for IN/OUT label
    );
  }

  /// Handle result item tap
  void _handleResultTap(SearchResultItem result) {
    debugPrint('Tapped on: ${result.name} (ID: ${result.id})');
    debugPrint('   Party Type: ${result.partyType}');
    debugPrint('   Balance: ${result.balance} ${result.balanceType}');

    // TODO: Navigate to ledger detail screen
    // Get.to(() => LedgerDetailScreen(), arguments: {'ledgerId': result.id});
  }

  /// Convert SearchSortBy enum to string for filter persistence
  String _getSortByString(SearchSortBy sortBy) {
    switch (sortBy) {
      case SearchSortBy.name:
        return 'name';
      case SearchSortBy.balance:
        return 'amount';
      case SearchSortBy.recent:
        return 'transaction_date';
    }
  }
}
