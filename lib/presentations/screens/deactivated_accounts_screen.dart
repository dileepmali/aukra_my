import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../app/constants/app_icons.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_text.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/responsive_layout/padding_navigation.dart';
import '../widgets/custom_app_bar/custom_app_bar.dart';
import '../widgets/custom_app_bar/model/app_bar_config.dart';
import '../widgets/list_item_widget.dart';
import '../widgets/dialogs/pin_verification_dialog.dart';

class DeactivatedAccountsScreen extends StatefulWidget {
  const DeactivatedAccountsScreen({Key? key}) : super(key: key);

  @override
  State<DeactivatedAccountsScreen> createState() => _DeactivatedAccountsScreenState();
}

class _DeactivatedAccountsScreenState extends State<DeactivatedAccountsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _deactivatedAccounts = [];

  @override
  void initState() {
    super.initState();
    _loadDeactivatedAccounts();
  }

  Future<void> _loadDeactivatedAccounts() async {
    // TODO: Replace with actual API call to fetch deactivated accounts
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      // Dummy data for UI testing
      _deactivatedAccounts = [
        {
          'id': 1,
          'name': 'Rahul Sharma',
          'phone': '9876543210',
          'deactivatedDate': '2024-01-15',
        },
        {
          'id': 2,
          'name': 'Priya Patel',
          'phone': '8765432109',
          'deactivatedDate': '2024-01-12',
        },
        {
          'id': 3,
          'name': 'Amit Kumar',
          'phone': '7654321098',
          'deactivatedDate': '2024-01-10',
        },
        {
          'id': 4,
          'name': 'Sneha Gupta',
          'phone': '6543210987',
          'deactivatedDate': '2024-01-08',
        },
        {
          'id': 5,
          'name': 'Vikram Singh',
          'phone': '9988776655',
          'deactivatedDate': '2024-01-05',
        },
      ];
      _isLoading = false;
    });
  }

  Future<void> _restoreAccount(Map<String, dynamic> account) async {
    debugPrint('🔄 Restoring account: ${account['name']}');
    // TODO: Implement restore account API call
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.overlay : AppColorsLight.scaffoldBackground,
      appBar: CustomResponsiveAppBar(
        config: AppBarConfig(
          type: AppBarType.titleOnly,
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
              SizedBox(width: responsive.wp(3)),
              AppText.searchbar2(
                'Deactivated Accounts',
                color: isDark ? Colors.white : AppColorsLight.textPrimary,
                fontWeight: FontWeight.w500,
                maxLines: 1,
                minFontSize: 12,
                letterSpacing: 1.1,
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
                strokeWidth: 1.0,
              ),
            )
          : RefreshIndicator(
              color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
              backgroundColor: isDark ? AppColors.containerDark : AppColorsLight.white,
              onRefresh: _loadDeactivatedAccounts,
              child: _deactivatedAccounts.isEmpty
                  ? _buildEmptyState(responsive, isDark)
                  : _buildAccountsList(responsive, isDark),
            ),
    );
  }

  Widget _buildEmptyState(AdvancedResponsiveHelper responsive, bool isDark) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: responsive.hp(25)),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AppIcons.boxIc,
                width: responsive.iconSizeExtraLarge * 2,
                height: responsive.iconSizeExtraLarge * 2,
                colorFilter: ColorFilter.mode(
                  isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(height: responsive.hp(3)),
              AppText.searchbar1(
                'No deactivated accounts',
                color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: responsive.hp(1)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.wp(10)),
                child: AppText.headlineLarge1(
                  'Accounts you deactivate will appear here. You can restore them anytime.',
                  color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountsList(AdvancedResponsiveHelper responsive, bool isDark) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _deactivatedAccounts.length,
      itemBuilder: (context, index) {
        final account = _deactivatedAccounts[index];
        final name = account['name'] as String? ?? 'Unknown';
        final phone = account['phone'] as String? ?? '';
        final deactivatedDate = account['deactivatedDate'] as String? ?? '';

        // Get initials
        String getInitials(String name) {
          final parts = name.trim().split(' ');
          if (parts.isEmpty) return '?';
          if (parts.length == 1) {
            return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
          }
          return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
        }

        return ListItemWidget(
          title: name,
          subtitle: phone.isNotEmpty ? '+91-$phone' : 'No phone',
          showAvatar: false,
          customTrailing: GestureDetector(
            onTap: () async {
              final result = await PinVerificationDialog.show(
                context: context,
                title: 'Enter Security Pin to unblock',
                subtitle: 'Enter your 4-digit pin to activate "$name"',
                requireOtp: false,
                showWarning: true,
                warningText: 'Once "$name" activated, you will regain access to all transactions, entries, and related info. These records will also appear in search results again.',
                confirmButtonText: 'Confirm',
                confirmGradientColors: [AppColors.red500, AppColors.red500],
                confirmTextColor: AppColors.white,
              );

              if (result != null && result['pin'] != null) {
                _restoreAccount(account);
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText.headlineLarge(
                      'Active',
                      color: AppColors.green400,
                      fontWeight: FontWeight.w600,
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.green400,
                      size: responsive.iconSizeMedium,
                    ),
                  ],
                ),
                SizedBox(height: responsive.hp(0.3)),
                AppText.headlineMedium(
                  'Block: $deactivatedDate',
                  color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                ),
              ],
            ),
          ),
          showBorder: true,
          onTap: () {
            debugPrint('📋 Deactivated account tapped: $name');
          },
        );
      },
    );
  }
}
