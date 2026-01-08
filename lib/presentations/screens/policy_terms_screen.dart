
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_fonts.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/helpers/policy_content_helper.dart';
import '../widgets/custom_app_bar/app_bar.dart';
import '../widgets/custom_app_bar/model/app_bar_config.dart';
import '../widgets/custom_single_border_color.dart';

class PolicyTermsScreen extends StatefulWidget {
  const PolicyTermsScreen({Key? key}) : super(key: key);

  @override
  State<PolicyTermsScreen> createState() => _PolicyTermsScreenState();
}

class _PolicyTermsScreenState extends State<PolicyTermsScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Screen initialized
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.overlay : AppColorsLight.scaffoldBackground,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            responsive.hp(12),
          ),
          child: CustomResponsiveAppBar(
            config: AppBarConfig(
              type: AppBarType.titleOnly,
              customPadding: EdgeInsets.symmetric(horizontal: responsive.wp(2.5)),
              leadingWidget: InkWell(
                onTap: () {
                  print('🔙 Back button tapped in PolicyTermsScreen');
                  Navigator.of(context).pop();
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back,
                      color: isDark ? Colors.white : AppColorsLight.textPrimary,
                      size: 25,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Policy & terms',
                      style: AppFonts.displaySmall(
                        color: isDark ? Colors.white : AppColorsLight.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            _buildTabBar(responsive),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.wp(4),
                  vertical: responsive.hp(2),
                ),
                child: _buildTabContent(responsive),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(AdvancedResponsiveHelper responsive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabs = ['Terms & Conditions', 'Privacy Policy'];

    return Stack(
      children: [
        Container(
        height: responsive.hp(8),
        padding: EdgeInsets.symmetric(
          horizontal: responsive.wp(4),
          vertical: responsive.hp(1),
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.black : AppColorsLight.background,
        ),
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            int index = entry.key;
            String tab = entry.value;
            bool isSelected = _selectedTabIndex == index;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: responsive.wp(1)),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppColors.containerDark : AppColorsLight.scaffoldBackground)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: Center(
                    child: Text(
                      tab,
                      style: AppFonts.labelLarge(
                        color: isSelected
                            ? (isDark ? AppColors.white : AppColorsLight.textPrimary)
                            : (isDark ? AppColors.white.withOpacity(0.7) : AppColorsLight.textSecondary),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ).copyWith(
                        fontSize: responsive.fontSize(16),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    Positioned.fill(child: CustomSingleBorderWidget(position: BorderPosition.bottom)),
      ]
    );
  }

  Widget _buildTabContent(AdvancedResponsiveHelper responsive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (_selectedTabIndex) {
      case 0:
        // Terms & Conditions Tab
        return Container(
          color: isDark ? AppColors.containerLight : AppColorsLight.background,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMainTitle(responsive, PolicyContentHelper.getTermsTitle()),
                _buildSection(
                  responsive,
                  '',
                  PolicyContentHelper.getTermsIntro(),
                  subtitle: PolicyContentHelper.getTermsLastUpdated(),
                ),
                _buildDivider(responsive),
                _buildSection(
                  responsive,
                  '',
                  PolicyContentHelper.getTermsAcceptance(),
                  subtitle: '1. Acceptance of Terms',
                ),
                _buildDivider(responsive),
                _buildSection(
                  responsive,
                  '',
                  PolicyContentHelper.getTermsEligibility(),
                  subtitle: '2. Eligibility',
                ),
                _buildDivider(responsive),
                _buildSection(
                  responsive,
                  '',
                  PolicyContentHelper.getTermsAccountRegistration(),
                  subtitle: '3. Account Registration',
                ),
                _buildDivider(responsive),
                _buildSection(
                  responsive,
                  '',
                  PolicyContentHelper.getTermsResponsibilities(),
                  subtitle: '4. Your Responsibilities',
                ),
                _buildDivider(responsive),
                _buildSection(
                  responsive,
                  '',
                  PolicyContentHelper.getTermsDataAccuracy(),
                  subtitle: '5. Data Accuracy',
                ),
                _buildDivider(responsive),
                _buildSection(
                  responsive,
                  '',
                  PolicyContentHelper.getTermsCommunications(),
                  subtitle: '6. Communications',
                ),
                _buildDivider(responsive),
                _buildSection(
                  responsive,
                  '',
                  PolicyContentHelper.getTermsPayments(),
                  subtitle: '7. Payments',
                ),
                _buildDivider(responsive),
                _buildSection(
                  responsive,
                  '',
                  PolicyContentHelper.getTermsIntellectualProperty(),
                  subtitle: '8. Intellectual Property',
                ),
                _buildDivider(responsive),
                _buildSection(
                  responsive,
                  '',
                  PolicyContentHelper.getTermsDataSecurity(),
                  subtitle: '9. Data Security & Privacy',
                ),
                _buildDivider(responsive),
                _buildSection(
                  responsive,
                  '',
                  PolicyContentHelper.getTermsLimitation(),
                  subtitle: '10. Limitation of Liability',
                ),
                _buildDivider(responsive),
                _buildSection(
                  responsive,
                  '',
                  PolicyContentHelper.getTermsTermination(),
                  subtitle: '11. Termination',
                ),
                _buildDivider(responsive),
                _buildSection(
                  responsive,
                  '',
                  PolicyContentHelper.getTermsModifications(),
                  subtitle: '12. Modifications',
                ),
                _buildDivider(responsive),
                _buildSection(
                  responsive,
                  '',
                  PolicyContentHelper.getTermsGoverningLaw(),
                  subtitle: '13. Governing Law',
                ),
                SizedBox(height: responsive.hp(5)),
              ],
            ),
          ),
        );
      case 1:
        // Privacy Policy Tab
        return Container(
          color: isDark ? AppColors.containerLight : AppColorsLight.background,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMainTitle(responsive, PolicyContentHelper.getPrivacyTitle()),
                _buildSection(
                  responsive,
                  '',
                  PolicyContentHelper.getPrivacyIntroduction(),
                  subtitle: PolicyContentHelper.getPrivacyLastUpdated(),
                ),
                _buildDivider(responsive),
                _buildSection(
                  responsive,
                  '',
                  PolicyContentHelper.getPrivacyInformationCollect(),
                  subtitle: '2. Information We Collect',
                ),
                _buildDivider(responsive),
                _buildSection(
                  responsive,
                  '',
                  PolicyContentHelper.getPrivacyUseInformation(),
                  subtitle: '3. How We Use Your Information',
                ),
                _buildDivider(responsive),
                _buildSection(
                  responsive,
                  '',
                  PolicyContentHelper.getPrivacyDataSecurity(),
                  subtitle: '4. Data Security',
                ),
                _buildDivider(responsive),
                _buildSection(
                  responsive,
                  '',
                  PolicyContentHelper.getPrivacyDataSharing(),
                  subtitle: '5. Data Sharing',
                ),
                _buildDivider(responsive),
                _buildSection(
                  responsive,
                  '',
                  PolicyContentHelper.getPrivacyDataRetention(),
                  subtitle: '6. Data Retention',
                ),
                _buildDivider(responsive),
                _buildSection(
                  responsive,
                  '',
                  PolicyContentHelper.getPrivacyYourRights(),
                  subtitle: '7. Your Rights',
                ),
                _buildDivider(responsive),
                _buildSection(
                  responsive,
                  '',
                  PolicyContentHelper.getPrivacyThirdParty(),
                  subtitle: '8. Third-Party Services',
                ),
                _buildDivider(responsive),
                _buildSection(
                  responsive,
                  '',
                  PolicyContentHelper.getPrivacyChildren(),
                  subtitle: '9. Children\'s Privacy',
                ),
                _buildDivider(responsive),
                _buildSection(
                  responsive,
                  '',
                  PolicyContentHelper.getPrivacyUpdates(),
                  subtitle: '10. Updates to this Policy',
                ),
                _buildDivider(responsive),
                _buildSection(
                  responsive,
                  '',
                  PolicyContentHelper.getPrivacyContact(),
                  subtitle: '11. Contact Us',
                ),
                SizedBox(height: responsive.hp(5)),
              ],
            ),
          ),
        );
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildMainTitle(AdvancedResponsiveHelper responsive, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: responsive.hp(0.5),
      ),
      child: Text(
        title,
        style: AppFonts.displayMedium(
          color: isDark ? AppColors.white : AppColorsLight.textPrimary,
          fontWeight: FontWeight.bold,
        ).copyWith(
          fontSize: responsive.fontSize(20),
        ),
      ),
    );
  }

  Widget _buildSection(AdvancedResponsiveHelper responsive, String title, String content, {String? subtitle}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: responsive.spacing(4),top: responsive.spacing(2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: AppFonts.headlineLarge(
                color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                fontWeight: FontWeight.bold,
              ).copyWith(
                fontSize: responsive.fontSize(20),
              ),
            ),
          ],
          if (subtitle != null) ...[
            Text(
              subtitle,
              style: AppFonts.headlineSmall(
                color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                fontWeight: FontWeight.bold,
              ).copyWith(
                fontSize: responsive.fontSize(18),
              ),
            ),
          ],
          _buildContentWithDividers(content, responsive),
        ],
      ),
    );
  }

  Widget _buildDivider(AdvancedResponsiveHelper responsive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: responsive.wp(2),
        vertical: responsive.hp(1.5),
      ),
      height: 1.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            isDark ? AppColors.white.withOpacity(0.3) : AppColorsLight.textSecondary.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildContentWithDividers(String content, AdvancedResponsiveHelper responsive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    List<String> lines = content.split('\n');
    List<Widget> widgets = [];
    List<String> currentSection = [];
    
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      
      // Check if this line starts with a number (new section)
      RegExp numberPattern = RegExp(r'^\d+\.\s*');
      bool isNumberedLine = numberPattern.hasMatch(line);
      
      // If we hit a new numbered section and we have content in currentSection
      if (isNumberedLine && currentSection.isNotEmpty) {
        // Add the previous section
        widgets.add(RichText(
          text: TextSpan(
            style: AppFonts.bodyLarge(
              color: isDark ? AppColors.white.withOpacity(0.85) : AppColorsLight.textPrimary.withOpacity(0.85),
              fontWeight: FontWeight.w400,
            ).copyWith(
              fontSize: responsive.fontSize(14),
              height: 1.6,
            ),
            children: _parseContentWithNumbers(currentSection.join('\n'), responsive),
          ),
        ));
        
        // Add divider
        widgets.add(SizedBox(height: responsive.hp(2)));
        widgets.add(Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                isDark ? AppColors.white.withOpacity(0.2) : AppColorsLight.textSecondary.withOpacity(0.2),
                Colors.transparent,
              ],
            ),
          ),
        ));
        widgets.add(SizedBox(height: responsive.hp(2)));
        
        // Start new section
        currentSection = [line];
      } else {
        // Add to current section
        currentSection.add(line);
      }
    }
    
    // Add the last section
    if (currentSection.isNotEmpty) {
      widgets.add(RichText(
        text: TextSpan(
          style: AppFonts.bodyLarge(
            color: isDark ? AppColors.white.withOpacity(0.85) : AppColorsLight.textPrimary.withOpacity(0.85),
            fontWeight: FontWeight.w400,
          ).copyWith(
            fontSize: responsive.fontSize(14),
            height: 1.6,
          ),
          children: _parseContentWithNumbers(currentSection.join('\n'), responsive),
        ),
      ));
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  List<TextSpan> _parseContentWithNumbers(String content, AdvancedResponsiveHelper responsive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    List<TextSpan> spans = [];
    List<String> lines = content.split('\n');

    // Base text style for consistency using AppFonts
    TextStyle baseTextStyle = AppFonts.bodyLarge(
      color: isDark ? AppColors.white.withOpacity(0.85) : AppColorsLight.textPrimary.withOpacity(0.85),
      fontWeight: FontWeight.w400,
    ).copyWith(
      fontSize: responsive.fontSize(14),
      height: 1.6,
    );

    TextStyle numberStyle = AppFonts.labelLarge(
      color: isDark ? AppColors.white : AppColorsLight.textPrimary,
      fontWeight: FontWeight.bold,
    ).copyWith(
      fontSize: responsive.fontSize(16),
      height: 1.6,
    );

    TextStyle linkStyle = AppFonts.bodyLarge(
      color: Colors.blue,
      fontWeight: FontWeight.w400,
    ).copyWith(
      fontSize: responsive.fontSize(14),
      height: 1.6,
      decoration: TextDecoration.underline,
    );

    for (String line in lines) {
      // Check if line starts with a number followed by a dot
      RegExp numberPattern = RegExp(r'^(\d+\.\s*)(.*)$');
      Match? match = numberPattern.firstMatch(line);

      if (match != null) {
        // Number part (bigger and bolder)
        spans.add(TextSpan(
          text: match.group(1),
          style: numberStyle,
        ));
        // Parse the rest for URLs
        spans.addAll(_parseLineForUrls(match.group(2) ?? '', baseTextStyle, linkStyle));
      } else {
        // Parse entire line for URLs
        spans.addAll(_parseLineForUrls(line, baseTextStyle, linkStyle));
      }

      // Add newline if not the last line
      if (line != lines.last) {
        spans.add(TextSpan(text: '\n'));
      }
    }

    return spans;
  }

  // Helper method to parse URLs in a line
  List<TextSpan> _parseLineForUrls(String text, TextStyle normalStyle, TextStyle linkStyle) {
    List<TextSpan> spans = [];
    RegExp urlPattern = RegExp(r'\{\{(.*?)\}\}');
    int lastIndex = 0;

    for (Match match in urlPattern.allMatches(text)) {
      // Add text before URL
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: normalStyle,
        ));
      }

      // Add clickable URL
      String url = match.group(1) ?? '';
      spans.add(TextSpan(
        text: url,
        style: linkStyle,
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            final Uri uri = Uri.parse(url.startsWith('http') ? url : 'mailto:$url');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
      ));

      lastIndex = match.end;
    }

    // Add remaining text after last URL
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: normalStyle,
      ));
    }

    return spans.isEmpty ? [TextSpan(text: text, style: normalStyle)] : spans;
  }


}
