import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/responsive_layout/padding_navigation.dart';

/// Shimmer loading widget for ListItemWidget
class ListItemShimmer extends StatelessWidget {
  final bool showAvatar;
  final bool showBorder;
  final bool showSubtitle;

  const ListItemShimmer({
    super.key,
    this.showAvatar = false,
    this.showBorder = true,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.wp(4),
            vertical: responsive.hp(1.2),
          ),
          child: Shimmer.fromColors(
              baseColor: isDark
                  ? AppColors.descontainerDark
                  : AppColorsLight.black.withOpacity(0.1),
              highlightColor: isDark
                  ? AppColors.containerDark.withOpacity(0.8)
                  : AppColorsLight.black.withOpacity(0.2),
              child: Row(
              children: [
                // Leading shimmer (avatar or icon)
                if (showAvatar)
                  Padding(
                    padding: EdgeInsets.only(right: responsive.spacing(10)),
                    child: CircleAvatar(
                      backgroundColor: isDark
                          ? AppColors.white.withOpacity(0.15)
                          : AppColorsLight.black.withOpacity(0.1),
                      radius: responsive.iconSizeLarge * 1.0,
                    ),
                  )
                else
                  Container(
                    margin: EdgeInsets.only(right: responsive.spacing(12)),
                    width: responsive.iconSizeLarge1,
                    height: responsive.iconSizeLarge1,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.white.withOpacity(0.15)
                          : AppColorsLight.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                // Title and subtitle shimmer
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 16,
                        width: responsive.wp(40),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.white.withOpacity(0.15)
                              : AppColorsLight.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      if (showSubtitle) ...[
                        SizedBox(height: responsive.spacing(8)),
                        Container(
                          height: 12,
                          width: responsive.wp(60),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.white.withOpacity(0.15)
                                : AppColorsLight.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
      ),
        // Divider line between items
        if (showBorder)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.wp(4.5)),
            child: Divider(
              height: 1,
              thickness: 1,
              color: isDark
                  ? AppColors.driver
                  : AppColorsLight.black.withOpacity(0.3),
            ),
          ),
      ],
    );
  }
}

/// Shimmer loading list - displays multiple shimmer items
class ListItemShimmerList extends StatelessWidget {
  final int itemCount;
  final bool showAvatar;
  final bool showSubtitle;

  const ListItemShimmerList({
    super.key,
    this.itemCount = 10,
    this.showAvatar = false,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return ListItemShimmer(
          showAvatar: showAvatar,
          showBorder: index < itemCount - 1,
          showSubtitle: showSubtitle,
        );
      },
    );
  }
}

/// Shimmer loading widget for GridItemWidget
class GridItemShimmer extends StatelessWidget {
  final bool showIcon;
  final bool showSubtitle;

  const GridItemShimmer({
    super.key,
    this.showIcon = true,
    this.showSubtitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(responsive.spacing(12)),
      child: Shimmer.fromColors(
          baseColor: isDark
              ? AppColors.descontainerDark
              : AppColorsLight.black.withOpacity(0.1),
          highlightColor: isDark
              ? AppColors.containerDark.withOpacity(0.8)
              : AppColorsLight.black.withOpacity(0.2),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon) ...[
              Container(
                width: responsive.iconSizeExtraLarge,
                height: responsive.iconSizeExtraLarge,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.white.withOpacity(0.15)
                      : AppColorsLight.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(height: responsive.spacing(8)),
            ],
            Container(
              height: 14,
              width: responsive.wp(20),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.white.withOpacity(0.15)
                    : AppColorsLight.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            if (showSubtitle) ...[
              SizedBox(height: responsive.spacing(4)),
              Container(
                height: 12,
                width: responsive.wp(15),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.white.withOpacity(0.15)
                      : AppColorsLight.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading grid - displays multiple shimmer items in a grid
class GridItemShimmerGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final bool showIcon;
  final bool showSubtitle;

  const GridItemShimmerGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.showIcon = true,
    this.showSubtitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1,
        crossAxisSpacing: responsive.spacing(8),
        mainAxisSpacing: responsive.spacing(8),
      ),
      itemCount: itemCount,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return GridItemShimmer(
          showIcon: showIcon,
          showSubtitle: showSubtitle,
        );
      },
    );
  }
}
