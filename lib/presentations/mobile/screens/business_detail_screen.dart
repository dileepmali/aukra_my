import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_text.dart';
import '../../../core/api/auth_storage.dart';
import '../../../core/api/merchant_list_api.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/services/error_service.dart';
import '../../../core/untils/error_types.dart';
import '../../../controllers/shop_detail_controller.dart';
import '../../../controllers/change_master_number_controller.dart';
import '../../../controllers/privacy_setting_controller.dart';
import '../../../models/merchant_list_model.dart';
import '../../widgets/custom_app_bar/custom_app_bar.dart';
import '../../widgets/custom_app_bar/model/app_bar_config.dart';
import '../../widgets/list_item_widget.dart';
import '../../widgets/dialogs/edit_business_name_dialog.dart';
import '../../widgets/dialogs/edit_address_dialog.dart';
import '../../widgets/dialogs/pin_verification_dialog.dart';
import '../../widgets/dialogs/new_number_otp_dialog.dart';
import '../../widgets/dialogs/mobile_number_dialog.dart';
import '../../widgets/bottom_sheets/business_type_bottom_sheet.dart';
import '../../widgets/bottom_sheets/category_bottom_sheet.dart';
import '../../widgets/bottom_sheets/manager_bottom_sheet.dart';
import '../../routes/app_routes.dart';
import '../../../core/utils/dialog_transition_helper.dart';

class BusinessDetailScreen extends StatefulWidget {
  final int merchantId;
  final String businessName;
  final String? address;

  const BusinessDetailScreen({
    super.key,
    required this.merchantId,
    required this.businessName,
    this.address,
  });

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  late String _businessName;
  late String _address;
  String _masterMobile = 'Loading...';
  String _masterMobileRaw = '';
  String _businessType = 'Not specified';
  String _category = 'Not specified';
  String _manager = 'Not assigned';
  String _email = '';
  String _phone = '';
  bool _isActive = true;
  bool _isVerified = false;
  bool _isLoading = true;

  // Full merchant data from API
  MerchantListModel? _currentMerchant;
  final MerchantListApi _merchantApi = MerchantListApi();
  final ShopDetailController _shopController = Get.put(ShopDetailController());

  // Controller for changing master mobile number
  late ChangeMasterNumberController _changeNumberController;

  @override
  void initState() {
    super.initState();
    _businessName = widget.businessName;
    _address = widget.address ?? 'Business address will be shown here';
    _changeNumberController = Get.put(ChangeMasterNumberController(), tag: 'master_mobile_${widget.merchantId}');
    _loadMerchantData();
  }

  @override
  void dispose() {
    Get.delete<ChangeMasterNumberController>(tag: 'master_mobile_${widget.merchantId}');
    super.dispose();
  }

