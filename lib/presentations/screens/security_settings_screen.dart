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
import '../../buttons/custom_toggle_button.dart';
import '../../buttons/app_button.dart';
import '../widgets/dialogs/pin_verification_dialog.dart';
import '../widgets/dialogs/new_number_otp_dialog.dart';
import '../../core/api/auth_storage.dart';
import '../../core/utils/formatters.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _biometricEnabled = false;
  bool _pinEnabled = true;

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
              AppText.custom(
                'Security',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColorsLight.textPrimary,
                  fontSize: responsive.fontSize(20),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                minFontSize: 12,
                letterSpacing: 1.1,
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: responsive.hp(2)),
            _buildSecurityOptions(responsive, isDark),
            SizedBox(height: responsive.hp(10)),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityOptions(AdvancedResponsiveHelper responsive, bool isDark) {
    final securityOptions = [
      {
        'icon': AppIcons.lockIc,
        'title': 'Security PIN',
        'subtitle': 'You can change the security pin to do any transaction, add or remove entries & other critical actions',
        'value': _pinEnabled,
        'onToggle': (bool value) {
          setState(() {
            _pinEnabled = value;
          });
          debugPrint('🔒 Security PIN ${value ? "enabled" : "disabled"}');
          // TODO: Save PIN lock preference
        },
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
          final hasCustomTrailing = option.containsKey('trailing');

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
                            child: AppText.custom(
                              option['title'] as String,
                              style: TextStyle(
                                color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                                fontSize: responsive.fontSize(20),
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                            ),
                          ),

                          SizedBox(width: responsive.wp(2)),

                          // Trailing: ON/OFF Toggle or nothing (for options with buttons)
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
                        AppText.custom(
                          option['subtitle'] as String,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textDisabled
                                : AppColorsLight.textSecondary,
                            fontSize: responsive.fontSize(13),
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 3,
                        ),
                      ],

                      // Show Change PIN button if this is Security PIN option and it's enabled
                      if (index == 0 && _pinEnabled) ...[
                        SizedBox(height: responsive.hp(3)),
                        AppButton(
                          text: 'Set pin',
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
                            debugPrint('🔐 Set PIN button tapped');

                            // Fetch merchant phone number
                            final phone = await AuthStorage.getPhoneNumber();
                            final maskedPhone = phone != null ? Formatters.formatMaskedPhone(phone) : null;
                            final formattedPhone = phone != null ? Formatters.formatPhoneWithCountryCode(phone) : null;

                            debugPrint('📱 Phone: $phone → Masked: $maskedPhone');

                            // Step 1: Open PIN verification dialog
                            final pinResult = await PinVerificationDialog.show(
                              context: context,
                              title: 'Set Security PIN',
                              subtitle: 'Enter a 4-digit pin proceed',
                              maskedPhoneNumber: maskedPhone,
                              requireOtp: false,
                              confirmButtonText: 'Send Otp',
                            );

                            if (pinResult != null && pinResult['pin'] != null) {
                              debugPrint('✅ PIN entered: ${pinResult['pin']}');

                              // Step 2: Open OTP dialog for new number
                              final otp = await NewNumberOtpDialog.show(
                                context: context,
                                newPhoneNumber: formattedPhone ?? 'your phone',
                                title: 'Verify New Number',
                                subtitle: 'Enter OTP sent to\n${formattedPhone ?? "your phone"}',
                                confirmButtonText: 'Confirm',

                              );

                              if (otp != null) {
                                debugPrint('✅ OTP verified: $otp');
                                // TODO: Call API to set new PIN with PIN and OTP
                              } else {
                                debugPrint('❌ OTP verification cancelled');
                              }
                            } else {
                              debugPrint('❌ PIN entry cancelled');
                            }
                          },
                        ),
                      ],

                      // Show Logout from all device button if this is Active device option
                      if (option['hasButton'] == true) ...[
                        SizedBox(height: responsive.hp(3)),
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
                          onPressed: () {
                            debugPrint('🚪 Logout from all device button tapped');
                            // TODO: Implement logout from all devices API call
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
        width: responsive.wp(22),
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
                  child: AppText.custom(
                    'On',
                    style: TextStyle(
                      color: isEnabled
                          ? Colors.white
                          : (isDark ? Colors.white.withOpacity(0.4) : AppColorsLight.textSecondary),
                      fontSize: responsive.fontSize(12),
                      fontWeight: isEnabled ? FontWeight.w600 : FontWeight.w500,
                    ),
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
                  child: AppText.custom(
                    'Off',
                    style: TextStyle(
                      color: !isEnabled
                          ? Colors.white
                          : (isDark ? Colors.white.withOpacity(0.4) : AppColorsLight.textSecondary),
                      fontSize: responsive.fontSize(12),
                      fontWeight: !isEnabled ? FontWeight.w600 : FontWeight.w500,
                    ),
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
