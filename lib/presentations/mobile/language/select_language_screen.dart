import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../../app/constants/app_icons.dart';
import '../../../buttons/app_button.dart';
import '../../../buttons/row_app_bar.dart';
import '../../../core/api/auth_storage.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../../../core/untils/binding/number_binding.dart';
import '../../../presentations/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_fonts.dart';
import '../../../app/themes/app_text.dart';
import '../../../controllers/localization_controller.dart';
import '../../../controllers/splash_controller.dart';
import '../../../controllers/language_search_controller.dart';
import '../../../controllers/user_preference_controller.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/services/back_button_service.dart';
import '../../../core/services/localization_service.dart';
import '../../../app/localizations/l10n/app_strings.dart';
import '../../widgets/custom_app_bar/app_bar.dart';
import '../../widgets/custom_app_bar/model/app_bar_config.dart';
import '../../widgets/custom_border_widget.dart';
import '../../widgets/custom_single_border_color.dart';
import '../../widgets/dialogs/exit_confirmation_dialog.dart';
import '../auth/number_verify_screen.dart';
import '../screens/shop_detail_screen.dart';
import '../../desktop/language/select_language_desktop_content.dart';


class SelectLanguageScreen extends StatefulWidget {
  final bool fromProfile; // ✅ NEW: Track if opened from My Profile screen

  const SelectLanguageScreen({
    super.key,
    this.fromProfile = false, // Default: first install flow
  });

  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> with WidgetsBindingObserver {

  late final LocalizationController _localizationController;
  late final LanguageSearchController _searchController;
  SplashController? _splashController;
  String? _controllerTag; // Store the controller tag for proper disposal
  bool _isDisposing = false; // Track disposal state

  /// Safely access the search controller to prevent disposed controller usage
  LanguageSearchController? get _safeSearchController {
    try {
      if (_isDisposing || _searchController.isClosed) {
        return null;
      }
      return _searchController;
    } catch (e) {
      debugPrint('⚠️ Error accessing search controller: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Ensure LocalizationService is available before accessing LocalizationController
    if (!Get.isRegistered<LocalizationService>()) {
      Get.put<LocalizationService>(
        LocalizationService(),
        permanent: true,
      );
      print('LocalizationService re-registered in SelectLanguageScreen');
    }

    _localizationController = Get.find<LocalizationController>();

    // 🔧 FIX: Reload language from storage to ensure fresh state after logout
    // This ensures the UI reflects the actual stored language (default 'en' after logout)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _localizationController.loadSavedLanguage();
      debugPrint('🌐 Language reloaded from storage: ${_localizationController.currentLanguageCode}');
    });

    // Initialize search controller with unique tag to avoid conflicts
    _controllerTag = 'language_search_${DateTime.now().millisecondsSinceEpoch}';
    _searchController = Get.put(LanguageSearchController(), tag: _controllerTag);

    // Reset selection state when screen initializes
    _searchController.isSelecting.value = false;
    try {
      _splashController = Get.find<SplashController>();
    } catch (e) {
      // SplashController not found - this is optional
    }

    // Register back button handler to show exit confirmation dialog
    BackButtonService.registerWithCleanup(
      screenName: 'SelectLanguageScreen',
      onBackPressed: BackButtonService.handleSelectLanguageBack,
      interceptorName: 'select_language_interceptor',
      priority: 1,
    );
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reset selection state when app comes to foreground
      _searchController.isSelecting.value = false;
    }
  }

  Future<void> _checkSecureStorageAndNavigate() async {
    try {
      final isTokenValid = await AuthStorage.isTokenValid();
      if (isTokenValid ?? false) {
        // Check if shop details are complete before going to MainScreen
        final hasShopDetails = await AuthStorage.hasShopDetails();
        if (hasShopDetails) {
          Get.offAllNamed(AppRoutes.main as String);
        } else {
          // Navigate to ShopDetailScreen to complete merchant setup
          Get.off(() => const ShopDetailScreen());
        }
      } else {
        Get.to(
              () => NumberVerifyScreen(),
          binding: NumberBinding(),
        );
      }
    } catch (e) {
      // Auth check failed, fallback to number verification
      Get.to(
            () => NumberVerifyScreen(),
        binding: NumberBinding(),
      );
    }
  }

