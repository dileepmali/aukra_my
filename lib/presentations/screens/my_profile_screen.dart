import 'package:aukra_anantkaya_space/app/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../app/localizations/l10n/app_localizations.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_text.dart';
import '../../buttons/app_button.dart';
import '../../core/api/auth_storage.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/responsive_layout/padding_navigation.dart';
import '../../core/utils/formatters.dart';
import '../../controllers/localization_controller.dart';
import '../widgets/custom_app_bar/custom_app_bar.dart';
import '../widgets/custom_app_bar/model/app_bar_config.dart';
import '../widgets/custom_border_widget.dart';
import '../widgets/custom_single_border_color.dart';
import '../widgets/list_item_widget.dart';
import '../widgets/dialogs/logout_confirmation_dialog.dart';
import '../widgets/dialogs/edit_profile_name_dialog.dart';
import '../language/select_language_screen.dart'; // ✅ NEW: Import SelectLanguageScreen
import 'manage_businesses_screen.dart';
import 'policy_terms_screen.dart';
import 'about_us_screen.dart';
import 'security_settings_screen.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  String _merchantName = '';
  String _businessName = ''; // ✅ NEW: Store business name separately
  String _mobileNumber = '';
  int? _merchantId;
  bool _isLoading = true;
  LocalizationController? _localizationController;

  @override
  void initState() {
    super.initState();
    try {
      _localizationController = Get.find<LocalizationController>();
    } catch (e) {
      debugPrint('⚠️ LocalizationController not found: $e');
    }
    _loadMerchantData();

    // ✅ Listen for when screen comes back into view (after navigation)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Auto-refresh when returning from other screens
      debugPrint('👀 Profile screen initialized - ready to receive updates');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Reload data when screen is visible again (e.g., after pop from manage business)
    _loadMerchantData();
  }

  Future<void> _loadMerchantData() async {
    try {
      debugPrint('');
      debugPrint('🔵 ========== PROFILE SCREEN: Loading Merchant Data ==========');

      // ✅ Load all merchant data from storage
      final merchantData = await AuthStorage.getMerchantData();
      final phone = await AuthStorage.getPhoneNumber();
      final merchantId = await AuthStorage.getMerchantId();

      debugPrint('📊 Data from Storage:');
      debugPrint('   merchantData (full): $merchantData');
      debugPrint('   phone: $phone');
      debugPrint('   merchantId: $merchantId');
      debugPrint('');

      setState(() {
        if (merchantData != null) {
          // ✅ Use merchantName (person's name) for profile
          _merchantName = merchantData['merchantName']?.toString() ?? 'Aukra';

          // ✅ Store businessName separately (shop name)
          _businessName = merchantData['businessName']?.toString() ?? '';

          _merchantId = merchantData['merchantId'] as int?;

          debugPrint('✅ Profile Display Values:');
          debugPrint('   Merchant Name (Person): $_merchantName');
          debugPrint('   Business Name (Shop): $_businessName');
          debugPrint('   Merchant ID: $_merchantId');
        } else {
          debugPrint('⚠️ No merchantData in storage - using defaults');
          _merchantName = 'Aukra';
          _businessName = '';
        }

        _mobileNumber = phone ?? '';
        _isLoading = false;
      });

      debugPrint('');
      debugPrint('✅ PROFILE SCREEN: Data Loaded Successfully');
      debugPrint('   CircularAvatar will show: ${_getInitials(_merchantName)}');
      debugPrint('   Name displayed: $_merchantName');
      debugPrint('   Mobile: $_mobileNumber');
      debugPrint('   Business: $_businessName');
      debugPrint('========================================================');
      debugPrint('');
    } catch (e) {
      debugPrint('❌ Error loading merchant data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.overlay : AppColorsLight.scaffoldBackground,
      appBar: CustomResponsiveAppBar(
        config: AppBarConfig(
          type: AppBarType.titleOnly,
          titleColor: isDark ? Colors.white : AppColorsLight.textPrimary,
          showBorder: true,
          customHeight: responsive.hp(12),
          customPadding: EdgeInsets.symmetric(horizontal: responsive.wp(2)),
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
                  return AppText.custom(
                    'My Profile',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColorsLight.textPrimary,
                      fontSize: responsive.fontSize(20),
                      fontWeight: FontWeight.w600,
                    ),
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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
              ),
            )
          : RefreshIndicator(
              color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
              backgroundColor: isDark ? AppColors.containerDark : AppColorsLight.white,
              onRefresh: _loadMerchantData,
              child: Column(
                children: [
                  _buildHeaderCard(responsive, isDark),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          _buildProfileOptions(responsive, isDark),
                          SizedBox(height: responsive.hp(2)),
                          _buildLogoutButton(responsive, isDark),
                          SizedBox(height: responsive.hp(20)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard(
    AdvancedResponsiveHelper responsive,
    bool isDark,
  ) {
    final merchantInitials = _getInitials(_merchantName);

    return Stack(
      children: [
        Positioned.fill(
          child: CustomSingleBorderWidget(position: BorderPosition.bottom),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(responsive.wp(4)),
          decoration: BoxDecoration(
            color: isDark ? AppColors.overlay : AppColorsLight.white,
            borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
          ),
          child: Row(
            children: [
              // Left side - Circular Avatar
              CircleAvatar(
                radius: responsive.wp(8),
                backgroundColor: isDark
                ? AppColors.containerDark
                    : AppColorsLight.splaceSecondary1,
                child: AppText.custom(
                  merchantInitials,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: responsive.fontSize(20),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: responsive.wp(3)),

              // Middle - Name and Mobile
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText.custom(
                      _merchantName.isEmpty ? 'Aukra' : _merchantName,
                      style: TextStyle(
                        color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                        fontSize: responsive.fontSize(18),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: responsive.hp(0.2)),
                    AppText.custom(
                      _mobileNumber.isEmpty ? 'No number' : Formatters.formatPhoneWithCountryCode(_mobileNumber),
                      style: TextStyle(
                        color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                        fontSize: responsive.fontSize(14),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Right side - Edit Icon
              GestureDetector(
                onTap: () async {
                  debugPrint('✏️ Edit profile tapped');
                  // Show edit profile name dialog
                  final newName = await EditProfileNameDialog.show(
                    context: context,
                    currentName: _merchantName,
                  );

                  if (newName != null && newName.isNotEmpty) {
                    debugPrint('✅ New name entered: $newName');
                    setState(() {
                      _merchantName = newName;
                    });
                    // TODO: Save to backend/storage
                    // await AuthStorage.updateMerchantName(newName);
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(responsive.wp(2)),
                  decoration: BoxDecoration(
                    border: Border.all(color: isDark ? AppColors.border1 : AppColorsLight.textDisabled),
                    color: isDark
                        ? AppColors.containerDark
                        : AppColorsLight.scaffoldBackground,
                    borderRadius: BorderRadius.circular(responsive.borderRadiusExtraLarge1),
                  ),
                  child: SvgPicture.asset(
                    AppIcons.editIc,
                    color: isDark ? AppColors.white : AppColorsLight.iconPrimary,
                    width: responsive.iconSizeMedium,
                    height: responsive.iconSizeMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOptions(AdvancedResponsiveHelper responsive, bool isDark) {
    final profileOptions = [
      {
        'icon': AppIcons.mobileIc,
        'title': 'Change your number',
        'subtitle': _mobileNumber.isEmpty ? 'No number' : Formatters.formatPhoneWithCountryCode(_mobileNumber),
        'onTap': () {
          debugPrint('🔄 Navigating to change number screen...');
          Get.toNamed('/change-number');
        },
      },
      {
        'icon': AppIcons.shopIc,
        'title': 'Manage businesses',
        'subtitle': _businessName.isNotEmpty ? _businessName : 'No business name', // ✅ Show businessName instead of merchantName
        'onTap': () {
          debugPrint('🏢 Navigating to manage businesses screen...');
          Get.to(() => const ManageBusinessesScreen());
        },
      },
      {
        'icon': AppIcons.lockIc,
        'title': 'Security',
        'subtitle': 'Set pin,biometric,activities & more',
        'onTap': () {
          debugPrint('🔒 Navigating to security settings screen...');
          Get.to(() => const SecuritySettingsScreen());
        },
      },
      {
        'icon': AppIcons.translateIc,
        'title': 'Language',
        'subtitle': _localizationController?.currentLanguageDisplayName ?? 'English',
        'onTap': () {
          debugPrint('🌐 Navigating to language selection screen from profile...');
          // ✅ Navigate to SelectLanguageScreen with fromProfile = true
          Get.to(() => const SelectLanguageScreen(fromProfile: true));
        },
      },
      {
        'icon': AppIcons.mobileIc,
        'title': 'Recovery mobile',
        'subtitle': 'Not added',
        'onTap': () => debugPrint('Help & Support tapped'),
      },

      {
        'icon': AppIcons.messageIc,
        'title': 'Help center',
        'subtitle': 'Need help or want to read docs?',
        'onTap': () {
          debugPrint('📚 Navigating to Help Center (Policy & Terms)...');
          Get.to(() => const PolicyTermsScreen());
        },
      },
      {
        'icon': AppIcons.bookIc,
        'title': 'Legal documents',
        'subtitle': 'Terms of service & policies',
        'onTap': () => debugPrint('About tapped'),
      },
      {
        'icon': AppIcons.informationIc,
        'title': 'About us',
        'subtitle': 'Read more about Aukra & parent company',
        'onTap': () {
          debugPrint('ℹ️ Navigating to About Us screen...');
          Get.to(() => const AboutUsScreen());
        },
      },
    ];

    return Padding(
      padding: EdgeInsets.all(responsive.wp(3)),
      child: Column(
        children: List.generate(profileOptions.length, (index) {
          final option = profileOptions[index];
          return Column(
            children: [
              ListItemWidget(
                backgroundColor: isDark ? AppColors.containerLight : AppColorsLight.containerLight,
                title: option['title'] as String,
                subtitle: option['subtitle'] as String,
                leadingIcon: option['icon'] as String,
                trailingIcon: AppIcons.arrowRightIc,
                onTap: option['onTap'] as VoidCallback,
                showBorder: false,
              ),
              if (index < profileOptions.length - 1)
                SizedBox(height: responsive.hp(0.8)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLogoutButton(AdvancedResponsiveHelper responsive, bool isDark) {
    return Padding(
      padding: EdgeInsets.all(responsive.wp(4)),
      child: AppButton(
        text: 'Logout',
        width: double.infinity,
        height: responsive.hp(7),
        gradientColors:
        isDark
            ?
        [
          AppColors.containerDark,
          AppColors.containerLight,
        ]
            :
        [
          AppColors.containerLight,
          AppColors.containerDark,
        ],

        textColor: AppColors.white,
        fontSize: responsive.fontSize(16),
        fontWeight: FontWeight.w600,
        borderColor: isDark ? AppColors.driver : AppColors.border1,
        borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
        onPressed: () {
          debugPrint('🚪 Logout button pressed - showing custom logout dialog');
          // ✅ Show custom logout confirmation dialog
          showLogoutConfirmationDialog(context);
        },
      ),
    );
  }

  // Helper method to get initials from name
  String _getInitials(String name) {
    if (name.isEmpty) return 'A';

    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }

    return (parts[0].substring(0, 1) + parts[parts.length - 1].substring(0, 1))
        .toUpperCase();
  }
}
