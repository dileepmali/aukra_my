import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_text.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/responsive_layout/padding_navigation.dart';
import '../widgets/custom_app_bar/custom_app_bar.dart';
import '../widgets/custom_app_bar/model/app_bar_config.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String? _currentFilter;
  String? _currentSortBy;
  String? _currentSortOrder;

  // Sample search results
  final RxList<Map<String, String>> _searchResults = <Map<String, String>>[].obs;
  final RxBool _isSearching = false.obs;

  @override
  void initState() {
    super.initState();
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
    debugPrint('🔍 Search query: $query');

    if (query.isEmpty) {
      _searchResults.clear();
      _isSearching.value = false;
      return;
    }

    _isSearching.value = true;

    // TODO: Implement actual search logic here
    // For now, showing sample results
    _searchResults.value = [
      {'title': 'Sample Result 1', 'subtitle': 'Description 1'},
      {'title': 'Sample Result 2', 'subtitle': 'Description 2'},
    ];
  }

  void _handleFiltersApplied(Map<String, dynamic> filters) {
    setState(() {
      _currentFilter = filters['filter'];
      _currentSortBy = filters['sortBy'];
      _currentSortOrder = filters['sortOrder'];
    });
    debugPrint('Filters applied: $filters');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final responsive = AdvancedResponsiveHelper(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.overlay : AppColorsLight.scaffoldBackground,
      appBar: CustomResponsiveAppBar(
        config: AppBarConfig(
          type: AppBarType.searchWithFilter,
          searchController: _searchController,
          searchFocusNode: _searchFocusNode,
          searchHint: 'Search anything...',
          enableSearchInput: true,
          forceEnableSearch: true,
          showViewToggle: false,
          onSearchChanged: _handleSearchChanged,
          onFiltersApplied: _handleFiltersApplied,
          currentFilter: _currentFilter,
          currentSortBy: _currentSortBy,
          currentSortOrder: _currentSortOrder,
          customHeight: responsive.hp(19),
          customPadding: EdgeInsets.symmetric(horizontal: responsive.wp(3)),
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
              SizedBox(width: responsive.wp(3)),
              AppText.searchbar2(
                'Search',
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.overlay, AppColors.overlay]
                : [AppColorsLight.scaffoldBackground, AppColorsLight.container],
          ),
        ),
        child: Obx(() {
          // Show empty state when not searching
          if (!_isSearching.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: responsive.iconSizeLarge * 3,
                    color: isDark
                        ? AppColors.white.withOpacity(0.3)
                        : AppColorsLight.textSecondary,
                  ),
                  SizedBox(height: responsive.spacing(16)),
                  AppText.headlineMedium(
                    'Start Searching',
                    color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                  ),
                  SizedBox(height: responsive.spacing(8)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: responsive.spacing(32)),
                    child: AppText.bodyMedium(
                      'Type in the search bar above to find what you\'re looking for',
                      color: isDark
                          ? AppColors.white.withOpacity(0.7)
                          : AppColorsLight.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          // Show search results
          if (_searchResults.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: responsive.iconSizeLarge * 3,
                    color: isDark
                        ? AppColors.white.withOpacity(0.3)
                        : AppColorsLight.textSecondary,
                  ),
                  SizedBox(height: responsive.spacing(16)),
                  AppText.headlineMedium(
                    'No Results Found',
                    color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                  ),
                  SizedBox(height: responsive.spacing(8)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: responsive.spacing(32)),
                    child: AppText.bodyMedium(
                      'Try searching with different keywords',
                      color: isDark
                          ? AppColors.white.withOpacity(0.7)
                          : AppColorsLight.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          // Display search results
          return ListView.builder(
            padding: EdgeInsets.all(responsive.spacing(16)),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final result = _searchResults[index];
              return Card(
                color: isDark ? AppColors.containerDark : AppColorsLight.white,
                margin: EdgeInsets.only(bottom: responsive.spacing(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isDark
                        ? AppColors.splaceSecondary1
                        : AppColorsLight.splaceSecondary1,
                    child: Icon(
                      Icons.article,
                      color: AppColors.white,
                    ),
                  ),
                  title: AppText.bodyLarge(
                    result['title'] ?? '',
                    color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                  ),
                  subtitle: AppText.bodySmall(
                    result['subtitle'] ?? '',
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColorsLight.textSecondary,
                  ),
                  onTap: () {
                    debugPrint('Result tapped: ${result['title']}');
                  },
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
