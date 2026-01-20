import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/constants/app_string.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_text.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../../../buttons/row_app_bar.dart';
import '../custom_single_border_color.dart';
import '../dialogs/pin_verification_dialog.dart';
import '../dialogs/image_preview_dialog.dart';
import '../../routes/app_routes.dart';
import '../../../core/api/ledger_transaction_api.dart';
import '../../../core/services/error_service.dart';
import '../../../core/untils/error_types.dart';
import '../../../controllers/ledger_controller.dart';
import '../../../controllers/privacy_setting_controller.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/transaction_detail_model.dart';

class TransactionDetailBottomSheet extends StatefulWidget {
  final int? transactionId;
  final int? ledgerId;
  final String partyName;
  final String location;
  final double amount;
  final String transactionDate; // ISO date string for formatting
  final String entryDate; // ISO date string for formatting
  final String? rawTransactionDate; // Original ISO date for API calls
  final String? remarks;
  final bool isPositive;
  final double? closingBalance; // Closing balance after this transaction
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionDetailBottomSheet({
    Key? key,
    this.transactionId,
    this.ledgerId,
    required this.partyName,
    required this.location,
    required this.amount,
    required this.transactionDate,
    required this.entryDate,
    this.rawTransactionDate,
    this.remarks,
    required this.isPositive,
    this.closingBalance,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    int? transactionId,
    int? ledgerId,
    required String partyName,
    required String location,
    required double amount,
    required String transactionDate,
    required String entryDate,
    String? rawTransactionDate,
    String? remarks,
    required bool isPositive,
    double? closingBalance,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailBottomSheet(
        transactionId: transactionId,
        ledgerId: ledgerId,
        partyName: partyName,
        location: location,
        amount: amount,
        transactionDate: transactionDate,
        entryDate: entryDate,
        rawTransactionDate: rawTransactionDate,
        remarks: remarks,
        isPositive: isPositive,
        closingBalance: closingBalance,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }

  @override
  State<TransactionDetailBottomSheet> createState() => _TransactionDetailBottomSheetState();
}

class _TransactionDetailBottomSheetState extends State<TransactionDetailBottomSheet> {
  bool _isLoading = false;
  TransactionDetailModel? _transactionDetail;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTransactionDetails();
  }

  Future<void> _fetchTransactionDetails() async {
    if (widget.transactionId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final api = LedgerTransactionApi();
      final detail = await api.getTransactionDetails(
        transactionId: widget.transactionId!,
      );
      setState(() {
        _transactionDetail = detail;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error fetching transaction details: $e');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // Get initials from name
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'U';
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use API data if available, otherwise fallback to widget parameters
    final displayAmount = _transactionDetail?.amount ?? widget.amount;
    final displayPartyName = _transactionDetail?.customerName ?? widget.partyName;
    final displayRemarks = _transactionDetail?.description ?? widget.remarks;
    final displayTransactionDate = _transactionDetail?.transactionDate ?? widget.rawTransactionDate ?? widget.transactionDate;
    final displayEntryDate = _transactionDetail?.updatedAt ?? widget.entryDate;
    final displayClosingBalance = _transactionDetail?.currentBalance ?? widget.closingBalance;
    final displayIsPositive = _transactionDetail?.isInTransaction ?? widget.isPositive;
    final hasHistory = _transactionDetail?.hasHistory ?? false;
    final historyItems = _transactionDetail?.transactionHistory ?? [];
    final attachments = _transactionDetail?.attachments ?? [];

    return Stack(
      children: [
        Container(
          constraints: BoxConstraints(
            maxHeight: responsive.hp(85),
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.overlay : AppColorsLight.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(responsive.borderRadiusExtraLarge),
              topRight: Radius.circular(responsive.borderRadiusExtraLarge),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Transaction Type Indicator
              SizedBox(height: responsive.hp(1.5)),
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: responsive.wp(3)),
                padding: EdgeInsets.symmetric(
                  vertical: responsive.hp(1.0),
                    horizontal: responsive.wp(2)
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.black : AppColorsLight.gradientColor2,
                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: responsive.hp(1.5),horizontal: responsive.wp(2)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: displayIsPositive
                          ? [
                              AppColors.splaceSecondary1,
                              AppColors.splaceSecondary2,
                            ]
                          : [
                              AppColors.red800,
                              AppColors.red500,
                            ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        displayIsPositive ? AppIcons.arrowInIc : AppIcons.arrowOutIc,
                        width: responsive.iconSizeMedium,
                        height: responsive.iconSizeMedium,
                        colorFilter: ColorFilter.mode(
                          displayIsPositive
                              ? (isDark ? AppColors.white : AppColorsLight.white)
                              : AppColors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: responsive.wp(2)),
                      AppText.searchbar1(
                        displayIsPositive ? 'In transaction entry' : 'Out transaction entry',
                        color: displayIsPositive
                            ? (isDark ? AppColors.white : AppColorsLight.white)
                            : AppColors.textDisabled,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ),

              // Scrollable content (no loading indicator - show content immediately)
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(responsive.wp(6)),
                      child: Column(
                        children: [
                          SizedBox(height: responsive.hp(1)),
                          // Avatar and Name
                          Container(
                            width: responsive.wp(19),
                            height: responsive.wp(19),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [
                                        AppColors.splaceSecondary1,
                                        AppColors.splaceSecondary2,
                                      ]
                                    : [
                                  AppColors.splaceSecondary1,
                                  AppColors.splaceSecondary2,
                                      ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Center(
                              child: AppText.displayMedium(
                                _getInitials(displayPartyName),
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(height: responsive.hp(0.5)),

                          // Party Name
                          AppText.searchbar2(
                            displayPartyName,
                            color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                            fontWeight: FontWeight.w600,
                            maxLines: 1,
                          ),
                          SizedBox(height: responsive.hp(0.2)),

                          // Location (if available)
                          if (widget.location.isNotEmpty) ...[
                            AppText.headlineLarge1(
                              widget.location,
                              color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                              fontWeight: FontWeight.w400,
                              maxLines: 1,
                            ),
                            SizedBox(height: responsive.hp(0.2)),
                          ],

                          SizedBox(height: responsive.hp(2)),

                          // Amount with Currency Icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: responsive.hp(1.5)),
                                child: SvgPicture.asset(
                                  AppIcons.vectoeIc3,
                                  width: responsive.iconSizeLarge,
                                  height: responsive.iconSizeLarge,
                                  colorFilter: ColorFilter.mode(
                                    isDark ? AppColors.white : AppColorsLight.textPrimary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              SizedBox(width: responsive.wp(1)),
                              AppText.displayLarge(
                                NumberFormat('#,##,##0.00', 'en_IN').format(displayAmount),
                                color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                                fontWeight: FontWeight.bold,
                                maxLines: 1,
                                minFontSize: 15,
                                letterSpacing: 1.2,
                              ),
                            ],
                          ),
                          SizedBox(height: responsive.hp(0.9)),

                          // Transaction Date (formatted: d MMM yyyy, HH:mm)
                          AppText.searchbar1(
                            'Transaction on : ${Formatters.formatStringToDateAndTime(displayTransactionDate)}',
                            color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          SizedBox(height: responsive.hp(2.6)),

                          // Entry Date (formatted: d MMM yyyy, HH:mm)
                          AppText.searchbar1(
                            'Entry on : ${Formatters.formatStringToDateAndTime(displayEntryDate)}',
                            color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          SizedBox(height: responsive.hp(3)),

                          // Remarks (if available)
                          if (displayRemarks != null && displayRemarks.isNotEmpty) ...[
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                horizontal: responsive.wp(3),
                                vertical: responsive.hp(1.5),
                              ),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.black.withOpacity(0.5)
                                    : AppColorsLight.gradientColor2,
                                borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                              ),
                              child: AppText.searchbar1(
                                displayRemarks,
                                color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                                fontWeight: FontWeight.w400,
                                textAlign: TextAlign.center,
                                maxLines: 3,
                              ),
                            ),
                            SizedBox(height: responsive.hp(2)),
                          ],

                          // Attachments Section
                          if (attachments.isNotEmpty) ...[
                            _buildAttachmentsSection(context, responsive, isDark, attachments),
                            SizedBox(height: responsive.hp(2)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

              // Bottom Action Bar - Fixed at bottom
              BottomActionBar(
                  gradientColors: [
                    isDark ? AppColors.containerDark : AppColorsLight.white,
                    isDark ? AppColors.containerLight : AppColorsLight.white,
                  ],
                  showBorder: true,
                  primaryButtonText: 'Edit',
                  onPrimaryPressed: () => _handleEdit(context),
                  secondaryButtonText: 'Delete',
                  secondaryButtonGradientColors: isDark
                      ? [
                          AppColors.red800,
                          AppColors.red500,
                        ]
                      : [
                    AppColors.red800,
                    AppColors.red500,
                        ],
                  buttonSpacing: responsive.spacing(16),
                  containerPadding: EdgeInsets.symmetric(
                    horizontal: responsive.spacing(16),
                    vertical: responsive.spacing(16),
                  ),
                  onSecondaryPressed: () => _handleDelete(context),
                ),
            ],
          ),
        ),
        Positioned.fill(
          child: CustomSingleBorderWidget(
            position: BorderPosition.top,
            borderWidth: isDark ? 1.0 : 2.0,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
        ),
      ]
    );
  }

  Widget _buildAttachmentsSection(
    BuildContext context,
    AdvancedResponsiveHelper responsive,
    bool isDark,
    List<TransactionAttachment> attachments,
  ) {
    return SizedBox(
      height: responsive.hp(10),
      child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: attachments.length,
            itemBuilder: (context, index) {
              final attachment = attachments[index];
              return GestureDetector(
                onTap: () {
                  // Get all attachment URLs for navigation
                  final imageUrls = attachments
                      .map((a) => a.presignedUrl)
                      .where((url) => url.isNotEmpty)
                      .toList();

                  ImagePreviewDialog.show(
                    context: context,
                    imagePaths: imageUrls,
                    initialIndex: index,
                    isNetworkImages: true,
                  );
                },
                child: Container(
                  width: responsive.wp(20),
                  margin: EdgeInsets.only(right: responsive.wp(2)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                    border: Border.all(
                      color: isDark ? AppColors.containerLight : AppColorsLight.containerLight,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                    child: Image.network(
                      attachment.presignedUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.broken_image,
                            color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
        ),
    );
  }

  Widget _buildHistorySection(
    BuildContext context,
    AdvancedResponsiveHelper responsive,
    bool isDark,
    List<TransactionHistoryItem> historyItems,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history,
              color: isDark ? AppColors.white : AppColorsLight.textPrimary,
              size: responsive.iconSizeSmall,
            ),
            SizedBox(width: responsive.wp(2)),
            AppText.searchbar1(
              'Transaction History (${historyItems.length})',
              color: isDark ? AppColors.white : AppColorsLight.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
        SizedBox(height: responsive.hp(1.5)),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: historyItems.length,
          itemBuilder: (context, index) {
            final item = historyItems[index];
            final isLatest = index == historyItems.length - 1;
            return Container(
              margin: EdgeInsets.only(bottom: responsive.hp(1)),
              padding: EdgeInsets.all(responsive.wp(3)),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.black.withOpacity(0.3)
                    : AppColorsLight.containerLight.withOpacity(0.3),
                borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                border: isLatest
                    ? Border.all(
                        color: isDark ? AppColors.splaceSecondary1 : AppColorsLight.gradientColor1,
                        width: 1,
                      )
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: responsive.wp(2),
                              vertical: responsive.hp(0.3),
                            ),
                            decoration: BoxDecoration(
                              color: isLatest
                                  ? (isDark ? AppColors.splaceSecondary1 : AppColorsLight.gradientColor1)
                                  : (isDark ? AppColors.containerLight : AppColorsLight.containerLight),
                              borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                            ),
                            child: AppText.headlineLarge1(
                              'V${item.version}',
                              color: isLatest
                                  ? AppColors.white
                                  : (isDark ? AppColors.textDisabled : AppColorsLight.textSecondary),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isLatest) ...[
                            SizedBox(width: responsive.wp(2)),
                            AppText.headlineLarge1(
                              '(Current)',
                              color: isDark ? AppColors.splaceSecondary1 : AppColorsLight.gradientColor1,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          SvgPicture.asset(
                            AppIcons.vectoeIc3,
                            width: responsive.iconSizeSmall - 4,
                            height: responsive.iconSizeSmall - 4,
                            colorFilter: ColorFilter.mode(
                              isDark ? AppColors.white : AppColorsLight.textPrimary,
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: responsive.wp(0.5)),
                          AppText.searchbar1(
                            NumberFormat('#,##,##0.00', 'en_IN').format(item.transactionAmount),
                            color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.hp(0.8)),
                  if (item.description != null && item.description!.isNotEmpty) ...[
                    AppText.headlineLarge1(
                      item.description!,
                      color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                      fontWeight: FontWeight.w400,
                      maxLines: 2,
                    ),
                    SizedBox(height: responsive.hp(0.5)),
                  ],
                  AppText.headlineLarge1(
                    'Updated: ${Formatters.formatStringToDateAndTime(item.updatedAt ?? '')}',
                    color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _handleEdit(BuildContext context) async {
    // Use global PIN check - skip if PIN is disabled
    String? pin;
    try {
      final privacyController = Get.find<PrivacySettingController>();
      final result = await privacyController.requirePinIfEnabled(
        context,
        title: 'Enter Security PIN',
        subtitle: 'Enter your 4-digit PIN to edit transaction',
      );

      if (result == null) {
        return; // User cancelled or PIN validation failed
      }

      pin = result == 'SKIP' ? '' : result;
    } catch (e) {
      // Controller not registered, show PIN dialog as fallback
      debugPrint('⚠️ PrivacySettingController not found, using fallback PIN dialog');
      final dialogResult = await PinVerificationDialog.show(
        context: context,
        title: 'Enter Security Pin',
        subtitle: 'Enter your 4-digit pin to edit transaction',
        requireOtp: false,
      );
      if (dialogResult == null || dialogResult['pin'] == null) {
        return;
      }
      pin = dialogResult['pin'];
    }

    // PIN verified or skipped, proceed with edit
    // Close bottom sheet first
    Navigator.pop(context);

    // Use API data if available
    final editTransactionId = _transactionDetail?.id ?? widget.transactionId;
    final editLedgerId = _transactionDetail?.ledgerId ?? widget.ledgerId;
    final editPartyName = _transactionDetail?.customerName ?? widget.partyName;
    final editAmount = _transactionDetail?.amount ?? widget.amount;
    final editIsPositive = _transactionDetail?.isInTransaction ?? widget.isPositive;
    final editTransactionDate = _transactionDetail?.transactionDate ?? widget.rawTransactionDate ?? widget.transactionDate;
    final editRemarks = _transactionDetail?.description ?? widget.remarks;

    // Navigate to Add Transaction screen in edit mode
    final navigationResult = await Get.toNamed(
      AppRoutes.addTransaction,
      arguments: {
        'transactionId': editTransactionId,
        'ledgerId': editLedgerId,
        'customerName': editPartyName,
        'customerLocation': widget.location,
        'amount': editAmount,
        'transactionType': editIsPositive ? 'IN' : 'OUT',
        'transactionDate': editTransactionDate,
        'comments': editRemarks,
      },
    );

    // If update was successful, call onEdit callback to refresh data
    if (navigationResult == true) {
      debugPrint('✅ Transaction updated successfully - triggering refresh');
      // Call onEdit callback to refresh LedgerDetailController
      widget.onEdit?.call();

      // Update ledger's last activity date locally (fixes date not updating issue)
      try {
        final ledgerController = Get.find<LedgerController>();
        final targetLedgerId = editLedgerId ?? widget.ledgerId;
        if (targetLedgerId != null) {
          debugPrint('🔄 Updating ledger $targetLedgerId last activity date...');
          ledgerController.updateLedgerLastActivity(targetLedgerId);
        }
        debugPrint('✅ LedgerController updated successfully');
      } catch (e) {
        debugPrint('⚠️ LedgerController not found, skipping update');
      }
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final deleteTransactionId = _transactionDetail?.id ?? widget.transactionId;

    // Check if transaction ID exists
    if (deleteTransactionId == null) {
      AdvancedErrorService.showError(
        'Transaction ID not found. Cannot delete.',
        severity: ErrorSeverity.high,
        category: ErrorCategory.validation,
      );
      return;
    }

    // Use global PIN check - skip if PIN is disabled
    String? pin;
    try {
      final privacyController = Get.find<PrivacySettingController>();
      final result = await privacyController.requirePinIfEnabled(
        context,
        title: 'Enter Security PIN',
        subtitle: 'Enter your 4-digit PIN to delete transaction',
        confirmGradientColors: [AppColors.red800, AppColors.red500],
      );

      if (result == null) {
        return; // User cancelled or PIN validation failed
      }

      pin = result == 'SKIP' ? '' : result;
    } catch (e) {
      // Controller not registered, show PIN dialog as fallback
      debugPrint('⚠️ PrivacySettingController not found, using fallback PIN dialog');
      final dialogResult = await PinVerificationDialog.show(
        context: context,
        title: 'Enter Security Pin',
        subtitle: 'Enter your 4-digit pin to delete transaction',
        requireOtp: false,
        confirmGradientColors: [AppColors.red800, AppColors.red500],
        confirmTextColor: AppColors.white,
      );
      if (dialogResult == null || dialogResult['pin'] == null) {
        return;
      }
      pin = dialogResult['pin'];
    }

    // PIN verified or skipped, proceed with deletion
    try {
      // Call Delete API
      final api = LedgerTransactionApi();
      final response = await api.deleteTransaction(
        transactionId: deleteTransactionId,
        securityKey: pin!,
      );

      // Close bottom sheet
      Navigator.pop(context);

      // Show success message
      AdvancedErrorService.showSuccess(
        response.message,
        type: SuccessType.snackbar,
        customDuration: Duration(seconds: 2),
      );

      debugPrint('✅ Transaction deleted successfully - triggering refresh');

      // Call onDelete callback to refresh LedgerDetailController
      widget.onDelete?.call();

      // Update ledger's last activity date locally (fixes date not updating issue)
      try {
        final ledgerController = Get.find<LedgerController>();
        final targetLedgerId = _transactionDetail?.ledgerId ?? widget.ledgerId;
        if (targetLedgerId != null) {
          debugPrint('🔄 Updating ledger $targetLedgerId last activity date after delete...');
          ledgerController.updateLedgerLastActivity(targetLedgerId);
        }
        debugPrint('✅ LedgerController updated successfully');
      } catch (e) {
        debugPrint('⚠️ LedgerController not found, skipping update');
      }
    } catch (e) {
      debugPrint('❌ Delete Transaction Error: $e');

      // Show error message
      AdvancedErrorService.showError(
        e.toString().replaceAll('Exception: ', ''),
        severity: ErrorSeverity.high,
        category: ErrorCategory.network,
        customDuration: Duration(seconds: 3),
      );
    }
  }
}
