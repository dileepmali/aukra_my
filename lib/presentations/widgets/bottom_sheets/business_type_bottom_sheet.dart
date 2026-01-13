import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_text.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../buttons/row_app_bar.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../custom_single_border_color.dart';
import '../list_item_widget.dart';
import '../text_filed/custom_text_field.dart';

class BusinessTypeBottomSheet extends StatefulWidget {
  final String? selectedType;

  const BusinessTypeBottomSheet({
    Key? key,
    this.selectedType,
  }) : super(key: key);

  static Future<String?> show({
    required BuildContext context,
    String? selectedType,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: isDark ? Colors.black : AppColorsLight.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => BusinessTypeBottomSheet(
        selectedType: selectedType,
      ),
    );
  }

  @override
  State<BusinessTypeBottomSheet> createState() => _BusinessTypeBottomSheetState();
}

class _BusinessTypeBottomSheetState extends State<BusinessTypeBottomSheet> {
  late String? _tempSelectedType;
  final TextEditingController _customTypeController = TextEditingController();
  final FocusNode _customTypeFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tempSelectedType = widget.selectedType;

    // Listen to focus changes to scroll when TextField is focused
    _customTypeFocusNode.addListener(() {
      if (_customTypeFocusNode.hasFocus) {
        // Scroll to bottom when TextField is focused (wait for keyboard to open)
        Future.delayed(const Duration(milliseconds: 600), () {
          if (_scrollController.hasClients && mounted) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _customTypeController.dispose();
    _customTypeFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final responsive = AdvancedResponsiveHelper(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    final businessTypes = [
      {'label': 'Retial Shop', 'subtitle': 'Sells a variety og goods to the public'},
      {'label': 'Whole-seller or Distributor', 'subtitle': 'Distributes clothing items to retailers.'},
      {'label': 'Personal use', 'subtitle': 'Purchases good or services for personal use.'},
      {'label': 'Other type', 'subtitle': 'Did not fount your business type? just write down below'},
    ];

    final bottomSheetHeight = responsive.hp(70) + bottomPadding;

    return Stack(
      children: [
        Container(
          height: bottomSheetHeight,
          decoration: BoxDecoration(
            color: isDark ? AppColors.containerLight : AppColorsLight.scaffoldBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            bottom: true,
            child: Padding(
              padding: EdgeInsets.only(bottom: keyboardHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Top spacing and drag handle
                SizedBox(height: responsive.hp(1.5)),
                Center(
                  child: Container(
                    width: responsive.wp(20),
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.containerDark : AppColorsLight.textPrimary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(responsive.borderRadiusMedium),
                    ),
                  ),
                ),

                SizedBox(height: responsive.hp(2)),

                // Title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: responsive.wp(5)),
                  child: AppText.searchbar2(
                    'Select Business Type',
                    color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: responsive.hp(2)),

                // Divider line
                Divider(
                  color: isDark ? Colors.white.withOpacity(0.1) : AppColorsLight.textPrimary.withOpacity(0.2),
                  thickness: 0.9,
                  height: 1,
                ),

                // Business type options using ListItemWidget
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: responsive.wp(1)),
                    itemCount: businessTypes.length + 1, // +1 for CustomTextField
                    itemBuilder: (context, index) {
                      // Show CustomTextField as last item
                      if (index == businessTypes.length) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: responsive.hp(1),
                            top: responsive.hp(1),
                            left: responsive.wp(4),
                            right: responsive.wp(4),
                          ),
                          child: CustomTextField(
                            controller: _customTypeController,
                            focusNode: _customTypeFocusNode,
                            hintText: 'Type your business...',
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                setState(() {
                                  _tempSelectedType = value;
                                });
                              }
                            },
                            borderRadius: responsive.borderRadiusSmall,
                          ),
                        );
                      }

                      // Show predefined business types
                      final type = businessTypes[index];
                      final label = type['label'] as String;
                      final subtitle = type['subtitle'] as String;
                      final isSelected = label == _tempSelectedType;

                      return ListItemWidget(
                        title: label,
                        subtitle: isSelected ? 'Selected' : subtitle,
                        showBorder: true,
                        onTap: () {
                          setState(() {
                            _tempSelectedType = label;
                            _customTypeController.clear(); // Clear custom input when selecting predefined type
                          });
                          debugPrint('Selected: $label');
                        },
                        itemPadding: EdgeInsets.symmetric(
                          horizontal: responsive.wp(4),
                          vertical: responsive.hp(1.5),
                        ),
                        itemMargin: EdgeInsets.only(bottom: responsive.hp(1)),
                        titleColor: isSelected
                            ? (isDark ? AppColors.splaceSecondary1 : AppColorsLight.splaceSecondary1)
                            : null,
                        subtitleColor: isSelected
                            ? (isDark ? AppColors.splaceSecondary1 : AppColorsLight.splaceSecondary1)
                            : null,
                      );
                    },
                  ),
                ),

                // Bottom action bar with Go back and Apply buttons
                BottomActionBar(
                  primaryButtonText: 'Go back',
                  onPrimaryPressed: () {
                    Navigator.of(context).pop(null);
                  },
                  secondaryButtonText: 'Apply',
                  onSecondaryPressed: () {
                    Navigator.of(context).pop(_tempSelectedType);
                  },
                  showBorder: true,
                  containerPadding: EdgeInsets.symmetric(
                    horizontal: responsive.wp(5),
                    vertical: responsive.hp(1.5),
                  ),
                ),
              ],
            ),
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
}
