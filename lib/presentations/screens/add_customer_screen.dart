import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_text.dart';
import '../../app/themes/app_fonts.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/responsive_layout/padding_navigation.dart';
import '../../models/contact_model.dart';
import '../widgets/custom_app_bar/custom_app_bar.dart';
import '../widgets/custom_app_bar/model/app_bar_config.dart';
import '../../controllers/contact_controller.dart';
import '../widgets/list_item_widget.dart';
import '../../app/constants/app_icons.dart';
import 'package:azlistview/azlistview.dart';
import '../routes/app_routes.dart';
import '../../core/utils/formatters.dart';
import '../widgets/add_customer_empty_state.dart';

class AddCustomerScreen extends StatefulWidget {
  final String? partyType; // 'customer', 'supplier', 'employer'

  const AddCustomerScreen({Key? key, this.partyType}) : super(key: key);

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Use ContactController to fetch contacts
  late final ContactController _contactController;

  // Get party type display name
  String get _partyTypeTitle {
    debugPrint('🏷️ _partyTypeTitle getter called');
    debugPrint('   widget.partyType = ${widget.partyType}');
    debugPrint('   widget.partyType?.toLowerCase() = ${widget.partyType?.toLowerCase()}');

    switch (widget.partyType?.toLowerCase()) {
      case 'supplier':
        debugPrint('   ✅ Returning: Add Supplier');
        return 'Add Supplier';
      case 'employer':
      case 'employee':
        debugPrint('   ✅ Returning: Add Employer');
        return 'Add Employer';
      case 'customer':
        debugPrint('   ✅ Returning: Add Customer (matched customer)');
        return 'Add Customer';
      default:
        debugPrint('   ⚠️ Returning: Add Customer (default fallback)');
        return 'Add Customer';
    }
  }

  String get _searchHint {
    switch (widget.partyType?.toLowerCase()) {
      case 'supplier':
        return 'Search suppliers...';
      case 'employer':
      case 'employee':
        return 'Search employers...';
      case 'customer':
      default:
        return 'Search customers...';
    }
  }

  // Static alphabet list for A-Z index
  static const List<String> _staticAlphabetIndex = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '#'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize ContactController
    _contactController = Get.put(ContactController());

