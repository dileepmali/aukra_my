import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/localizations/l10n/app_localizations.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../custom_single_border_color.dart';

class ImagePickerBottomSheet extends StatelessWidget {
  final Function(List<XFile>)? onImagesSelected;
  final ImagePicker _imagePicker =  ImagePicker();

   ImagePickerBottomSheet({
    Key? key,
    this.onImagesSelected,
  }) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    Function(List<XFile>)? onImagesSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.black : AppColorsLight.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ImagePickerBottomSheet(
        onImagesSelected: onImagesSelected,
      ),
    );
  }

  Future<void> _selectImageFromGallery(BuildContext context) async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty && onImagesSelected != null) {
        onImagesSelected!(images);
      }
    } catch (e) {
      debugPrint('Error picking images from gallery: $e');
    }
  }

  Future<void> _selectImageFromCamera(BuildContext context) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
      if (image != null && onImagesSelected != null) {
        onImagesSelected!([image]);
      }
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final responsive = AdvancedResponsiveHelper(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final bottomSheetHeight = responsive.hp(18) + bottomPadding;

    return Stack(
      children: [
        Container(
          height: bottomSheetHeight,
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF262626) : AppColorsLight.scaffoldBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            bottom: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top spacing
                SizedBox(height: responsive.hp(1.5)),

                // Drag handle
                Center(
                  child: Container(
                    width: responsive.wp(12),
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.white : AppColorsLight.textPrimary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(responsive.borderRadiusMedium),
                    ),
                  ),
                ),

                // Content - Gallery and Camera options
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Gallery Option
                      _buildImagePickerOption(
                        context,
                        responsive,
                        AppIcons.galleryIc,
                        AppLocalizations.of(context)?.gallery ?? 'Gallery',
                        () {
                          Navigator.of(context).pop();
                          _selectImageFromGallery(context);
                        },
                      ),

                      // Camera Option
                      _buildImagePickerOption(
                        context,
                        responsive,
                        AppIcons.cameraIc,
                        AppLocalizations.of(context)?.camera ?? 'Camera',
                        () {
                          Navigator.of(context).pop();
                          _selectImageFromCamera(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Border widget
        Positioned.fill(
          child: CustomSingleBorderWidget(
            position: BorderPosition.top,
            borderWidth: isDark ? 1.0 : 2.0,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePickerOption(
    BuildContext context,
    AdvancedResponsiveHelper responsive,
    String iconPath,
    String label,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: responsive.wp(35),
        padding: EdgeInsets.symmetric(
          vertical: responsive.hp(2),
          horizontal: responsive.wp(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: responsive.iconSizeExtraLarge,
              height: responsive.iconSizeExtraLarge,
              colorFilter: ColorFilter.mode(
                isDark ? AppColors.white : AppColorsLight.textPrimary,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(height: responsive.hp(1)),
            Text(
              label,
              style: TextStyle(
                color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                fontSize: responsive.fontSize(14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
