import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_text.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../../widgets/custom_app_bar/custom_app_bar.dart';
import '../../widgets/custom_app_bar/model/app_bar_config.dart';
import '../../../buttons/custom_toggle_button.dart';
import '../../../buttons/app_button.dart';
import '../../widgets/dialogs/pin_verification_dialog.dart';
import '../../widgets/dialogs/new_number_otp_dialog.dart';
import '../../../core/api/auth_storage.dart';
import '../../../core/api/user_profile_api_service.dart';
import '../../../core/api/merchant_list_api.dart';
import '../../../core/services/error_service.dart';
import '../../../core/untils/error_types.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/user_profile_model.dart';
import '../../../core/services/device_info_service.dart';
import '../../widgets/dialogs/logout_confirmation_dialog.dart';
import '../../../controllers/privacy_setting_controller.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _biometricEnabled = false;

  // Privacy Setting Controller - Global controller for security PIN
  late PrivacySettingController _privacyController;

  // Active devices
  final UserProfileApiService _apiService = UserProfileApiService();
  final MerchantListApi _merchantApi = MerchantListApi();
  List<UserProfileModel> _devices = [];
  bool _isLoadingDevices = true;
  String _merchantAddress = ''; // Merchant's business address

  // Loading state for PIN operations
  bool _isPinOperationLoading = false;

  // Track if user toggled ON but hasn't set PIN yet
  bool _pendingPinSetup = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _loadActiveDevices();
  }

  /// Initialize the privacy setting controller
  void _initializeController() {
    // Get the global controller (registered in MainBinding)
    if (Get.isRegistered<PrivacySettingController>()) {
      _privacyController = Get.find<PrivacySettingController>();
    } else {
      // Fallback: Register if not already registered
      _privacyController = Get.put(PrivacySettingController(), permanent: true);
    }
    debugPrint('🔐 SecuritySettingsScreen: Controller initialized');
    debugPrint('   isPinEnabled: ${_privacyController.isPinEnabled}');
  }

  Future<void> _loadActiveDevices() async {
    setState(() => _isLoadingDevices = true);

    // Load devices and merchant address in parallel
    final devices = await _apiService.getActiveDevices();
    await _loadMerchantAddress();

    // Debug: Print current device ID and all device IDs from API
    debugPrint('');
    debugPrint('📱 ========== DEVICE ID COMPARISON ==========');
    debugPrint('🔑 Current Device ID (Local): ${DeviceInfoService.deviceId}');
    debugPrint('📋 Devices from API: ${devices?.length ?? 0}');
    debugPrint('🏢 Merchant Address: $_merchantAddress');
    if (devices != null) {
      for (var i = 0; i < devices.length; i++) {
        final d = devices[i];
        final isMatch = d.deviceId == DeviceInfoService.deviceId;
        debugPrint('   [$i] deviceId: ${d.deviceId} | name: ${d.deviceName} | match: $isMatch');
      }
    }
    debugPrint('=============================================');
    debugPrint('');

    if (mounted) {
      setState(() {
        _devices = devices ?? [];
        _isLoadingDevices = false;
      });
    }
  }

  /// Load merchant address from API
  Future<void> _loadMerchantAddress() async {
    try {
      final merchants = await _merchantApi.getAllMerchants();
      if (merchants.isNotEmpty) {
        // Find main account or use first merchant
        final mainMerchant = merchants.firstWhere(
          (m) => m.isMainAccount,
          orElse: () => merchants.first,
        );
        _merchantAddress = mainMerchant.formattedAddress;
        debugPrint('✅ Merchant address loaded: $_merchantAddress');
      }
    } catch (e) {
      debugPrint('❌ Error loading merchant address: $e');
      _merchantAddress = '';
    }
  }

  // ============================================================
  // PIN ENABLE/DISABLE FLOW
  // ============================================================

  /// Handle PIN toggle - Enable or Disable security PIN
  Future<void> _handlePinToggle(bool enablePin) async {
    if (_isPinOperationLoading) return;

    if (enablePin) {
      // ENABLE PIN: Just show "Set PIN" button, no loading, no dialogs yet
      debugPrint('🔒 Toggle ON: Showing Set PIN button');
      setState(() {
        _pendingPinSetup = true;
      });
    } else {
      // DISABLE PIN: Run the disable flow with loading
      setState(() => _isPinOperationLoading = true);

      try {
        final phone = await AuthStorage.getPhoneNumber();
        final maskedPhone = phone != null ? Formatters.formatMaskedPhone(phone) : null;
        final formattedPhone = phone != null ? Formatters.formatPhoneWithCountryCode(phone) : null;

        await _disablePinFlow(maskedPhone, formattedPhone);
      } catch (e) {
        debugPrint('❌ Error in PIN disable: $e');
        AdvancedErrorService.showError(
          'An error occurred',
          category: ErrorCategory.network,
        );
      } finally {
        if (mounted) {
          setState(() => _isPinOperationLoading = false);
        }
      }
    }
  }

  /// Handle "Set PIN" button click - starts the actual PIN setup flow
  Future<void> _handleSetPinClick() async {
    if (_isPinOperationLoading) return;

    setState(() => _isPinOperationLoading = true);

    try {
      final phone = await AuthStorage.getPhoneNumber();
      final maskedPhone = phone != null ? Formatters.formatMaskedPhone(phone) : null;
      final formattedPhone = phone != null ? Formatters.formatPhoneWithCountryCode(phone) : null;

      await _enablePinFlow(maskedPhone, formattedPhone);

      // Reset pending state after successful setup
      if (mounted && _privacyController.isPinEnabled) {
        setState(() {
          _pendingPinSetup = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error in PIN setup: $e');
      AdvancedErrorService.showError(
        'An error occurred',
        category: ErrorCategory.network,
      );
    } finally {
      if (mounted) {
        setState(() => _isPinOperationLoading = false);
      }
    }
  }

  /// Enable PIN Flow:
  /// 1. Enter new 4-digit PIN
  /// 2. Send OTP to mobile
  /// 3. Enter OTP
  /// 4. Call API to enable PIN
  Future<void> _enablePinFlow(String? maskedPhone, String? formattedPhone) async {
    debugPrint('🔐 Starting ENABLE PIN flow...');

    // Step 1: Show PIN entry dialog
    final pinResult = await PinVerificationDialog.show(
      context: context,
      title: 'Set Security PIN',
      subtitle: 'Enter a 4-digit PIN to secure your account',
      maskedPhoneNumber: maskedPhone,
      requireOtp: false,
      confirmButtonText: 'Send OTP',
    );

    if (pinResult == null || pinResult['pin'] == null) {
      debugPrint('❌ PIN entry cancelled');
      return;
    }

    final pin = pinResult['pin'] as String;
    debugPrint('✅ PIN entered: ****');

    // Step 2: Send OTP to mobile
    final otpSent = await _privacyController.sendOtp();
    if (!otpSent) {
      debugPrint('❌ Failed to send OTP');
      return;
    }

    // Step 3: Show OTP entry dialog
    final otp = await NewNumberOtpDialog.show(
      context: context,
      newPhoneNumber: formattedPhone ?? 'your phone',
      title: 'Verify Mobile Number',
      subtitle: 'Enter OTP sent to\n${formattedPhone ?? "your phone"}',
      confirmButtonText: 'Enable PIN',
      onResendOtp: () async {
        debugPrint('🔄 Resending OTP for Enable PIN...');
        return await _privacyController.sendOtp();
      },
    );

    if (otp == null) {
      debugPrint('❌ OTP verification cancelled');
      return;
    }

    debugPrint('✅ OTP entered: ****');

    // Step 4: Call API to enable PIN
    final success = await _privacyController.enablePin(
      securityKey: pin,
      otp: otp,
    );

    if (success) {
      debugPrint('✅ Security PIN enabled successfully');
      // UI will update automatically via Obx/GetX
      if (mounted) setState(() {});
    }
  }

  /// Disable PIN Flow:
  /// 1. Send OTP to mobile (no PIN verification needed)
  /// 2. Enter OTP
  /// 3. Call API to disable PIN
  Future<void> _disablePinFlow(String? maskedPhone, String? formattedPhone) async {
    debugPrint('🔓 Starting DISABLE PIN flow...');

    // Step 1: Send OTP to mobile directly (no PIN verification needed)
    debugPrint('📡 Step 1: Sending OTP to mobile...');
    final otpSent = await _privacyController.sendOtp();
    if (!otpSent) {
      debugPrint('❌ Failed to send OTP');
      return;
    }

    debugPrint('✅ OTP sent successfully');

    if (!mounted) return;

    // Step 2: Show OTP entry dialog
    debugPrint('📍 Step 2: Showing OTP dialog...');
    final otp = await NewNumberOtpDialog.show(
      context: context,
      newPhoneNumber: formattedPhone ?? 'your phone',
      title: 'Enter OTP',
      subtitle: 'Enter OTP received on your mobile number\n${formattedPhone ?? "your phone"}',
      confirmButtonText: 'Disable PIN',
      onResendOtp: () async {
        debugPrint('🔄 Resending OTP for Disable PIN...');
        return await _privacyController.sendOtp();
      },
    );

    if (otp == null) {
      debugPrint('❌ OTP verification cancelled');
      return;
    }

    debugPrint('✅ OTP entered: ****');

    // Step 3: Call API to disable PIN
    final success = await _privacyController.disablePinWithKey(
      securityKey: '', // No PIN needed for disable
      otp: otp,
    );

    if (success) {
      debugPrint('✅ Security PIN disabled successfully');
      // UI will update automatically via Obx/GetX
      if (mounted) setState(() {});
    }
  }

  /// Change PIN Flow (when PIN is already enabled):
  /// Same as enable flow - just re-sets the PIN
  Future<void> _changePinFlow() async {
    if (_isPinOperationLoading) return;

    setState(() => _isPinOperationLoading = true);

    try {
      final phone = await AuthStorage.getPhoneNumber();
      final maskedPhone = phone != null ? Formatters.formatMaskedPhone(phone) : null;
      final formattedPhone = phone != null ? Formatters.formatPhoneWithCountryCode(phone) : null;

      await _enablePinFlow(maskedPhone, formattedPhone);
    } catch (e) {
      debugPrint('❌ Error in change PIN: $e');
      AdvancedErrorService.showError(
        'An error occurred',
        category: ErrorCategory.network,
      );
    } finally {
      if (mounted) {
        setState(() => _isPinOperationLoading = false);
      }
    }
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
              SizedBox(width: responsive.wp(3)),
              AppText.searchbar2(
                'Security',
                  color: isDark ? Colors.white : AppColorsLight.textPrimary,
                fontWeight: FontWeight.w500,
                maxLines: 1,
                minFontSize: 10,
                letterSpacing: 1.2,
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
        backgroundColor: isDark ? AppColors.containerDark : AppColorsLight.white,
        onRefresh: () async {
          await _loadActiveDevices();
          await _privacyController.loadPrivacySettings();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: responsive.hp(2)),
              _buildSecurityOptions(responsive, isDark),
              SizedBox(height: responsive.hp(10)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityOptions(AdvancedResponsiveHelper responsive, bool isDark) {
    // Use Obx to reactively update when controller state changes
    return Obx(() {
      final isPinEnabled = _privacyController.isPinEnabled;

      final securityOptions = [
        {
          'icon': AppIcons.lockIc,
          'title': 'Security PIN',
          'subtitle': 'You can change the security pin to do any transaction, add or remove entries & other critical actions',
          'value': isPinEnabled || _pendingPinSetup, // Show as ON if pending setup
          // TODO: Toggle disabled temporarily - uncomment when API is ready
          // 'onToggle': (bool value) {
          //   debugPrint('🔒 Security PIN toggle: ${value ? "enable" : "disable"}');
          //   // If turning OFF while pending, just reset pending state
          //   if (!value && _pendingPinSetup && !isPinEnabled) {
          //     setState(() {
          //       _pendingPinSetup = false;
          //     });
          //     return;
          //   }
          //   _handlePinToggle(value);
          // },
        },
        {
          'icon': AppIcons.fingerprintIc,
          'title': 'App lock',
          'subtitle': 'if you enable app lock your phone biometic or pin or pattern is going to use directly to open the app',
          'value': _biometricEnabled,
          'onToggle': (bool value) {
            setState(() {
              _biometricEnabled = value;
            });
            debugPrint('👆 Biometric ${value ? "enabled" : "disabled"}');
            // TODO: Save biometric preference
          },
        },
        {
          'icon': AppIcons.mobileIc,
          'title': 'Active device',
          'subtitle': '',
          'hasButton': true,
        },
      ];

      return Padding(
        padding: EdgeInsets.all(responsive.wp(3)),
        child: Column(
          children: List.generate(securityOptions.length, (index) {
            final option = securityOptions[index];
            final hasToggle = option.containsKey('value') && option.containsKey('onToggle');

            return Column(
              children: [
                GestureDetector(
                  onTap: hasToggle ? null : (option['onTap'] as VoidCallback?),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.wp(4),
                      vertical: responsive.hp(2),
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.containerLight : AppColorsLight.containerLight,
                      borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // First Row: Icon + Title + Toggle/Arrow
                        Row(
                          children: [
                            // Leading icon
                            SvgPicture.asset(
                              option['icon'] as String,
                              width: responsive.iconSizeExtraLarge,
                              height: responsive.iconSizeExtraLarge,
                              colorFilter: ColorFilter.mode(
                                isDark ? AppColors.white : AppColorsLight.iconPrimary,
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(width: responsive.wp(3)),

                            // Title
                            Expanded(
                              child: AppText.searchbar(
                                option['title'] as String,
                                  color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                                  fontWeight: FontWeight.w500,
                                maxLines: 1,
                                minFontSize: 10,
                                letterSpacing: 1.0,
                              ),
                            ),

                            SizedBox(width: responsive.wp(2)),

                            // Trailing: ON/OFF Toggle
                            if (hasToggle)
                              _buildOnOffToggle(
                                responsive,
                                isDark,
                                option['value'] as bool,
                                option['onToggle'] as ValueChanged<bool>,
                              ),
                          ],
                        ),

                        // Second Row: Subtitle (below icon + title) - only show if subtitle is not empty
                        if ((option['subtitle'] as String).isNotEmpty) ...[
                          SizedBox(height: responsive.hp(1.5)),
                          AppText.headlineLarge(
                            option['subtitle'] as String,
                              color: isDark
                                  ? AppColors.textDisabled
                                  : AppColorsLight.textSecondary,
                            fontWeight: FontWeight.w400,
                            maxLines: 4,
                            minFontSize: 10,
                            letterSpacing: 1.0,
                          ),
                        ],

                        // Show "Set PIN" button if toggle is ON but PIN not yet enabled
                        if (index == 0 && _pendingPinSetup && !isPinEnabled) ...[
                          SizedBox(height: responsive.hp(3)),
                          AppButton(
                            text: 'Set PIN',
                            height: responsive.hp(6),
                            width: double.infinity,
                            borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                            borderColor: isDark ? AppColors.border1 : AppColorsLight.shadowLight,
                            textStyle: TextStyle(
                              color: isDark ? Colors.white : AppColorsLight.buttonTextColor,
                              fontSize: responsive.fontSize(16),
                              fontWeight: FontWeight.w600,
                            ),
                            gradientColors: isDark
                                ? [
                                    AppColors.containerLight,
                                    AppColors.containerDark,
                                  ]
                                : [
                                    AppColorsLight.gradientColor1,
                                    AppColorsLight.gradientColor2,
                                  ],
                            onPressed: _handleSetPinClick,
                          ),
                        ],

                        // Show Change PIN button if this is Security PIN option and it's enabled
                        if (index == 0 && isPinEnabled) ...[
                          SizedBox(height: responsive.hp(3)),
                          AppButton(
                            text: 'Change PIN',
                            height: responsive.hp(6),
                            width: double.infinity,
                            borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                            borderColor: isDark ? AppColors.border1 : AppColorsLight.shadowLight,
                            textStyle: TextStyle(
                              color: isDark ? Colors.white : AppColorsLight.buttonTextColor,
                              fontSize: responsive.fontSize(16),
                              fontWeight: FontWeight.w600,
                            ),
                            gradientColors: isDark
                                ? [
                              AppColors.containerLight,
                              AppColors.containerDark,
                                  ]
                                : [
                                    AppColorsLight.gradientColor1,
                                    AppColorsLight.gradientColor2,
                                  ],
                            onPressed: _isPinOperationLoading ? null : _changePinFlow,
                          ),
                        ],

                        // Show Active devices list and Logout button
                        if (option['hasButton'] == true) ...[
                          SizedBox(height: responsive.hp(2)),

                          // Device list (no loading indicator - uses pull to refresh)
                          if (_devices.isEmpty && !_isLoadingDevices)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: responsive.hp(2)),
                              child: AppText.searchbar2(
                                'No active devices',
                                  color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                                maxLines: 1,
                                minFontSize: 10,
                                letterSpacing: 1.0,
                              ),
                            )
                          else
                            ...List.generate(_devices.length, (deviceIndex) {
                              final device = _devices[deviceIndex];
                              final isCurrentDevice = device.deviceId == DeviceInfoService.deviceId;

                              return Padding(
                                padding: EdgeInsets.only(bottom: responsive.hp(0.5)),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: responsive.wp(3),
                                    vertical: responsive.hp(1.5),
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.black.withOpacity(0.5) : AppColorsLight.blue,
                                    borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Left side: Device name and address
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            AppText.searchbar1(
                                              device.deviceName ?? 'Unknown Device',
                                                color: AppColors.white,
                                                fontWeight: FontWeight.w500,
                                        maxLines: 1,
                                        minFontSize: 9,
                                        letterSpacing: 1.0,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            // Show merchant business address instead of device address
                                          if (_merchantAddress.isNotEmpty) ...[
                                              SizedBox(height: responsive.hp(0.3)),
                                              AppText.searchbar(
                                                _merchantAddress,
                                                  color: AppColors.textDisabled,
                                                maxLines: 1,
                                                minFontSize: 10,
                                                letterSpacing: 1.0,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),

                                      SizedBox(width: responsive.wp(2)),

                                      // Right side: Current device or Logout

                                      if (isCurrentDevice)
                                        AppText.headlineLarge(
                                          'Current device',
                                            color: isDark ? AppColors.primeryamount : AppColorsLight.blue,
                                            fontWeight: FontWeight.w500,

                                        )
                                      else
                                        GestureDetector(
                                          onTap: () async {
                                            debugPrint('🚪 Logout device: ${device.sessionId}');
                                            if (device.sessionId != null) {
                                              // Show confirmation dialog
                                              final success = await showLogoutConfirmationDialog(
                                                context,
                                                logoutType: LogoutType.specificDevice,
                                                sessionId: device.sessionId,
                                                deviceName: device.deviceName,
                                              );

                                              if (success == true) {
                                                AdvancedErrorService.showSuccess(
                                                  'Device logged out successfully',
                                                  type: SuccessType.snackbar,
                                                );
                                                _loadActiveDevices(); // Refresh list
                                              }
                                            }
                                          },
                                          child: AppText.headlineLarge(
                                            'Logout',
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,

                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }),

                          SizedBox(height: responsive.hp(2)),

                          // Logout from all devices button
                          AppButton(
                            text: 'Logout from all device',
                            height: responsive.hp(6),
                            width: double.infinity,
                            borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                            borderColor: isDark ? AppColors.border1 : AppColorsLight.shadowLight,
                            textStyle: TextStyle(
                              color: isDark ? Colors.white : AppColorsLight.buttonTextColor,
                              fontSize: responsive.fontSize(16),
                              fontWeight: FontWeight.w600,
                            ),
                            gradientColors: isDark
                                ? [
                                    AppColors.containerLight,
                                    AppColors.containerDark,
                                  ]
                                : [
                                    AppColorsLight.gradientColor1,
                                    AppColorsLight.gradientColor2,
                                  ],
                            onPressed: () async {
                              debugPrint('🚪 Logout from all device button tapped');

                              // Show confirmation dialog
                              await showLogoutConfirmationDialog(
                                context,
                                logoutType: LogoutType.allDevices,
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                if (index < securityOptions.length - 1)
                  SizedBox(height: responsive.hp(0.8)),
              ],
            );
          }),
        ),
      );
    });
  }

  Widget _buildOnOffToggle(
    AdvancedResponsiveHelper responsive,
    bool isDark,
    bool isEnabled,
    ValueChanged<bool> onToggle,
  ) {
    return GestureDetector(
      onTap: () => onToggle(!isEnabled),
      child: Container(
        width: responsive.wp(30),
        height: responsive.hp(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            // ON Button
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  gradient: isEnabled
                      ? const LinearGradient(
                          colors: [
                            Color(0xFF5b5b5b),
                            Color(0xFF303030),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: isDark
                              ? [
                                  AppColors.black,
                                  AppColors.black,
                                ]
                              : [
                                  AppColorsLight.gradientColor1,
                                  AppColorsLight.gradientColor2,
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                  boxShadow: isEnabled
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: AppText.searchbar1(
                    'On',
                      color: isEnabled
                          ? Colors.white
                          : (isDark ? Colors.white.withOpacity(0.4) : AppColorsLight.textSecondary),
                      fontWeight: isEnabled ? FontWeight.w600 : FontWeight.w500,
                    maxLines: 1,
                    minFontSize: 9,
                  ),
                ),
              ),
            ),

            SizedBox(width: 2),

            // OFF Button
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  gradient: !isEnabled
                      ? const LinearGradient(
                          colors: [
                            Color(0xFF5b5b5b),
                            Color(0xFF303030),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: isDark
                              ? [
                                  AppColors.black,
                                  AppColors.black,
                                ]
                              : [
                                  AppColorsLight.gradientColor1,
                                  AppColorsLight.gradientColor2,
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                  boxShadow: !isEnabled
                      ? [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: AppText.searchbar1(
                    'Off',
                      color: !isEnabled
                          ? Colors.white
                          : (isDark ? Colors.white.withOpacity(0.4) : AppColorsLight.textSecondary),
                      fontWeight: !isEnabled ? FontWeight.w600 : FontWeight.w500,
                    maxLines: 1,
                    minFontSize: 9,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}