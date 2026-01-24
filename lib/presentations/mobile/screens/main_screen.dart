
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../controllers/localization_controller.dart';
import '../../../controllers/user_preference_controller.dart';
import '../../../core/services/fcm_service.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/constants/light_theme/app_icons.dart';
import '../../../app/localizations/l10n/app_localizations.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_text.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../../widgets/custom_single_border_color.dart';
import '../../widgets/dialogs/exit_confirmation_dialog.dart';
import '../../../buttons/custom_floating_button.dart';
import '../../routes/app_routes.dart';
import '../../../controllers/ledger_controller.dart';
import '../../../controllers/account_controller.dart';
import 'ledger_screen.dart';
import 'account_screen.dart';
import 'my_profile_screen.dart';
import '../../desktop/screens/main_desktop_content.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _ledgerTabIndex = 0; // Track Ledger screen's internal tab (0=Customers, 1=Suppliers, 2=Employees)

  // Tab screens
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize screens with callback
    _screens = [
      LedgerScreen(
        onTabChanged: (index) {
          setState(() {
            _ledgerTabIndex = index;
          });
        },
      ),
      AccountScreen(),
      MyProfileScreen(),
    ];

    // ✅ Initialize post-login services (preferences, FCM, language sync)
    _initializePostLoginServices();
  }

  /// Initialize services that require authentication
  /// Called only after successful login when MainScreen is loaded
  Future<void> _initializePostLoginServices() async {
    debugPrint('');
    debugPrint('🚀 ========== POST-LOGIN INITIALIZATION ==========');

    try {
      // ✅ Step 1: Load user preferences from backend
      if (Get.isRegistered<UserPreferenceController>()) {
        final prefController = Get.find<UserPreferenceController>();
        debugPrint('📱 Step 1: Loading user preferences...');
        await prefController.loadPreferences();
      }

      // ✅ Step 2: Sync current language to backend (only if NO preferences exist on server)
      // If preferences already exist, we respect server's language - no auto-sync needed
      if (Get.isRegistered<LocalizationController>() &&
          Get.isRegistered<UserPreferenceController>()) {
        final localizationController = Get.find<LocalizationController>();
        final prefController = Get.find<UserPreferenceController>();

        final currentLang = localizationController.currentLanguageCode;
        debugPrint('📱 Step 2: Checking language preference...');
        debugPrint('   - App language: $currentLang');
        debugPrint('   - Server language: ${prefController.language}');
        debugPrint('   - Has loaded: ${prefController.hasLoaded.value}');

        // Only sync if preferences DON'T exist on server (first time user)
        // If hasLoaded is true, it means server has preferences - don't override
        if (!prefController.hasLoaded.value) {
          debugPrint('📱 First time user - syncing language to server...');
          // Use silent: true to avoid showing errors for background operations
          await prefController.setLanguage(currentLang, silent: true);
        } else {
          debugPrint('📱 Preferences exist on server - skipping auto-sync');
        }
      }

      // ✅ Step 3: Initialize FCM (request permission + register token)
      // This is called AFTER login so notification permission dialog appears after auth
      debugPrint('📱 Step 3: Initializing FCM service (permission + token registration)...');
      await FcmService.init();

      debugPrint('✅ Post-login initialization complete!');
      debugPrint('==================================================');
      debugPrint('');
    } catch (e) {
      debugPrint('❌ Post-login initialization error: $e');
      debugPrint('==================================================');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Auto-refresh Account dashboard when Account tab is selected
    if (index == 1) {
      try {
        final accountController = Get.find<AccountController>();
        accountController.refreshDashboard();
        debugPrint('🔄 Account tab selected - refreshing dashboard...');
      } catch (e) {
        debugPrint('⚠️ Could not refresh account dashboard: $e');
      }
    }
  }

  String _getScreenType() {
    // Only show FAB on Ledger screen (index 0)
    if (_selectedIndex == 0) {
      // Return screen type based on Ledger's internal tab
      switch (_ledgerTabIndex) {
        case 0:
          return 'customers';
        case 1:
          return 'suppliers';
        case 2:
          return 'employees';
        default:
          return 'customers';
      }
    }
    // For other tabs, return generic type
    return 'main';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final responsive = AdvancedResponsiveHelper(context);

    // Check if desktop/widescreen based on screen width
    final isDesktop = responsive.screenWidth > 600;

    // Desktop layout
    if (isDesktop) {
      return MainDesktopContent(
        initialTabIndex: _ledgerTabIndex,
        onTabChanged: (index) {
          setState(() {
            if (index <= 2) {
              _selectedIndex = 0;
              _ledgerTabIndex = index;
            } else if (index == 3) {
              _selectedIndex = 1; // Account
            } else if (index == 5) {
              _selectedIndex = 2; // Settings
            }
          });
        },
      );
    }

    // Mobile layout
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        if (_selectedIndex == 0) {
          // On first tab - show custom exit confirmation dialog
          showExitConfirmationDialog(context);
        } else {
          // On other tabs - go back to first tab
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.overlay, AppColors.containerDark]
                : [AppColorsLight.scaffoldBackground, AppColorsLight.container],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              // Main content
              IndexedStack(
                index: _selectedIndex,
                children: _screens,
              ),

              // Floating action button - Only show on Ledger screen
              if (_selectedIndex == 0)
                Positioned(
                  right: 16,
                  bottom: AdvancedResponsiveHelper(context).hp(11) +
                          MediaQuery.of(context).padding.bottom + 16,
                  child: CustomFloatingActionButton(
                    onPressed: () {
                      // Navigate based on current ledger tab
                      String partyType = 'customer';
                      switch (_ledgerTabIndex) {
                        case 0:
                          partyType = 'customer';
                          break;
                        case 1:
                          partyType = 'supplier';
                          break;
                        case 2:
                          partyType = 'employee';
                          break;
                      }

                      debugPrint('🚀 FAB clicked - Navigating with partyType: $partyType');

                      // Navigate to Add Customer screen with partyType
                      Get.toNamed(
                        AppRoutes.addCustomer,
                        arguments: {'partyType': partyType},
                        preventDuplicates: false,
                      )?.then((_) {
                        // Refresh ledger data when returning from add customer screen
                        debugPrint('🔄 Returned from Add Customer - Refreshing ledger...');
                        try {
                          final ledgerController = Get.find<LedgerController>();
                          ledgerController.refreshAll();
                        } catch (e) {
                          debugPrint('⚠️ Could not refresh ledger: $e');
                        }
                      });
                    },
                    screenType: _getScreenType(),
                  ),
                ),

              // Bottom navigation bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: CustomBottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context);

    // Navigation items configuration
    final navItems = [
      _NavItem(
        label: 'Ledger',
        activeIcon: isDark ? AppIcons.floderActivie : LightAppIcons.folderActivieIc,
        inactiveIcon: isDark ? AppIcons.folderIc : LightAppIcons.folderIc,
      ),
      _NavItem(
        label: 'Account',
        activeIcon: isDark ? AppIcons.accountAcIc : LightAppIcons.shareActiveIc,
        inactiveIcon: isDark ? AppIcons.accountDecIc : LightAppIcons.shareUnActiveIc,
      ),
      _NavItem(
        label: 'Settings',
        activeIcon: isDark ? AppIcons.profileAcIc : LightAppIcons.folderActivieIc,
        inactiveIcon: isDark ? AppIcons.profileDesIc : LightAppIcons.settingIc,
      ),
    ];

    return Stack(
      children: [
        Container(
          height: responsive.hp(11) + bottomPadding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      AppColors.containerDark,
                      AppColors.containerLight,
                    ]
                  : [
                      AppColorsLight.white,
                      AppColorsLight.white,
                    ],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(navItems.length, (index) {
                final item = navItems[index];
                final isSelected = currentIndex == index;

                return Expanded(
                  child: InkWell(
                    onTap: () => onTap(index),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: responsive.spacing(2)),
                          child: SvgPicture.asset(
                            isSelected ? item.activeIcon : item.inactiveIcon,
                            width: responsive.iconSizeLarge,
                            height: responsive.iconSizeLarge,
                          ),
                        ),
                        AppText.navigation(
                          item.label,
                          color: isSelected
                              ? (isDark ? AppColors.white : AppColorsLight.textPrimary)
                              : (isDark ? Colors.grey[400] : AppColorsLight.textPrimary),
                          maxLines: 1,
                          minFontSize: 12,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        Positioned.fill(
          child: CustomSingleBorderWidget(
            position: BorderPosition.top,
            borderWidth: isDark ? 1.0 : 1.0,
          ),
        ),
      ],
    );
  }
}

// Helper class for navigation items
class _NavItem {
  final String label;
  final String activeIcon;
  final String inactiveIcon;

  _NavItem({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
  });
}
