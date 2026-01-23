import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/constants/app_images.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_text.dart';
import '../../../controllers/search_controller.dart' as app;
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../../../core/services/recent_searches_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/search_model.dart';
import '../../widgets/custom_app_bar/custom_app_bar.dart';
import '../../widgets/custom_app_bar/model/app_bar_config.dart';
import '../../widgets/custom_single_border_color.dart';
import '../../widgets/list_item_widget.dart';
import '../../widgets/recent_searches_widget.dart';

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

  // Track last valid search query for saving when user starts new search
  String _lastValidQuery = '';

  // Track last saved query to prevent duplicates
  String _lastSavedQuery = '';

  @override
  void initState() {
    super.initState();
    // Use existing controller if available, otherwise create new one
    if (Get.isRegistered<app.SearchController>()) {
      _controller = Get.find<app.SearchController>();
      // Clear previous search state to show recent searches
      _controller.clearSearch();
      // Disable loading if data is already cached
      if (_controller.allLedgers.isNotEmpty) {
        _controller.isInitialLoading.value = false;
      }
      debugPrint('🔍 SearchScreen: Reusing existing controller, cleared search state');
    } else {
      _controller = Get.put(app.SearchController());
      debugPrint('🔍 SearchScreen: Created new controller');
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
    final trimmedQuery = query.trim();

    // If user cleared field or starting new search (0-1 chars) and we have previous valid query
    // Save the previous query
    if (trimmedQuery.length <= 1 && _lastValidQuery.isNotEmpty) {
      _saveSearch(_lastValidQuery);
      _lastValidQuery = '';
    }

    // Update last valid query if current query is valid (2+ chars)
    if (trimmedQuery.length >= 2) {
      _lastValidQuery = trimmedQuery;
    }

    // Perform search
    _controller.performSearch(query);
  }

  /// Handle search submission (Enter key pressed)
  void _handleSearchSubmitted(String query) {
    // Save search only when user explicitly submits (Enter key)
    if (query.trim().isNotEmpty && query.trim().length >= 2) {
      _saveSearch(query.trim());
      _lastValidQuery = ''; // Clear since it's saved
      _updateRecentSearches();
    }
  }

  /// Save search to recent searches (with duplicate prevention)
  Future<void> _saveSearch(String query) async {
    if (query.isEmpty || query.length < 2) return;
    if (query == _lastSavedQuery) return; // Prevent saving same query again

    _lastSavedQuery = query;
    await RecentSearchesService.saveSearch(query);
    debugPrint('✅ Search saved: "$query"');
  }

  /// Save current search when navigating back (if has valid search)
  Future<void> _saveSearchOnExit() async {
    // Save last valid query if not already saved
    if (_lastValidQuery.isNotEmpty) {
      await _saveSearch(_lastValidQuery);
    }
    // Also save current text if different
    final currentQuery = _searchController.text.trim();
    if (currentQuery.length >= 2) {
      await _saveSearch(currentQuery);
    }
  }

  /// Handle back navigation (both app back button and Android back)
  Future<bool> _handleBackNavigation() async {
    await _saveSearchOnExit();
    FocusScope.of(context).unfocus();
    return true; // Allow back navigation
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackNavigation();
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
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
            onSearchSubmitted: () => _handleSearchSubmitted(_searchController.text),
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
                  onTap: () async {
                    await _handleBackNavigation();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
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
        // Debug: Log current state
        debugPrint('🔍 Body Obx rebuild:');
        debugPrint('   - isInitialLoading: ${_controller.isInitialLoading.value}');
        debugPrint('   - allLedgers: ${_controller.allLedgers.length}');
        debugPrint('   - searchResults: ${_controller.searchResults.length}');
        debugPrint('   - searchQuery: "${_controller.searchQuery.value}"');
        debugPrint('   - hasActiveFilters: ${_controller.hasActiveFilters.value}');

        // Show initial loading ONLY if we don't have any cached data
        // This prevents showing loading on every navigation
        if (_controller.isInitialLoading.value && _controller.allLedgers.isEmpty) {
          debugPrint('   → Showing: LOADING STATE');
          return _buildLoadingState(responsive, isDark);
        }

        // Show error state (only if no cached data available)
        if (_controller.errorMessage.value.isNotEmpty && _controller.allLedgers.isEmpty) {
          debugPrint('   → Showing: ERROR STATE');
          return _buildErrorState(responsive, isDark);
        }

        // Show search results if we have any (from search or filters)
        // This check comes FIRST to show results even when default filter is applied
        if (_controller.searchResults.isNotEmpty) {
          debugPrint('   → Showing: SEARCH RESULTS');
          return _buildSearchResults(responsive, isDark);
        }

        // Show recent searches when not searching AND no filters active AND no results
        if (_controller.searchQuery.value.isEmpty && !_controller.hasActiveFilters.value) {
          debugPrint('   → Showing: RECENT SEARCHES');
          return RecentSearchesWidget(
            key: ValueKey(_recentSearchesKey),
            onSearchTap: _handleRecentSearchTap,
            onUpdate: _updateRecentSearches,
          );
        }

        // Show no results (for search or filters)
        debugPrint('   → Showing: NO RESULTS STATE');
        return _buildNoResultsState(responsive, isDark);
      }),
      ),
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

        // Results list with infinite scrolling
        Expanded(
          child: Obx(() {
            final isLoadingMore = _controller.isLoadingMore.value;
            final results = _controller.searchResults;

            return ListView.builder(
              controller: _controller.scrollController,
              itemCount: results.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Show loading indicator at the end
                if (index == results.length) {
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

                final result = results[index];
                return _buildResultItem(responsive, isDark, result);
              },
            );
          }),
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

    // Save search when user taps on a result (means search was successful)
    _saveSearch(_searchController.text.trim());
    _lastValidQuery = ''; // Clear since it's saved

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