  Future<void> _loadMerchantData() async {
    try {
      debugPrint('');
      debugPrint('🏢 ========== BUSINESS DETAIL: Loading Data ==========');
      debugPrint('   Merchant ID: ${widget.merchantId}');

      // Fetch fresh data from API
      final merchants = await _merchantApi.getAllMerchants();
      debugPrint('✅ Fetched ${merchants.length} merchants from API');

      // Find current merchant by merchantId
      MerchantListModel? currentMerchant;
      for (var merchant in merchants) {
        if (merchant.merchantId == widget.merchantId) {
          currentMerchant = merchant;
          debugPrint('✅ Found merchant by ID: ${merchant.merchantId}');
          break;
        }
      }

      if (currentMerchant != null && mounted) {
        setState(() {
          _currentMerchant = currentMerchant;
          _businessName = currentMerchant!.businessName.isNotEmpty
              ? currentMerchant.businessName
              : widget.businessName;

          // Address from API
          _address = currentMerchant.formattedAddress.isNotEmpty
              ? currentMerchant.formattedAddress
              : widget.address ?? 'No address added';

          // Master mobile (adminMobileNumber from API)
          String? masterPhone = currentMerchant.adminMobileNumber ?? currentMerchant.phone;
          if (masterPhone.isNotEmpty) {
            _masterMobileRaw = masterPhone;
            _masterMobile = Formatters.formatMaskedPhone(masterPhone);
          } else {
            _masterMobile = 'Not available';
            _masterMobileRaw = '';
          }

          // Phone number
          _phone = currentMerchant.phone;

          // Business Type from API
          _businessType = currentMerchant.businessType ?? 'Not specified';

          // Category from API
          _category = currentMerchant.category ?? 'Not specified';

          // Manager from API
          _manager = currentMerchant.manager ?? 'Not assigned';

          // Email from API
          _email = currentMerchant.emailId ?? '';

          // Status flags
          _isActive = currentMerchant.isActive;
          _isVerified = currentMerchant.isVerified;

          _isLoading = false;

          debugPrint('');
          debugPrint('✅ BUSINESS DETAIL: Data Loaded from API');
          debugPrint('   Business Name: $_businessName');
          debugPrint('   Address: $_address');
          debugPrint('   Master Mobile: $_masterMobile');
          debugPrint('   Phone: $_phone');
          debugPrint('   Business Type: $_businessType');
          debugPrint('   Category: $_category');
          debugPrint('   Manager: $_manager');
          debugPrint('   Email: $_email');
          debugPrint('   isActive: $_isActive');
          debugPrint('   isVerified: $_isVerified');
          debugPrint('====================================================');
          debugPrint('');
        });
      } else {
        debugPrint('⚠️ Merchant not found in API, using fallback data');
        // Fallback to storage
        final merchantData = await AuthStorage.getMerchantData();
        final phone = await AuthStorage.getPhoneNumber();

        if (mounted) {
          setState(() {
            if (merchantData != null) {
              _businessName = merchantData['businessName']?.toString() ?? widget.businessName;
              _address = merchantData['address']?.toString() ?? widget.address ?? 'No address added';

              String? masterPhone = merchantData['masterMobileNumber']?.toString() ?? phone;
              if (masterPhone != null && masterPhone.isNotEmpty) {
                _masterMobileRaw = masterPhone;
                _masterMobile = Formatters.formatMaskedPhone(masterPhone);
              }
            }
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading merchant data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleItemTap(String title) async {
    debugPrint('✏️ $title tapped');

    if (title == 'Business Name') {
      // Show edit business name dialog
      final newName = await EditBusinessNameDialog.show(
        context: context,
        currentName: _businessName,
      );

      if (newName != null && newName.isNotEmpty && newName != _businessName) {
        debugPrint('✅ New business name entered: $newName');

        // Call controller method to update with merchantId from this screen
        final success = await _shopController.updateMerchantFromScreen(
          businessName: newName,
          merchantId: widget.merchantId,
        );

        if (success) {
          setState(() {
            _businessName = newName;
          });
          await _loadMerchantData();
        }
      }
    } else if (title == 'Master mobile') {
      // ✅ Complete flow using admin-mobile APIs:
      // API 1: PIN → Send OTP to current admin mobile
      // API 2: Verify OTP → Get sessionId
      // API 3: Enter new mobile → Send OTP to new number
      // API 4: Verify new OTP → Complete change

      debugPrint('');
      debugPrint('🔐 ========== MASTER MOBILE CHANGE FLOW ==========');
      debugPrint('📱 Current Master Mobile (masked): $_masterMobile');
      debugPrint('📱 Current Master Mobile (raw): $_masterMobileRaw');

      // Reset controller for fresh flow
      _changeNumberController.reset();
      _changeNumberController.setCurrentNumber(_masterMobileRaw);

      // Prepare for dialog sequence - hide any existing keyboard
      await DialogTransitionHelper.prepareForDialogSequence(context);

      // STEP 1: Use global PIN check - skip if PIN is disabled
      debugPrint('');
      debugPrint('📍 STEP 1: Check PIN and send OTP to current admin mobile...');

      String? pin;
      try {
        final privacyController = Get.find<PrivacySettingController>();
        final result = await privacyController.requirePinIfEnabled(
          context,
          title: 'Enter Security PIN',
          subtitle: 'Enter your 4-digit PIN to change master mobile',
          confirmButtonText: 'Send OTP',
        );

        if (result == null) {
          debugPrint('❌ User cancelled PIN entry or validation failed');
          return;
        }

        pin = result == 'SKIP' ? '' : result;
      } catch (e) {
        // Controller not registered, show PIN dialog as fallback
        debugPrint('⚠️ PrivacySettingController not found, using fallback PIN dialog');
        final pinResult = await PinVerificationDialog.show(
          context: context,
          title: 'Enter Security Pin',
          subtitle: 'Enter your 4-digit pin to get OTP on',
          maskedPhoneNumber: _masterMobile,
          requireOtp: false,
          confirmButtonText: 'Send OTP',
          showWarning: false,
          warningText: 'Once you changed your master mobile you will lose the access to this business. And ownership is going to be transferred to the new number.',
        );

        final pinValue = pinResult?['pin'];
        if (pinResult == null || pinValue == null) {
          debugPrint('❌ User cancelled PIN entry');
          return;
        }
        pin = pinValue;
      }

      debugPrint('✅ PIN verified or skipped');

      // Wait for keyboard to close before API call
      await DialogTransitionHelper.waitForDialogTransition();

      // API 1: Send OTP to current admin mobile
      debugPrint('📡 API 1: Sending OTP to current admin mobile...');
      final otpSentToCurrent = await _changeNumberController.sendOtpToCurrentNumber(pin);

      if (!otpSentToCurrent) {
        debugPrint('❌ API 1 Failed: Could not send OTP to current number');
        return;
      }

      debugPrint('✅ API 1 Success: OTP sent to current admin mobile');

      if (!mounted) return;

      // Wait for smooth transition before showing next dialog
      await DialogTransitionHelper.waitForDialogTransition();

      // STEP 2: Show OTP dialog for current number and call API 2
      debugPrint('');
      debugPrint('📍 STEP 2: Verify OTP received on current admin mobile...');

      final currentOtp = await NewNumberOtpDialog.show(
        context: context,
        newPhoneNumber: _masterMobile,
        title: 'Enter OTP',
        subtitle: 'Enter OTP received on your current admin mobile\n$_masterMobile',
        confirmButtonText: 'Verify',
        warningText: 'Once you changed your master mobile you will lose the access to this business. And ownership is going to be transferred to the new number.',
        onResendOtp: () async {
          debugPrint('🔄 Resending OTP to current admin mobile...');
          return await _changeNumberController.sendOtpToCurrentNumber('');
        },
      );

      if (currentOtp == null) {
        debugPrint('❌ User cancelled current OTP verification');
        return;
      }

      // Wait for keyboard to close before API call
      await DialogTransitionHelper.waitForDialogTransition();

      debugPrint('📡 API 2: Verifying current admin mobile OTP...');
      final currentOtpVerified = await _changeNumberController.verifyCurrentNumberOtp(currentOtp);

      if (!currentOtpVerified) {
        debugPrint('❌ API 2 Failed: Invalid OTP for current number');
        return;
      }

      debugPrint('✅ API 2 Success: OTP verified, session created');
      debugPrint('   Session ID: ${_changeNumberController.sessionId}');

      if (!mounted) return;

      // Wait for smooth transition before showing next dialog
      await DialogTransitionHelper.waitForDialogTransition();

      // STEP 3: Show dialog to enter new mobile number
      debugPrint('');
      debugPrint('📍 STEP 3: Enter new admin mobile number...');

      final newMobile = await MobileNumberDialog.show(
        context: context,
        title: 'Enter New Mobile',
        subtitle: 'Enter the new admin mobile number',
        confirmButtonText: 'Send OTP',
        showWarning: true,
        warningText: 'Once you changed your master mobile you will lose the access to this business. And ownership is going to be transferred to the new number.',
      );

      if (newMobile == null || newMobile.isEmpty) {
        debugPrint('❌ User cancelled or no new mobile provided');
        return;
      }

      debugPrint('✅ New mobile entered: ${newMobile.substring(0, 2)}****${newMobile.substring(newMobile.length - 2)}');

      // Wait for keyboard to close before API call
      await DialogTransitionHelper.waitForDialogTransition();

      // API 3: Send OTP to new mobile number
      debugPrint('📡 API 3: Sending OTP to new mobile number...');
      final otpSentToNew = await _changeNumberController.sendOtpToNewNumber(newMobile);

      if (!otpSentToNew) {
        debugPrint('❌ API 3 Failed: Could not send OTP to new number');
        return;
      }

      debugPrint('✅ API 3 Success: OTP sent to new mobile');

      if (!mounted) return;

      // Wait for smooth transition before showing next dialog
      await DialogTransitionHelper.waitForDialogTransition();

      // STEP 4: Show OTP dialog for new number and call API 4
      debugPrint('');
      debugPrint('📍 STEP 4: Verify OTP received on new mobile...');

      final formattedNewMobile = Formatters.formatPhoneWithCountryCode('+91$newMobile');

      final newNumberOtp = await NewNumberOtpDialog.show(
        context: context,
        newPhoneNumber: formattedNewMobile,
        title: 'Enter OTP',
        subtitle: 'Enter OTP received on your new mobile\n$formattedNewMobile',
        confirmButtonText: 'Confirm',
        warningText: 'Once you changed your master mobile you will lose the access to this business. And ownership is going to be transferred to the new number.',
        onResendOtp: () async {
          debugPrint('🔄 Resending OTP to new mobile...');
          return await _changeNumberController.sendOtpToNewNumber(newMobile);
        },
      );

      if (newNumberOtp == null) {
        debugPrint('❌ User cancelled new number OTP verification');
        return;
      }

      // Wait for keyboard to close before API call
      await DialogTransitionHelper.waitForDialogTransition();

      debugPrint('📡 API 4: Verifying new mobile OTP and completing change...');
      final changeSuccess = await _changeNumberController.verifyNewNumberOtp(newNumberOtp);

      if (changeSuccess) {
        debugPrint('✅ API 4 Success: Master mobile changed successfully!');
        debugPrint('');
        debugPrint('🎉 ========== FLOW COMPLETED SUCCESSFULLY ==========');

        AdvancedErrorService.showSuccess(
          'Master mobile changed! Please login with new number.',
          type: SuccessType.snackbar,
        );

        debugPrint('⏳ Waiting 4 seconds before logout...');
        debugPrint('📱 User should login with new number: $newMobile');

        // Wait 4 seconds before logout
        await Future.delayed(const Duration(seconds: 4));

        // Logout user - ownership transferred to new number
        debugPrint('🔐 Logging out user...');
        await AuthStorage.logout(clearControllers: false);

        // Navigate to select language screen
        if (mounted) {
          debugPrint('🚀 Navigating to Select Language screen...');
          Get.offAllNamed(AppRoutes.selectLanguage);
        }
      } else {
        debugPrint('❌ API 4 Failed: Could not complete master mobile change');
      }

      debugPrint('====================================================');
      debugPrint('');
    } else if (title == 'Address') {
      // Show edit address dialog
      final newAddress = await EditAddressDialog.show(
        context: context,
        currentAddress: _address,
      );

      if (newAddress != null && newAddress.isNotEmpty && newAddress != _address) {
        debugPrint('✅ New address entered: $newAddress');

        // Call controller method to update with merchantId from this screen
        final success = await _shopController.updateMerchantFromScreen(
          address: newAddress,
          merchantId: widget.merchantId,
        );

        if (success) {
          setState(() {
            _address = newAddress;
          });
          await _loadMerchantData();
        }
      }
    } else if (title == 'Business Type') {
      debugPrint('🏢 Business Type tapped - showing bottom sheet');

      final selectedType = await BusinessTypeBottomSheet.show(
        context: context,
        selectedType: _businessType,
      );

      if (selectedType != null && selectedType != _businessType) {
        debugPrint('✅ Business Type selected: $selectedType');

        // Call API to update business type
        final success = await _shopController.updateMerchantFromScreen(
          businessType: selectedType,
          merchantId: widget.merchantId,
        );

        if (success) {
          setState(() {
            _businessType = selectedType;
          });
          await _loadMerchantData();
        }
      }
    } else if (title == 'Category') {
      debugPrint('📁 Category tapped - showing bottom sheet');

      final selectedCategory = await CategoryBottomSheet.show(
        context: context,
        selectedCategory: _category,
      );

      if (selectedCategory != null && selectedCategory != _category) {
        debugPrint('✅ Category selected: $selectedCategory');

        // Call API to update category
        final success = await _shopController.updateMerchantFromScreen(
          category: selectedCategory,
          merchantId: widget.merchantId,
        );

        if (success) {
          setState(() {
            _category = selectedCategory;
          });
          await _loadMerchantData();
        }
      }
    } else if (title == 'Manager') {
      debugPrint('👤 Manager tapped - showing bottom sheet');

      final selectedManager = await ManagerBottomSheet.show(
        context: context,
        selectedManager: _manager,
      );

      if (selectedManager != null && selectedManager != _manager) {
        debugPrint('✅ Manager selected: $selectedManager');

        // Call API to update manager
        final success = await _shopController.updateMerchantFromScreen(
          manager: selectedManager,
          merchantId: widget.merchantId,
        );

        if (success) {
          setState(() {
            _manager = selectedManager;
          });
          await _loadMerchantData();
        }
      }
    } else if (title == 'Deactivate business' || title == 'Activate business') {
      final isActivating = title == 'Activate business';
      final actionText = isActivating ? 'activate' : 'deactivate';
      final actionTextCapitalized = isActivating ? 'Activate' : 'Deactivate';

      debugPrint('🔄 $actionTextCapitalized business tapped - checking PIN status');

      // Warning text based on action
      final warningText = isActivating
          ? 'Once "$_businessName" is activated, you will regain access to all transactions, entries, and related info. These records will also appear in search results again.'
          : 'Once this business is deactivated, you will no longer have access to any transaction, entries, or related info. These records will also not appear in search results. To view or retrieve the data, the business must be reactivated from the Deactivated List in Settings.';

      // Button colors based on action
      final buttonColors = isActivating
          ? [AppColors.red500, AppColors.red500]
          : [AppColors.red500, AppColors.red500];

      // STEP 1: Use global PIN check - skips dialog if PIN is disabled
      final privacyController = Get.find<PrivacySettingController>();
      final pinResult = await privacyController.requirePinIfEnabled(
        context,
        title: 'Enter Security Pin',
        subtitle: 'Enter your 4-digit pin to $actionText "$_businessName"',
        confirmButtonText: 'Confirm',
        confirmGradientColors: buttonColors,
      );

      // null means cancelled or failed
      if (pinResult == null) {
        debugPrint('❌ User cancelled PIN entry or validation failed');
        return;
      }

      // 'SKIP' means PIN is disabled, use empty string
      // Otherwise use the validated PIN
      final securityKey = pinResult == 'SKIP' ? '' : pinResult;
      debugPrint('✅ PIN verified or skipped for $actionText');

      if (!mounted) return;

      // Wait for smooth transition before showing next dialog
      await DialogTransitionHelper.waitForDialogTransition();

      // STEP 2: Show OTP verification dialog
      debugPrint('📍 STEP 2: Showing OTP dialog for master mobile verification...');

      final otp = await NewNumberOtpDialog.show(
        context: context,
        newPhoneNumber: _masterMobile,
        title: 'Enter OTP',
        subtitle: 'Enter secure OTP received on your master mobile number\n$_masterMobile',
        confirmButtonText: 'Confirm',
        warningText: warningText,
        confirmGradientColors: buttonColors,
        confirmTextColor: AppColors.white,
        onResendOtp: () async {
          debugPrint('🔄 Resending OTP for $actionText...');
          return await privacyController.sendOtp();
        },
      );

      if (otp == null) {
        debugPrint('❌ User cancelled OTP verification');
        return;
      }

      debugPrint('✅ OTP verified for $actionText: $otp');

      // STEP 3: Call controller to activate/deactivate business
      debugPrint('📡 STEP 3: Calling API to $actionText business...');

      final success = await _shopController.updateMerchantStatus(
        merchantId: widget.merchantId,
        isActive: isActivating, // true for activate, false for deactivate
        securityKey: securityKey,
      );

      if (success && mounted) {
        debugPrint('✅ Business ${actionText}d successfully');
        // Navigate back after status change
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } else {
      debugPrint('$title tapped (no action)');
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
                _businessName,
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
                strokeWidth: 1,
              ),
            )
          : RefreshIndicator(
              color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
              backgroundColor: isDark ? AppColors.containerDark : AppColorsLight.white,
              onRefresh: _loadMerchantData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildBusinessDetails(responsive, isDark),
                    SizedBox(height: responsive.hp(10)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBusinessDetails(AdvancedResponsiveHelper responsive, bool isDark) {
    final businessDetails = [
      {
        'icon': AppIcons.documentIc,
        'title': 'Business Name',
        'subtitle': _businessName.isNotEmpty ? _businessName : 'Not provided',
      },
      {
        'icon': AppIcons.mobileIc,
        'title': 'Master mobile',
        'subtitle': _masterMobile,
      },
      {
        'icon': AppIcons.locationIc,
        'title': 'Address',
        'subtitle': _address.isNotEmpty ? _address : 'No address added',
      },
      {
        'icon': AppIcons.shopIc,
        'title': 'Business Type',
        'subtitle': _businessType,
      },
      {
        'icon': AppIcons.shopIc,
        'title': 'Category',
        'subtitle': _category,
      },
      {
        'icon': AppIcons.personIc,
        'title': 'Manager',
        'subtitle': _manager,
      },
      {
        'icon': _isActive ? AppIcons.deleteIc : AppIcons.deleteIc,
        'title': _isActive ? 'Deactivate business' : 'Activate business',
        'subtitle': _isActive
            ? 'This action leads to archive entries'
            : 'Restore this business to active state',
      },
    ];

    return Padding(
      padding: EdgeInsets.all(responsive.wp(3)),
      child: Column(
        children: List.generate(businessDetails.length, (index) {
          final detail = businessDetails[index];
          return Column(
            children: [
              ListItemWidget(
                backgroundColor: isDark ? AppColors.containerLight : AppColorsLight.containerLight,
                title: detail['title'] as String,
                subtitle: detail['subtitle'] as String,
                leadingIcon: detail['icon'] as String,
                trailingIcon: AppIcons.arrowRightIc,
                onTap: () => _handleItemTap(detail['title'] as String),
                showBorder: false,
              ),
              if (index < businessDetails.length - 1)
                SizedBox(height: responsive.hp(0.8)),
            ],
          );
        }),
      ),
    );
  }
}
