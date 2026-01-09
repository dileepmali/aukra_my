import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/constants/app_icons.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_text.dart';
import '../../core/api/auth_storage.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/responsive_layout/padding_navigation.dart';
import '../../core/utils/formatters.dart';
import '../../controllers/shop_detail_controller.dart';
import '../widgets/custom_app_bar/custom_app_bar.dart';
import '../widgets/custom_app_bar/model/app_bar_config.dart';
import '../widgets/list_item_widget.dart';
import '../widgets/dialogs/edit_business_name_dialog.dart';
import '../widgets/dialogs/edit_address_dialog.dart';
import '../widgets/dialogs/pin_verification_dialog.dart';
import '../widgets/dialogs/new_number_otp_dialog.dart';
import '../widgets/bottom_sheets/business_type_bottom_sheet.dart';
import '../widgets/bottom_sheets/category_bottom_sheet.dart';
import '../widgets/bottom_sheets/manager_bottom_sheet.dart';

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
  String _masterMobileRaw = ''; // Store unmasked number for dialog
  String _businessType = 'Retail Store';
  String _category = 'General';
  String _manager = 'Manager name';
  final ShopDetailController _shopController = Get.put(ShopDetailController());

  @override
  void initState() {
    super.initState();
    _businessName = widget.businessName;
    _address = widget.address ?? 'Business address will be shown here';
    _loadMerchantData();
  }

  Future<void> _loadMerchantData() async {
    try {
      final merchantData = await AuthStorage.getMerchantData();
      final phone = await AuthStorage.getPhoneNumber();

      if (merchantData != null && mounted) {
        setState(() {
          _businessName = merchantData['businessName']?.toString() ?? widget.businessName;
          _address = merchantData['address']?.toString() ?? widget.address ?? 'Business address will be shown here';

          // ✅ Load master mobile number from storage
          String? masterPhone = merchantData['masterMobileNumber']?.toString() ?? phone;

          if (masterPhone != null && masterPhone.isNotEmpty) {
            _masterMobileRaw = masterPhone; // Store raw number
            // ✅ Use Formatters to mask the phone number
            _masterMobile = Formatters.formatMaskedPhone(masterPhone);
          } else {
            _masterMobile = 'Not available';
            _masterMobileRaw = '';
          }

          debugPrint('🏢 ========== BUSINESS DETAIL DATA LOADED ==========');
          debugPrint('   Business Name: $_businessName');
          debugPrint('   Address: $_address');
          debugPrint('   Master Mobile Raw: $_masterMobileRaw');
          debugPrint('   Master Mobile Masked: $_masterMobile');
          debugPrint('====================================================');
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading merchant data: $e');
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

        // Call controller method to update
        final success = await _shopController.updateMerchantFromScreen(
          businessName: newName,
        );

        if (success) {
          setState(() {
            _businessName = newName;
          });
          await _loadMerchantData();
        }
      }
    } else if (title == 'Master mobile') {
      // ✅ Complete flow: PIN → OTP (old) → New Number → OTP (new) → Update
      debugPrint('');
      debugPrint('🔐 ========== MASTER MOBILE CHANGE FLOW ==========');
      debugPrint('📱 Current Master Mobile (masked): $_masterMobile');
      debugPrint('📱 Current Master Mobile (raw): $_masterMobileRaw');

      // STEP 1: Show PIN verification dialog (NO WARNING)
      debugPrint('📍 STEP 1: Showing PIN verification dialog...');
      final pinResult = await PinVerificationDialog.show(
        context: context,
        title: 'Enter Security Pin',
        subtitle: 'Enter your 4-digit pin to get OTP on',
        maskedPhoneNumber: _masterMobile,
        requireOtp: true,
        confirmButtonText: 'Send OTP',
        showWarning: false, // ✅ NO warning in first dialog
        warningText: 'Once you changed your master mobile you will lose the access to this business. And ownership is going to be transferred to the new number.',
      );

      if (pinResult == null) {
        debugPrint('❌ User cancelled PIN verification');
        return;
      }

      debugPrint('✅ STEP 1-3 Complete: PIN & OTP verified, new mobile entered');
      debugPrint('   PIN: ${pinResult['pin']}');
      debugPrint('   OTP: ${pinResult['otp']}');
      debugPrint('   New Mobile: ${pinResult['mobile']}');

      final newMobile = pinResult['mobile'];
      if (newMobile == null || newMobile.isEmpty) {
        debugPrint('❌ No new mobile number provided');
        return;
      }

      debugPrint('');
      debugPrint('📍 STEP 4: Showing OTP verification for new number...');
      debugPrint('   New Number: $newMobile');

      // Format new number for display
      final formattedNewMobile = Formatters.formatPhoneWithCountryCode('+91$newMobile');

      if (!mounted) return;

      final newNumberOtp = await NewNumberOtpDialog.show(
        context: context,
        newPhoneNumber: formattedNewMobile,
        title: 'Enter OTP',
        subtitle: 'Enter secure pin received on your mobile number\n$formattedNewMobile',
        confirmButtonText: 'Confirm',
        warningText: 'Once you changed your master mobile you will lose the access to this business. And ownership is going to be transferred to the new number.',
      );

      if (newNumberOtp == null) {
        debugPrint('❌ User cancelled new number OTP verification');
        return;
      }

      debugPrint('✅ STEP 4 Complete: New number OTP verified');
      debugPrint('   OTP: $newNumberOtp');

      // STEP 5: Call PUT API to update master mobile
      debugPrint('');
      debugPrint('📍 STEP 5: Updating master mobile via PUT API...');

      final success = await _updateMasterMobile(newMobile);

      if (success) {
        debugPrint('✅ STEP 5 Complete: Master mobile updated successfully');
        debugPrint('');
        debugPrint('🎉 ========== FLOW COMPLETED SUCCESSFULLY ==========');

        await _loadMerchantData();
      } else {
        debugPrint('❌ STEP 5 Failed: Could not update master mobile');
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

        final success = await _shopController.updateMerchantFromScreen(
          address: newAddress,
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
        setState(() {
          _businessType = selectedType;
        });
      }
    } else if (title == 'Category') {
      debugPrint('📁 Category tapped - showing bottom sheet');

      final selectedCategory = await CategoryBottomSheet.show(
        context: context,
        selectedCategory: _category,
      );

      if (selectedCategory != null && selectedCategory != _category) {
        debugPrint('✅ Category selected: $selectedCategory');
        setState(() {
          _category = selectedCategory;
        });
      }
    } else if (title == 'Manager') {
      debugPrint('👤 Manager tapped - showing bottom sheet');

      final selectedManager = await ManagerBottomSheet.show(
        context: context,
        selectedManager: _manager,
      );

      if (selectedManager != null && selectedManager != _manager) {
        debugPrint('✅ Manager selected: $selectedManager');
        setState(() {
          _manager = selectedManager;
        });
      }
    } else {
      debugPrint('$title tapped (no action)');
    }
  }

  Future<bool> _updateMasterMobile(String newMasterMobile) async {
    try {
      debugPrint('🔄 Updating master mobile number...');
      debugPrint('   New Master Mobile: $newMasterMobile');

      final merchantData = await AuthStorage.getMerchantData();
      if (merchantData == null) {
        debugPrint('❌ No merchant data found');
        return false;
      }

      await AuthStorage.saveMasterMobileNumber(newMasterMobile);
      debugPrint('✅ Master mobile saved to storage');

      // TODO: Call PUT API to update masterMobileNumber on backend
      // await _shopController.updateMerchantFromScreen(masterMobileNumber: newMasterMobile)

      return true;
    } catch (e) {
      debugPrint('❌ Error updating master mobile: $e');
      return false;
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
              AppText.custom(
                _businessName,
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
            _buildBusinessDetails(responsive, isDark),
            SizedBox(height: responsive.hp(10)),
          ],
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
        'subtitle': _address,
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
        'icon': AppIcons.deleteIc,
        'title': 'Deactivate business',
        'subtitle': 'This action leads to archive entries',
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
