import 'package:aukra_anantkaya_space/presentations/widgets/custom_single_border_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_text.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../buttons/dialog_botton.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../../../controllers/user_profile_controller.dart';
import '../text_filed/custom_text_field.dart';

class EditProfileNameDialog {
  static Future<String?> show({
    required BuildContext context,
    required String currentName,
  }) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _EditProfileNameDialogContent(
        currentName: currentName,
      ),
    );
  }
}

class _EditProfileNameDialogContent extends StatefulWidget {
  final String currentName;

  const _EditProfileNameDialogContent({
    required this.currentName,
  });

  @override
  State<_EditProfileNameDialogContent> createState() =>
      _EditProfileNameDialogContentState();
}

class _EditProfileNameDialogContentState
    extends State<_EditProfileNameDialogContent> {
  late final TextEditingController _nameController;
  final FocusNode _nameFocusNode = FocusNode();
  String? errorMessage;
  bool _isSubmitting = false;

  // Controller for API calls
  late final UserProfileController _profileController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);

    // Initialize or get existing controller
    if (Get.isRegistered<UserProfileController>()) {
      _profileController = Get.find<UserProfileController>();
    } else {
      _profileController = Get.put(UserProfileController());
    }

    // Auto focus on name field
    Future.delayed(Duration(milliseconds: 300), () {
      _nameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    final name = _nameController.text.trim();

    // Validation
    if (name.isEmpty) {
      setState(() {
        errorMessage = 'Name cannot be empty';
      });
      return;
    }

    if (name.length < 2) {
      setState(() {
        errorMessage = 'Name must be at least 2 characters';
      });
      return;
    }

    if (name.length > 50) {
      setState(() {
        errorMessage = 'Name must be less than 50 characters';
      });
      return;
    }

    // If name hasn't changed, just close dialog
    if (name == widget.currentName) {
      Navigator.of(context).pop(null);
      return;
    }

    // Show loading state
    setState(() {
      _isSubmitting = true;
      errorMessage = null;
    });

    debugPrint('');
    debugPrint('🔵 ========== DIALOG: Submitting Profile Name ==========');
    debugPrint('📝 Current name: ${widget.currentName}');
    debugPrint('📝 New name: $name');

    // Call API to update profile name
    final success = await _profileController.updateProfileName(name);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      debugPrint('✅ Profile name updated via API');
      // Return the new name on success
      Navigator.of(context).pop(name);
    } else {
      // Show error from controller
      setState(() {
        errorMessage = _profileController.errorMessage.value.isNotEmpty
            ? _profileController.errorMessage.value
            : 'Failed to update profile name';
      });
      debugPrint('❌ Failed to update profile name');
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: responsive.wp(8)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.containerDark, AppColors.containerLight]
                : [AppColorsLight.background, AppColorsLight.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
          border: Border.all(
            color: isDark ? AppColors.driver : AppColorsLight.shadowLight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and close button
            Padding(
              padding:  EdgeInsets.only(left: responsive.wp(4),top: responsive.hp(1)),
              child: AppText.custom(
                'Profile Name',
                style: TextStyle(
                  color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                  fontSize: responsive.fontSize(20),
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: responsive.hp(0.5)),

            // Subtitle
            Padding(
              padding:  EdgeInsets.only(left: responsive.wp(4)),
              child: AppText.custom(
                'Edit profile name',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textDisabled
                      : AppColorsLight.textSecondary,
                  fontSize: responsive.fontSize(14),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.start,
              ),
            ),

            // Name Input Field
            Padding(
              padding: EdgeInsets.all(responsive.wp(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    hintText: 'Enter your name',
                    fontSize: responsive.fontSize(16),
                    borderRadius: responsive.borderRadiusSmall,
                    maxLines: 1,
                    enabled: !_isSubmitting,
                    onChanged: (value) {
                      // Clear error when user types
                      if (errorMessage != null) {
                        setState(() {
                          errorMessage = null;
                        });
                      }
                    },
                  ),
                  if (errorMessage != null) ...[
                    SizedBox(height: responsive.hp(1)),
                    AppText.custom(
                      errorMessage!,
                      style: TextStyle(
                        color: AppColors.red500,
                        fontSize: responsive.fontSize(12),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Action Buttons
            Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(responsive.wp(4)),
                  child: DialogButtonRow(
                    cancelText: 'Cancel',
                    confirmText: 'Submit',
                    onCancel: () => Navigator.of(context).pop(),
                    onConfirm: _handleConfirm,
                    isLoading: _isSubmitting,
                    buttonHeight: responsive.hp(6),
                    buttonSpacing: responsive.wp(3),
                    cancelGradientColors: isDark
                        ? [AppColors.containerDark, AppColors.containerLight]
                        : [
                            AppColorsLight.gradientColor1,
                            AppColorsLight.gradientColor2
                          ],
                    confirmGradientColors: isDark
                        ? [AppColors.splaceSecondary1, AppColors.splaceSecondary2]
                        : [
                            AppColorsLight.splaceSecondary1,
                            AppColorsLight.splaceSecondary2
                          ],
                    confirmTextColor: isDark ? AppColors.white : AppColorsLight.black,
                    cancelTextColor: isDark ? AppColors.white : AppColorsLight.black,
                    enableSweepGradient: true,
                  ),
                ),
                Positioned.fill(
                  child: CustomSingleBorderWidget(
                    position: BorderPosition.top,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}