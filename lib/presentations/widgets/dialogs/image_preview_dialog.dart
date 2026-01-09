import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/responsive_layout/padding_navigation.dart';

class ImagePreviewDialog extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const ImagePreviewDialog({
    Key? key,
    required this.imagePaths,
    this.initialIndex = 0,
  }) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    required List<String> imagePaths,
    int initialIndex = 0,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (context) => ImagePreviewDialog(
        imagePaths: imagePaths,
        initialIndex: initialIndex,
      ),
    );
  }

  @override
  State<ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends State<ImagePreviewDialog> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (_currentIndex < widget.imagePaths.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasMultipleImages = widget.imagePaths.length > 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: responsive.wp(4),
        vertical: responsive.hp(10),
      ),
      child: Stack(
        children: [
          // PageView with images
          Center(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.imagePaths.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                      child: Image.file(
                        File(widget.imagePaths[index]),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: responsive.wp(80),
                            height: responsive.hp(50),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.containerLight : AppColorsLight.containerLight,
                              borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                size: responsive.iconSizeLarge,
                                color: isDark ? AppColors.white.withOpacity(0.3) : AppColorsLight.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Previous button (left side)
          if (hasMultipleImages && _currentIndex > 0)
            Positioned(
              left: responsive.wp(2),
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _goToPrevious,
                  child: Container(
                    width: responsive.fontSize(45),
                    height: responsive.fontSize(45),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.containerLight : AppColorsLight.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: responsive.fontSize(20),
                        color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Next button (right side)
          if (hasMultipleImages && _currentIndex < widget.imagePaths.length - 1)
            Positioned(
              right: responsive.wp(2),
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _goToNext,
                  child: Container(
                    width: responsive.fontSize(45),
                    height: responsive.fontSize(45),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.containerLight : AppColorsLight.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: responsive.fontSize(20),
                        color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Image counter (top center)
          if (hasMultipleImages)
            Positioned(
              top: responsive.hp(2),
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.spacing(16),
                    vertical: responsive.spacing(8),
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.containerLight : AppColorsLight.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(responsive.borderRadiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.imagePaths.length}',
                    style: TextStyle(
                      color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                      fontSize: responsive.fontSize(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

          // Close button
          Positioned(
            top: responsive.hp(2),
            right: responsive.wp(2),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: responsive.fontSize(40),
                height: responsive.fontSize(40),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.red800 : AppColorsLight.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.close,
                    size: responsive.fontSize(24),
                    color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