  /// ✅ NEW: Handle Save button from My Profile (just save language and go back)
  Future<void> _handleSaveLanguage() async {
    debugPrint('💾 Saving language from profile...');

    // Get selected language
    final selectedLang = _searchController.currentLanguages.firstWhere(
      (lang) => _localizationController.currentLanguageCode == lang['code'],
      orElse: () => _searchController.currentLanguages.first,
    );

    // Save the selected language
    if (_localizationController.currentLanguageCode != selectedLang['code']) {
      await _localizationController.changeLocale(selectedLang['code'] ?? '');
    }

    // ✅ Update user preference via API
    await _updateLanguagePreference(selectedLang['code'] ?? 'en');

    debugPrint('✅ Language saved: ${selectedLang['code']}');

    // Go back to My Profile
    Get.back();
  }

  /// ✅ Update language preference via API
  Future<void> _updateLanguagePreference(String languageCode) async {
    try {
      if (Get.isRegistered<UserPreferenceController>()) {
        final prefController = Get.find<UserPreferenceController>();
        await prefController.setLanguage(languageCode);
        debugPrint('✅ Language preference updated via API: $languageCode');
      }
    } catch (e) {
      debugPrint('❌ Error updating language preference: $e');
    }
  }

  Future<void> _handleContinuePressed(BuildContext context) async {
    // First dismiss keyboard
    FocusScope.of(context).unfocus();

    // Wait for keyboard to close
    await Future.delayed(Duration(milliseconds: 300));

    // Get the selected language - prioritize current selection, then auto-selected
    Map<String, String> selectedLang;

    if (_searchController.isSearching.value &&
        _searchController.autoSelectedLanguageKey.value.isNotEmpty) {
      // During search, use auto-selected language if no manual selection
      final currentMatch = _searchController.currentLanguages.where(
        (lang) => _localizationController.currentLanguageCode == lang['code']
      ).toList();

      if (currentMatch.isNotEmpty) {
        // User manually selected a language
        selectedLang = currentMatch.first;
      } else {
        // Use auto-selected language
        selectedLang = _searchController.currentLanguages.firstWhere(
          (lang) => lang['code'] == _searchController.autoSelectedLanguageKey.value,
          orElse: () => _searchController.currentLanguages.first,
        );
      }
    } else {
      // Normal mode - use current language or first available
      selectedLang = _searchController.currentLanguages.isNotEmpty
          ? _searchController.currentLanguages.firstWhere(
              (lang) => _localizationController.currentLanguageCode == lang['code'],
              orElse: () => _searchController.currentLanguages.first,
            )
          : {'code': 'en', 'name': 'English'};
    }

    _searchController.isSelecting.value = true;

    if (_localizationController.currentLanguageCode != selectedLang['code']) {
      _localizationController.changeLocale(selectedLang['code'] ?? '');
    }

    // 🔧 FIX: Mark language selection as complete
    // This ensures 'is_first_time_install' is set to false
    await _localizationController.completeLanguageSelection();
    debugPrint('✅ Language selection completed: ${_localizationController.currentLanguageCode}');

    // ✅ DON'T call API here - user is not logged in yet
    // Language preference will be synced to backend in MainScreen after successful login
    // await _updateLanguagePreference(selectedLang['code'] ?? 'en');

    await _checkSecureStorageAndNavigate();

    // Reset state after navigation (in case user comes back)
    _searchController.isSelecting.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ FIX: Moved AppStrings.init to post-frame callback to avoid setState during build
    // Reset selection state whenever screen is built (including when navigating back)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Initialize AppStrings for localization (safe to call after build)
      AppStrings.init(context);

      final controller = _safeSearchController;
      if (controller != null && controller.isSelecting.value) {
        controller.isSelecting.value = false;
      }
    });

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        debugPrint('');
        debugPrint('╔══════════════════════════════════════════════════════════╗');
        debugPrint('║  🔙 BACK NAVIGATION TRIGGERED                            ║');
        debugPrint('╠══════════════════════════════════════════════════════════╣');
        debugPrint('║  📍 FROM: SelectLanguageScreen                           ║');
        debugPrint('║  📍 TO:   EXIT APP (Dialog)                              ║');
        debugPrint('╠══════════════════════════════════════════════════════════╣');
        debugPrint('║  ⏰ Time: ${DateTime.now()}');
        debugPrint('╚══════════════════════════════════════════════════════════╝');
        debugPrint('');

        // Show exit confirmation dialog
        final shouldExit = await Get.dialog<bool>(
          const ExitConfirmationDialog(),
          barrierDismissible: false,
          barrierColor: AppColors.transparent.withValues(alpha: 0.7),
        );

        if (shouldExit == true) {
          debugPrint('✅ User confirmed exit - closing app');
          SystemNavigator.pop();
        } else {
          debugPrint('❌ User cancelled exit - staying in app');
        }
      },
      child: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          // Safety check: Don't build if disposing or controller is closed
          final safeController = _safeSearchController;
          if (safeController == null) {
            return Scaffold(
              backgroundColor: isDark ? AppColors.overlay : AppColorsLight.scaffoldBackground,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Check if desktop/widescreen based on screen width
          final isDesktop = responsive.screenWidth > 600;

          // Desktop layout
          if (isDesktop) {
            return Scaffold(
              backgroundColor: isDark ? AppColors.overlay : AppColorsLight.scaffoldBackground,
              body: SelectLanguageDesktopContent(
                localizationController: _localizationController,
                searchController: _searchController,
                onContinuePressed: () => _handleContinuePressed(context),
              ),
            );
          }

          // Mobile layout
          return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: isDark ? AppColors.overlay : AppColorsLight.scaffoldBackground,
          appBar: CustomResponsiveAppBar(
            config: AppBarConfig(
              enableSearchInput: true,
              forceEnableSearch: true, // 🔧 NEW: Force enable search ONLY for contact_screen
              customHeight:responsive.hp(18),
              customPadding: EdgeInsets.symmetric(horizontal: responsive.wp(3)),
              leadingWidget: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: isDark ? Colors.white : AppColorsLight.iconPrimary,
                      size: responsive.iconSizeLarge,
                    ),
                  ),
                  SizedBox(
                    width: responsive.spaceSM,
                  ),
                  AppText.searchbar2(
                    AppStrings.getLocalizedString(context, (localizations) => localizations.selectLanguage),
                    color: isDark ? Colors.white : AppColorsLight.textPrimary,
                    maxLines: 1,
                    minFontSize: 14,
                  ),
                ],
              ),
              type: AppBarType.searchOnly,
              searchController: _searchController.searchController,
              searchHint: AppStrings.getLocalizedString(context, (localizations) => localizations.search),
              onSearchChanged: (value) {
                // Search is handled automatically by the controller's listener
              },
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: responsive.hp(0),
                  left: 0,
                  right: 0,
                  bottom: isKeyboardVisible
                      ? MediaQuery.of(context).viewInsets.bottom * 0.2
                      : responsive.hp(12),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: responsive.screenPadding.left,
                      right: responsive.screenPadding.right,
                      top: responsive.screenPadding.top,
                      bottom: responsive.hp(2),
                    ),
                    child: Column(
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: responsive.wp(95),
                          ),
                          child: Obx(() {
                            final languages = _searchController.currentLanguages;

                            if (languages.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: responsive.wp(15),
                                      color: isDark
                                          ? AppColors.textWhite.withOpacity(0.5)
                                          : AppColorsLight.textSecondary,
                                    ),
                                    SizedBox(height: responsive.spaceMD),
                                    AppText.headlineSmall(
                                      AppStrings.getLocalizedString(context, (localizations) => localizations.noLanguagesFound),
                                      color: isDark
                                          ? AppColors.textWhite.withOpacity(0.7)
                                          : AppColorsLight.textPrimary,
                                      maxLines: 2,
                                      minFontSize: 9,
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: responsive.spaceSM),
                                    AppText.bodyMedium(
                                      AppStrings.getLocalizedString(context, (localizations) => localizations.tryDifferentSearchTerm),
                                      color: isDark
                                          ? AppColors.textWhite.withOpacity(0.5)
                                          : AppColorsLight.textSecondary,
                                      maxLines: 2,
                                      minFontSize: 8,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: responsive.smartGridColumns(
                                  minColumns: 2,
                                  maxColumns: 6,
                                  itemMinWidth: 140.0,
                                ),
                                crossAxisSpacing: responsive.smartSpacing(SpacingLevel.sm),
                                mainAxisSpacing: responsive.smartSpacing(SpacingLevel.sm),
                                childAspectRatio: 1.4,
                              ),
                              itemCount: languages.length,
                              itemBuilder: (context, index) {
                                final lang = languages[index];

                                return Obx(() {
                                  final isCurrentLanguage = _localizationController.currentLanguageCode == (lang['code'] ?? '');
                                  final isAutoSelected = _searchController.isSearching.value &&
                                                       _searchController.isLanguageAutoSelected(lang['code'] ?? '');
                                  
                                  // Check if any language in current results is manually selected
                                  final hasManualSelection = _searchController.currentLanguages.any(
                                    (l) => _localizationController.currentLanguageCode == l['code']
                                  );
                                  
                                  // Selection logic: Manual selection takes priority over auto-selection
                                  final isSelected = isCurrentLanguage || 
                                                   (isAutoSelected && !hasManualSelection);

                                  return BorderColor(
                                    isSelected: isSelected,
                                    borderRadius: responsive.borderRadiusSmall,
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 150),
                                      curve: Curves.easeOut,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: isDark
                                              ? [
                                            AppColors.containerDark.withOpacity(0.8),
                                            AppColors.containerDark.withOpacity(0.8),
                                            AppColors.containerDark.withOpacity(0.8),
                                          ]
                                              : [
                                            AppColorsLight.background,
                                            AppColorsLight.background,
                                            AppColorsLight.background,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(math.max(0, responsive.borderRadiusSmall - 2)),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(math.max(0, responsive.borderRadiusSmall - 2)),
                                          onTap: () {
                                            // Change language and allow selection during search
                                            _localizationController.changeLocale(lang['code'] ?? '');
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(responsive.spaceSM),
                                            child: Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  if (isSelected) ...[
                                                    SvgPicture.asset(
                                                      AppIcons.checkmarkIc,
                                                      width: responsive.wp(5),
                                                      height: responsive.hp(2.5),
                                                      colorFilter: ColorFilter.mode(
                                                        isDark ? Colors.white : AppColorsLight.textPrimary,
                                                        BlendMode.srcIn,
                                                      ),
                                                    ),
                                                    SizedBox(height: responsive.space2XS),
                                                  ],
                                                  Flexible(
                                                    child: AppText.displaySmall(
                                                      lang['name'] ?? '',
                                                      color: isDark
                                                          ? Colors.white.withOpacity(0.65)
                                                          : AppColorsLight.textPrimary,
                                                      maxLines: 1,
                                                      minFontSize: 10,
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                });
                              },
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                // ✅ CONDITIONAL: Show BottomActionBar if from Profile, else show AppButton
                Positioned(
                  bottom: isKeyboardVisible
                      ? MediaQuery.of(context).viewInsets.bottom * 0.0
                      : 0.0,
                  left: 0,
                  right: 0,
                  child: widget.fromProfile
                      ? // ✅ From My Profile → Show BottomActionBar (Go Back + Save)
                      BottomActionBar(
                          showBorder: true,
                          primaryButtonText: 'Go Back',
                          onPrimaryPressed: () {
                            debugPrint('🔙 Go Back pressed - returning to profile');
                            Get.back();
                          },
                          secondaryButtonText: 'Save',
                          onSecondaryPressed: () => _handleSaveLanguage(),
                        )
                      : // ✅ First Install → Show AppButton (Continue)
                      Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.containerDark
                                      : AppColorsLight.white),
                              padding: EdgeInsets.only(
                                left: responsive.screenPadding.left,
                                right: responsive.screenPadding.right,
                                bottom: responsive.screenPadding.bottom,
                                top: responsive.hp(1.5),
                              ),
                              child: Obx(() => AppButton(
                                    width: double.infinity,
                                    height: responsive.hp(9),
                                    gradientColors: [
                                      AppColors.splaceSecondary1,
                                      AppColors.splaceSecondary2,
                                    ],
                                    enableSweepGradient: true,
                                    borderRadius: BorderRadius.circular(
                                        responsive.borderRadiusSmall),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: responsive.wp(2),
                                        offset: Offset(0, responsive.hp(0.3)),
                                      ),
                                    ],
                                    padding: EdgeInsets.symmetric(
                                        horizontal: responsive.spacing(20)),
                                    onPressed: _searchController.isSelecting.value
                                        ? null
                                        : () => _handleContinuePressed(context),
                                    child: _searchController.isSelecting.value
                                        ? Center(
                                            child: SizedBox(
                                              height: responsive.hp(3),
                                              width: responsive.wp(7),
                                              child: CircularProgressIndicator(
                                                color: AppColors.white,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: AppText.button(
                                              AppStrings.getLocalizedString(
                                                  context,
                                                  (localizations) =>
                                                      localizations.continueText),
                                              color: AppColors.white,
                                              maxLines: 1,
                                              minFontSize: 12,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                  )),
                            ),
                            Positioned.fill(
                                child: CustomSingleBorderWidget(
                                    position: BorderPosition.top))
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    ),
    );
  }

  @override
  void dispose() {
    debugPrint('🗑️ SelectLanguageScreen disposing...');
    
    // Mark as disposing to prevent further controller access
    _isDisposing = true;
    
    // First remove observers and interceptors
    WidgetsBinding.instance.removeObserver(this);

    // Remove back button handler
    BackButtonService.remove(interceptorName: 'select_language_interceptor');
    
    // Ensure proper cleanup order to prevent TextEditingController disposal errors
    try {
      // First dismiss keyboard if active
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
      
      // Wait for any pending UI operations to complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _disposeControllerSafely();
      });
      
    } catch (e) {
      debugPrint('💥 Search controller disposal error: $e');
    }
    
    super.dispose();
    debugPrint('✅ SelectLanguageScreen disposed successfully');
  }

  /// Safely dispose the controller after UI operations complete
  void _disposeControllerSafely() {
    try {
      if (_controllerTag != null) {
        if (Get.isRegistered<LanguageSearchController>(tag: _controllerTag)) {
          debugPrint('🗑️ Disposing LanguageSearchController with tag: $_controllerTag');
          
          // Get reference to controller before deletion
          final controller = Get.find<LanguageSearchController>(tag: _controllerTag);
          
          // Delete from GetX registry
          Get.delete<LanguageSearchController>(tag: _controllerTag);
          
          // Manual dispose if still not closed
          if (!controller.isClosed) {
            controller.dispose();
          }
          
          debugPrint('✅ Successfully disposed controller with tag: $_controllerTag');
        } else {
          debugPrint('ℹ️ Controller with tag $_controllerTag not registered, may already be disposed');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error in _disposeControllerSafely: $e');
    }
  }
}