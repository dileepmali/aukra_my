
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_fonts.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/helpers/policy_content_helper.dart';
import '../../widgets/custom_app_bar/app_bar.dart';
import '../../widgets/custom_app_bar/model/app_bar_config.dart';
import '../../widgets/custom_single_border_color.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
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
                  print('🔙 Back button tapped in AboutUsScreen');
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
                      'About us',
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
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.wp(4),
                  vertical: responsive.hp(2),
                ),
                child: _buildAboutContent(responsive),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutContent(AdvancedResponsiveHelper responsive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.containerLight : AppColorsLight.background,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainTitle(responsive, PolicyContentHelper.getAboutTitle()),
            _buildSection(
              responsive,
              '',
              PolicyContentHelper.getAboutWhatIsAukra(),
              subtitle: PolicyContentHelper.getAboutLastUpdated(),
            ),
            _buildDivider(responsive),
            _buildSection(
              responsive,
              '',
              PolicyContentHelper.getAboutVision(),
              subtitle: 'Our vision',
            ),
            _buildDivider(responsive),
            _buildSection(
              responsive,
              '',
              PolicyContentHelper.getAboutCoreValues(),
              subtitle: 'Our Core Values',
            ),
            _buildDivider(responsive),
            _buildSection(
              responsive,
              '',
              PolicyContentHelper.getAboutAnantKaya(),
              subtitle: 'About AnantKaya Solutions Pvt. Ltd.',
            ),
            SizedBox(height: responsive.hp(5)),
          ],
        ),
      ),
    );
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
        style: AppFonts.headlineSmall(
          color: isDark ? AppColors.white : AppColorsLight.textPrimary,
          fontWeight: FontWeight.w600,
        ).copyWith(
          fontSize: responsive.fontSize(18),
        ),
      ),
    );
  }

  Widget _buildSection(AdvancedResponsiveHelper responsive, String title, String content, {String? subtitle}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: responsive.spacing(4), top: responsive.spacing(2)),
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
                fontSize: responsive.fontSize(16),
              ),
            ),
          ],
          _buildContentWithLinks(content, responsive),
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

  Widget _buildContentWithLinks(String content, AdvancedResponsiveHelper responsive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    TextStyle baseTextStyle = AppFonts.bodyLarge(
      color: isDark ? AppColors.white.withOpacity(0.85) : AppColorsLight.textPrimary.withOpacity(0.85),
      fontWeight: FontWeight.w400,
    ).copyWith(
      fontSize: responsive.fontSize(14),
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

    return RichText(
      text: TextSpan(
        style: baseTextStyle,
        children: _parseContentForLinks(content, baseTextStyle, linkStyle),
      ),
    );
  }

  List<TextSpan> _parseContentForLinks(String text, TextStyle normalStyle, TextStyle linkStyle) {
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
            final Uri uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
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
