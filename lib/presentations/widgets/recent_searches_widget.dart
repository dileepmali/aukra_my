import 'package:flutter/material.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/padding_navigation.dart';
import '../../core/services/recent_searches_service.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_fonts.dart';
import '../../app/themes/app_text.dart';

/// Reusable widget to display recent search history
/// Can be used in any screen with search functionality
class RecentSearchesWidget extends StatelessWidget {
  /// Callback when a recent search item is tapped
  final Function(String query) onSearchTap;

  /// Callback to trigger UI rebuild after clearing/removing searches
  final VoidCallback onUpdate;

  const RecentSearchesWidget({
    Key? key,
    required this.onSearchTap,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = responsive.deviceType == DeviceType.desktop;

    return FutureBuilder<List<String>>(
      future: RecentSearchesService.getRecentSearches(),
      builder: (context, snapshot) {
        final recentSearches = snapshot.data ?? [];

        if (recentSearches.isEmpty) {
          // Show empty state when no recent searches
          return _buildEmptyState(context, responsive, isDark);
        }

        // Show recent searches list
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with "Recent searches" title and "Clear all" button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.spacing(20),
                vertical: responsive.spacing(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Recent searches title
                  isDesktop
                      ? AppText.headlineSmall1(
                          'Recent searches',
                          color: isDark ? AppColors.textWhite70 : AppColorsLight.textSecondary,
                          maxLines: 1,
                          minFontSize: 12,
                        )
                      : AppText.searchbar1(
                          'Recent searches',
                          color: isDark ? AppColors.textWhite70 : AppColorsLight.textSecondary,
                          maxLines: 1,
                          minFontSize: 11,
                        ),
                  // Clear all button
                  GestureDetector(
                    onTap: () async {
                      await RecentSearchesService.clearAllSearches();
                      onUpdate(); // Trigger parent rebuild
                    },
                    child: isDesktop
                        ? AppText.bodyLarge(
                            'Clear all',
                            color: isDark ? AppColors.blue : AppColorsLight.blue,
                            maxLines: 1,
                            minFontSize: 12,
                          )
                        : AppText.headlineLarge(
                            'Clear all',
                            color: isDark ? AppColors.blue : AppColorsLight.blue,
                            maxLines: 1,
                            minFontSize: 11,
                          ),
                  ),
                ],
              ),
            ),
            // Recent searches list with dividers
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: responsive.spacing(5)),
                itemCount: recentSearches.length,
                separatorBuilder: (context, index) => Divider(
                  color: isDark
                      ? AppColors.textWhite54.withOpacity(0.2)
                      : AppColorsLight.textSecondary.withOpacity(0.2),
                  height: 1,
                  thickness: 0.5,
                  indent: responsive.spacing(56), // Indent to align with text (after icon)
                  endIndent: responsive.spacing(16),
                ),
                itemBuilder: (context, index) {
                  final searchQuery = recentSearches[index];

                  return ListTile(
                    leading: Icon(
                      Icons.history,
                      color: isDark ? AppColors.textWhite54 : AppColorsLight.iconSecondary,
                      size: isDesktop ? responsive.iconSizeMedium : null,
                    ),
                    title: isDesktop
                        ? AppText.bodyLarge1(
                            searchQuery,
                            color: isDark ? AppColors.textWhite : AppColorsLight.textPrimary,
                            maxLines: 1,
                            minFontSize: 12,
                          )
                        : Text(
                            searchQuery,
                            style: AppFonts.searchbar1(
                              color: isDark ? AppColors.textWhite : AppColorsLight.textPrimary,
                            ),
                          ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isDark ? AppColors.textWhite54 : AppColorsLight.iconSecondary,
                        size: isDesktop ? responsive.iconSizeMedium : null,
                      ),
                      onPressed: () async {
                        await RecentSearchesService.removeSearch(searchQuery);
                        onUpdate(); // Trigger parent rebuild
                      },
                    ),
                    onTap: () {
                      // Execute the search with selected query
                      onSearchTap(searchQuery);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build empty state when no recent searches
  Widget _buildEmptyState(BuildContext context, AdvancedResponsiveHelper responsive, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: responsive.iconSizeLarge * 3,
            color: isDark
                ? AppColors.white.withOpacity(0.3)
                : AppColorsLight.textSecondary.withOpacity(0.5),
          ),
          SizedBox(height: responsive.hp(2)),
          AppText.headlineMedium(
            'Start Searching',
            color: isDark ? AppColors.white : AppColorsLight.textPrimary,
          ),
          SizedBox(height: responsive.hp(1)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.wp(10)),
            child: AppText.bodyMedium(
              'Search by name, mobile, address, pincode or amount',
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
}