    // Debug: Print received partyType
    debugPrint('📋 AddCustomerScreen initialized with partyType: ${widget.partyType}');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleSearchChanged(String value) {
    // Update ContactController's search
    _contactController.searchController.text = value;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final responsive = AdvancedResponsiveHelper(context);

    debugPrint('🏗️ AddCustomerScreen.build() called');
    debugPrint('   Current partyType: ${widget.partyType}');
    debugPrint('   Title will be: $_partyTypeTitle');

    // Detect keyboard visibility
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.overlay : AppColorsLight.scaffoldBackground,
      appBar: CustomResponsiveAppBar(
        config: AppBarConfig(
          customHeight: responsive.hp(19),
          customPadding: EdgeInsets.symmetric(horizontal: responsive.wp(3)),
          type: AppBarType.searchOnly,
          searchController: _searchController,
          searchFocusNode: _searchFocusNode,
          searchHint: _searchHint,
          enableSearchInput: true,
          forceEnableSearch: true,
          onSearchChanged: _handleSearchChanged,
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
              SizedBox(width: responsive.wp(3),),
              Builder(
                builder: (context) {
                  final title = _partyTypeTitle;
                  debugPrint('📱 AppBar rendering with title: $title');
                  return AppText.searchbar2(
                    title,
                    color: isDark ? Colors.white : AppColorsLight.textPrimary,
                    fontWeight: FontWeight.w500,
                    maxLines: 1,
                    minFontSize: 12,
                    letterSpacing: 1.1,
                  );
                },
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
          // Check if permission is denied
          if (_contactController.isPermissionDenied.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.contacts_outlined,
                    size: responsive.iconSizeLarge * 3,
                    color: isDark
                        ? AppColors.white.withOpacity(0.3)
                        : AppColorsLight.textSecondary,
                  ),
                  SizedBox(height: responsive.spacing(16)),
                  AppText.headlineMedium(
                    'Contact Permission Required',
                    color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                  ),
                  SizedBox(height: responsive.spacing(8)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: responsive.spacing(32)),
                    child: AppText.bodyMedium(
                      'Please grant contact permission to load customers from your contacts',
                      color: isDark
                          ? AppColors.white.withOpacity(0.7)
                          : AppColorsLight.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: responsive.spacing(24)),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _contactController.loadContacts();
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Request Permission'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.splaceSecondary1,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.spacing(24),
                        vertical: responsive.spacing(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Show loading indicator
          if (_contactController.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
                strokeWidth: 1.0,
              ),
            );
          }

          // Show contacts list
          final contacts = _contactController.filteredContacts;

          if (contacts.isEmpty) {
            // Check if user is searching
            final searchText = _searchController.text.trim();

            if (searchText.isNotEmpty) {
              // Show add customer empty state when searching
              return AddCustomerEmptyState(searchQuery: searchText);
            }

          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contacts header
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.wp(5),
                  vertical: responsive.hp(1.6),
                ),
                child: AppText.searchbar2(
                  'Contacts',
                  color: isDark ? AppColors.textSecondary : AppColorsLight.textPrimary,
                  maxLines: 1,
                  minFontSize: 10,
                  letterSpacing: 0.7,
                ),
              ),

              // Divider below header
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

              // Contacts list with A-Z index and pull-to-refresh
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    // Refresh contacts when user pulls down
                    debugPrint('🔄 Pull-to-refresh triggered');
                    await _contactController.refreshContacts();
                  },
                  color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
                  backgroundColor: isDark ? AppColors.containerDark : AppColorsLight.white,
                  child: AzListView(
                    indexBarItemHeight: responsive.hp(2.2),
                    data: contacts,
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final customer = contacts[index];
                      return ListItemWidget(
                        title: customer.name,
                        subtitle: customer.phone.isNotEmpty ? customer.phone : 'No phone',
                        showAvatar: true,
                        avatarText: customer.initials.isNotEmpty
                            ? customer.initials
                            : (customer.name.isNotEmpty
                                ? customer.name[0].toUpperCase()
                                : '?'),
                        onTap: () {
                          // Navigate to customer form with contact data
                          // Use Formatters utility to extract phone number
                          final phoneNumber = Formatters.extractPhoneNumber(customer.phone);

                          Get.toNamed(
                            AppRoutes.customerForm,
                            arguments: {
                              'contactName': customer.name,
                              'contactPhone': phoneNumber,
                              'partyType': widget.partyType ?? 'customer', // Pass partyType
                            },
                          );
                        },
                      );
                    },
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: EdgeInsets.only(
                      left: responsive.wp(1),
                      top: responsive.hp(1),
                      right: responsive.wp(8),
                      bottom: responsive.hp(10),
                    ),
                    susItemBuilder: (BuildContext context, int index) {
                      final contact = contacts[index];
                      return const SizedBox.shrink(); // Hide section headers
                    },
                    indexBarData: isKeyboardVisible ? [] : _staticAlphabetIndex,
                    indexBarOptions: IndexBarOptions(
                      needRebuild: true,
                      // Text styling for alphabet letters
                      textStyle: TextStyle(
                        fontSize: responsive.fontSize(12),
                        color: isDark ? Colors.white : AppColorsLight.black,
                        fontWeight: FontWeight.w500,
                        height: 1.8,
                      ),
                      // Selected letter styling
                      selectTextStyle: AppFonts.headlineSmall(
                        color: isDark ? AppColors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      selectItemDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? Colors.white : AppColorsLight.black,
                      ),
                      // Hint bubble (large preview when scrolling)
                      indexHintWidth: responsive.wp(20),
                      indexHintHeight: responsive.wp(20),
                      indexHintDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            AppColors.splaceSecondary1,
                            AppColors.splaceSecondary2,
                            AppColors.splaceSecondary1,
                            AppColors.splaceSecondary2,
                            AppColors.splaceSecondary1,
                            AppColors.splaceSecondary2,
                            AppColors.splaceSecondary1,
                          ],
                          startAngle: 0.0,
                          endAngle: 3.14 * 2,
                        ),
                      ),
                      indexHintAlignment: Alignment.centerRight,
                      indexHintChildAlignment: Alignment.center,
                      indexHintOffset: Offset(responsive.wp(-5), 0),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
