import 'package:flutter/material.dart';
import '../../../../../core/responsive_layout/device_category.dart';
import '../../../../core/responsive_layout/helper_class_2.dart';
import '../../text_filed/search_bar.dart';

class SearchSection extends StatelessWidget {
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode; // 🔥 NEW: FocusNode for auto-focus
  final String? searchHint;
  final bool? enableSearchInput;
  final Function(String)? onSearchChanged;
  final VoidCallback? onSearchSubmitted;
  final VoidCallback? onSearchTap;
  final bool? forceEnableSearch; // 🔧 NEW: Force enable search for contact_screen

  const SearchSection({
    Key? key,
    this.searchController,
    this.searchFocusNode, // 🔥 NEW: FocusNode parameter
    this.searchHint,
    this.enableSearchInput,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onSearchTap,
    this.forceEnableSearch, // 🔧 NEW: Pass forceEnable parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);

    return CustomSearchBar(
      controller: searchController ?? TextEditingController(),
      focusNode: searchFocusNode, // 🔥 NEW: Pass FocusNode to CustomSearchBar
      height: responsive.hp(6.5),
      hintText: searchHint,
      enableInput: enableSearchInput ?? false,
      forceEnable: forceEnableSearch ?? false, // 🔧 NEW: Pass forceEnable to CustomSearchBar
      onChanged: onSearchChanged,
      onSubmitted: () => onSearchSubmitted?.call(),
      onTap: onSearchTap,
    );
  }
}