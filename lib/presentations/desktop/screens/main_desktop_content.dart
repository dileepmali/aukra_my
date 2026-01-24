import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../app/constants/app_icons.dart';
import '../../../app/constants/app_images.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_text.dart';
import '../../../controllers/account_controller.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../../mobile/screens/account_screen.dart';
import '../../mobile/screens/my_profile_screen.dart';
import 'ledger_desktop_content.dart';

/// Desktop layout for Main Screen
/// Top horizontal navigation: Aukra Logo | Customers | Suppliers | Employees | Account | Report | Settings
/// Content area switches based on selected tab
class MainDesktopContent extends StatefulWidget {
  final int initialTabIndex;
  final ValueChanged<int>? onTabChanged;

  const MainDesktopContent({
    Key? key,
    this.initialTabIndex = 0,
    this.onTabChanged,
  }) : super(key: key);

  @override
  State<MainDesktopContent> createState() => _MainDesktopContentState();
}

class _MainDesktopContentState extends State<MainDesktopContent> {
  late int _selectedIndex;

  // Tab names for desktop navigation
  final List<String> _tabNames = [
    'Customers',
    'Suppliers',
    'Employees',
    'Account',
    'Report',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onTabChanged?.call(index);

    // Auto-refresh Account dashboard when Account tab is selected
    if (index == 3) {
      try {
        final accountController = Get.find<AccountController>();
        accountController.refreshDashboard();
        debugPrint('🔄 Account tab selected - refreshing dashboard...');
      } catch (e) {
        debugPrint('⚠️ Could not refresh account dashboard: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.overlay : AppColorsLight.scaffoldBackground,
      body: Column(
        children: [
          // Top Navigation Bar
          _buildTopNavigationBar(responsive, isDark),
          // Content Area
          Expanded(
            child: _buildContent(responsive, isDark),
          ),
        ],
      ),
    );
  }

  /// Top horizontal navigation bar
  Widget _buildTopNavigationBar(AdvancedResponsiveHelper responsive, bool isDark) {
    return Container(
      height: responsive.hp(7),
      decoration: BoxDecoration(
        color: isDark ? AppColors.black : AppColorsLight.white,
      ),
      padding: EdgeInsets.symmetric(horizontal: responsive.wp(2)),
      child: Row(
        children: [
          // Aukra Logo (Left side)
          _buildLogo(responsive, isDark),

          SizedBox(width: responsive.wp(1)),

          // Navigation Tabs
          Expanded(
            child: Row(
              children: List.generate(_tabNames.length, (index) {
                return _buildNavTab(
                  responsive,
                  isDark,
                  _tabNames[index],
                  index,
                );
              }),
            ),
          ),

          // Right side actions (optional - can add notifications, profile, etc.)
          _buildRightActions(responsive, isDark),
        ],
      ),
    );
  }

  /// Aukra logo widget
  Widget _buildLogo(AdvancedResponsiveHelper responsive, bool isDark) {
    return Image.asset(
      AppImages.appLogoIm,
      height: responsive.hp(5),
      fit: BoxFit.contain,
    );
  }

  /// Individual navigation tab
  Widget _buildNavTab(
    AdvancedResponsiveHelper responsive,
    bool isDark,
    String label,
    int index,
  ) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: responsive.wp(0.3)),
        padding: EdgeInsets.symmetric(
          horizontal: responsive.wp(1.0),
          vertical: responsive.hp(1.3),
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: isDark
                      ? [AppColors.containerDark, AppColors.containerLight]
                      : [AppColorsLight.gradientColor1, AppColorsLight.gradientColor2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: !isSelected ? Colors.transparent : null,
          borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tab icon
            _buildTabIcon(responsive, isDark, index, isSelected),
            SizedBox(width: responsive.wp(0.2)),
            // Tab label
            AppText.bodyMedium(
              label,
              color: isSelected
                  ? (isDark ? AppColors.white : AppColorsLight.black)
                  : (isDark ? AppColors.textSecondary : AppColorsLight.textSecondary),
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              maxLines: 1,
              letterSpacing: 1.0,
              minFontSize: 7,
            ),
          ],
        ),
      ),
    );
  }

  /// Tab icon based on index
  Widget _buildTabIcon(
    AdvancedResponsiveHelper responsive,
    bool isDark,
    int index,
    bool isSelected,
  ) {
    String iconPath;

    switch (index) {
      case 0: // Customers
        iconPath = AppIcons.customerIc;
        break;
      case 1: // Suppliers
        iconPath = AppIcons.supplierIc;
        break;
      case 2: // Employees
        iconPath = AppIcons.employeeIc;
        break;
      case 3: // Account
        iconPath = isSelected ? AppIcons.accountAcIc : AppIcons.accountDecIc;
        break;
      case 4: // Report
        iconPath = AppIcons.documentIc;
        break;
      case 5: // Settings
        iconPath = isSelected ? AppIcons.profileAcIc : AppIcons.profileDesIc;
        break;
      default:
        iconPath = AppIcons.folderIc;
    }

    return SvgPicture.asset(
      iconPath,
      width: responsive.iconSizeSmall,
      height: responsive.iconSizeSmall,
      colorFilter: ColorFilter.mode(
        isSelected
            ? (isDark ? AppColors.white : AppColorsLight.black)
            : (isDark ? AppColors.textSecondary : AppColorsLight.textSecondary),
        BlendMode.srcIn,
      ),
    );
  }

  /// Right side actions (notifications, etc.)
  Widget _buildRightActions(AdvancedResponsiveHelper responsive, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Notification icon
        GestureDetector(
          onTap: () {
            debugPrint('🔔 Notifications tapped');
          },
          child: Container(
            padding: EdgeInsets.all(responsive.wp(0.5)),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.containerLight
                  : AppColorsLight.inputBackground,
              borderRadius: BorderRadius.circular(responsive.borderRadiusSmall / 2),
            ),
            child: SvgPicture.asset(
              AppIcons.notificationIc,
              width: responsive.iconSizeSmall,
              height: responsive.iconSizeSmall,
              colorFilter: ColorFilter.mode(
                isDark ? AppColors.white : AppColorsLight.iconPrimary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build content based on selected tab
  Widget _buildContent(AdvancedResponsiveHelper responsive, bool isDark) {
    switch (_selectedIndex) {
      case 0: // Customers
        return LedgerDesktopContent(selectedTabIndex: 0);
      case 1: // Suppliers
        return LedgerDesktopContent(selectedTabIndex: 1);
      case 2: // Employees
        return LedgerDesktopContent(selectedTabIndex: 2);
      case 3: // Account
        return AccountScreen();
      case 4: // Report
        return _buildReportContent(responsive, isDark);
      case 5: // Settings
        return MyProfileScreen();
      default:
        return SizedBox.shrink();
    }
  }

  /// Report content (placeholder)
  Widget _buildReportContent(AdvancedResponsiveHelper responsive, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AppIcons.documentIc,
            width: responsive.wp(8),
            height: responsive.wp(8),
            colorFilter: ColorFilter.mode(
              isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: responsive.hp(2)),
          AppText.headlineMedium(
            'Reports',
            color: isDark ? AppColors.white : AppColorsLight.textPrimary,
          ),
          SizedBox(height: responsive.hp(1)),
          AppText.bodyLarge(
            'Report feature coming soon',
            color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
          ),
        ],
      ),
    );
  }
}