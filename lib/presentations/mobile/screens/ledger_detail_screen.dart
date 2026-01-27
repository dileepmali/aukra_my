import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/themes/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/balance_helper.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_text.dart';
import '../../../controllers/ledger_detail_controller.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../../../core/services/error_service.dart';
import '../../../core/untils/error_types.dart';
import '../../widgets/custom_app_bar/custom_app_bar.dart';
import '../../widgets/custom_app_bar/model/app_bar_config.dart';
import '../../widgets/list_item_widget.dart';
import '../../routes/app_routes.dart';
import '../../widgets/bottom_sheets/transaction_detail_bottom_sheet.dart';
import '../../widgets/bottom_sheets/action_bottom_sheet.dart';
import '../../widgets/custom_single_border_color.dart';

class LedgerDetailScreen extends GetView<LedgerDetailController> {
  const LedgerDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor:
          isDark ? AppColors.overlay : AppColorsLight.scaffoldBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(responsive.hp(10)),
        child: Stack(
          children: [
            Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        AppColors.containerDark,
                        AppColors.containerLight,
                      ]
                    : [
                        AppColorsLight.background,
                        AppColorsLight.background,
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: responsive.wp(3),vertical: responsive.hp(2)),
                child: Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.arrow_back,
                        color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                        size: responsive.iconSizeLarge,
                      ),
                    ),
                    SizedBox(width: responsive.wp(3)),

                    // CircularAvatar with name and details - Clickable to open Dashboard
                    Obx(() {
                      final detail = controller.ledgerDetail.value;
                      final name = detail?.partyName ?? 'Ledger Individual';
                      final mobile = detail?.mobileNumber ?? '';
                      // Use area field directly from API response
                      final area = detail?.area ?? '';

                      // Debug: Check area value
                      debugPrint('📍 AppBar - Mobile: $mobile, Area: $area');

                      // Get initials from name
                      String getInitials(String name) {
                        final parts = name.trim().split(' ');
                        if (parts.isEmpty) return 'L';
                        if (parts.length == 1) {
                          return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'L';
                        }
                        return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
                      }

                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (detail != null) {
                              debugPrint('🎯 AppBar clicked - Opening Ledger Dashboard');
                              Get.toNamed(
                                AppRoutes.ledgerDashboard,
                                arguments: {
                                  'ledgerId': controller.ledgerId,
                                  'partyName': detail.partyName,
                                  'partyType': detail.partyType,
                                  'creditAmount': detail.currentBalance.abs(),
                                  'mobileNumber': detail.mobileNumber,
                                },
                              );
                            }
                          },
                          child: Row(
                            children: [
                              // CircularAvatar with gradient
                              Container(
                              width: responsive.wp(11),
                              height: responsive.wp(11),
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
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: AppText.searchbar1(
                                  getInitials(name),
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: responsive.wp(3)),
                
                            // Name, Mobile, Address
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Name (Title)
                                  AppText.searchbar(
                                    name,
                                    color: isDark
                                        ? AppColors.white
                                        : AppColorsLight.textPrimary,
                                    fontWeight: FontWeight.w400,
                                    maxLines: 1,
                                    minFontSize: 10,
                                  ),
                                  SizedBox(height: responsive.hp(0.2)),
                
                                  // Mobile Number + Area (Subtitle)
                                  AppText.bodyLarge(
                                    [
                                      if (mobile.isNotEmpty) Formatters.formatPhoneWithCountryCode(mobile),
                                      if (area.isNotEmpty) area,
                                    ].join(' • '),
                                    color: isDark
                                        ? AppColors.textDisabled
                                        : AppColorsLight.textSecondary,
                                    fontWeight: FontWeight.w400,
                                    maxLines: 1,
                                    minFontSize: 10,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        )
                      );
                    }),
                
                    SizedBox(width: responsive.wp(2)),
                
                    // Action buttons
                    _buildIconButton(
                      context,
                      AppIcons.notificationIc,
                      () {
                        debugPrint('Notifications tapped');
                      },
                      responsive,
                      isDark,
                    ),
                    SizedBox(width: responsive.wp(2)),
                    _buildIconButton(
                      context,
                      AppIcons.reminderIc,
                      () {
                        debugPrint('Share tapped');
                      },
                      responsive,
                      isDark,
                    ),
                    SizedBox(width: responsive.wp(2)),
                    _buildIconButton(
                      context,
                      AppIcons.whatsappIc,
                      () {
                        debugPrint('Call tapped');
                      },
                      responsive,
                      isDark,
                    ),
                    SizedBox(width: responsive.wp(2)),
                    GestureDetector(
                      onTap: () {
                        debugPrint('More options tapped');
                        final partyName = controller.ledgerDetail.value?.partyName;
                        ActionBottomSheet.show(
                          context: context,
                          partyName: partyName,
                          onReminder: () {
                            debugPrint('Reminder tapped');
                          },
                          onCall: () {
                            debugPrint('Call tapped');
                          },
                          onWhatsappReminder: () {
                            debugPrint('Whatsapp reminder tapped');
                          },
                          onDeactivateConfirmed: (pin) async {
                            final partyName = controller.ledgerDetail.value?.partyName ?? 'Ledger';
                            debugPrint('🔒 Deactivate confirmed with PIN: $pin');

                            // Call API to deactivate ledger
                            final success = await controller.deactivateLedger(pin);

                            if (success) {
                              // Show success message using AdvancedErrorService
                              AdvancedErrorService.showSuccess(
                                '$partyName is deactivated',
                                type: SuccessType.snackbar,
                              );

                              // Go back to previous screen (ledger list)
                              Get.back();
                            }
                            // Note: Error is already shown by controller, no need to show again
                          },
                        );
                      },
                      child: Icon(
                        Icons.more_vert,
                        color: isDark ? AppColors.white : AppColorsLight.iconPrimary,
                        size: responsive.iconSizeLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ],
                          ),
          ),
            Positioned.fill(child: CustomSingleBorderWidget(position: BorderPosition.bottom))

          ]
        ),
      ),
      // UI always visible - no loading indicator hiding the entire screen
      body: Column(
        children: [
          // Fixed Closing Balance Card - Does NOT scroll - Clickable to open Dashboard
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: isDark
                      ? LinearGradient(
                          colors: [
                            AppColors.black,
                            AppColors.black
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [
                            AppColorsLight.gradientColor1,
                            AppColorsLight.gradientColor2
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                ),
                child: _buildBalanceCard(controller, responsive, isDark),
              ),
              Positioned.fill(
                child: CustomSingleBorderWidget(
                  position: BorderPosition.bottom,
                ),
              ),
            ],
          ),

          // Scrollable Transaction List - ONLY this scrolls
          Expanded(
            child: _buildTransactionsList(controller, responsive, isDark),
          ),
        ],
      ),
      floatingActionButton: _buildAddEntryButton(responsive, isDark),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildIconButton(
    BuildContext context,
    String iconPath,
    VoidCallback onTap,
    AdvancedResponsiveHelper responsive,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        iconPath,
        width: responsive.iconSizeLarge,
        height: responsive.iconSizeLarge,
        colorFilter: ColorFilter.mode(
          isDark ? AppColors.white : AppColorsLight.iconPrimary,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  Widget _buildBalanceCard(
    LedgerDetailController controller,
    AdvancedResponsiveHelper responsive,
    bool isDark,
  ) {
    return Container(
      margin: EdgeInsets.all(responsive.wp(4)),
      padding: EdgeInsets.all(responsive.wp(4)),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                colors: [AppColors.containerDark, AppColors.containerLight],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
              )
            : LinearGradient(
                colors: [
                  AppColorsLight.white,
                  AppColorsLight.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
        borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
      ),
      child: Obx(() {
        final detail = controller.ledgerDetail.value;

        // Use backend's current balance directly (default to 0 if not loaded)
        final balance = detail?.currentBalance ?? 0.0;

        // ✅ FIX: Check if balance is effectively zero (handles floating point issues)
        final isZeroBalance = balance.abs() < 0.01;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Wrap in Expanded to give bounded width for Flexible to work
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.searchbar4(
                    'Closing Balance',
                    color: isDark ? AppColors.white.withOpacity(0.8) : AppColorsLight.black,
                    fontWeight: FontWeight.w400,
                    minFontSize: 10,
                  ),
                  SizedBox(height: responsive.hp(1)),
                  AppText.amountRow(
                    amount: balance.abs(),
                    // ✅ KHATABOOK LOGIC: Use balance value for color
                    // Positive = RED (Customer owes you - You will RECEIVE)
                    // Negative = GREEN (You owe customer - You will GIVE)
                    // Zero = GREEN (Settled/Clear)
                    color: isZeroBalance
                        ? AppColors.primeryamount
                        : BalanceHelper.getBalanceColorFromValue(balance),
                    symbolSize: AmountSymbolSize.searchbar1,
                    amountSize: AmountTextSize.searchbar2,
                    amountFontWeight: FontWeight.w500,
                    minFontSize: 10,
                    spacing: responsive.wp(1),
                  ),
                ],
              ),
            ),
            // Stack with 3 SVG icons - changes based on balance type
            // ✅ FIX: Show neutral styling for zero balance
            if (!isZeroBalance)
              SizedBox(
                width: responsive.iconSizeExtraLarge * 1.5,
                height: responsive.iconSizeExtraLarge * 1.5,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Base SVG icon - changes based on balance
                    SvgPicture.asset(
                      balance < 0 ? AppIcons.vectoeIc1 : AppIcons.vectoeIc4,
                      width: responsive.iconSizeExtraLarge,
                      height: responsive.iconSizeExtraLarge,
                    ),
                    // Center stacked icon - changes based on balance
                    SvgPicture.asset(
                      balance < 0 ? AppIcons.vectoeIc3 : AppIcons.vectoeIc3,
                      width: responsive.iconSizeSmall + 5,
                      height: responsive.iconSizeSmall + 5,
                    ),
                    // Top right stacked icon - changes based on balance
                    Positioned(
                      top: 5,
                      right: 5,
                      child: SvgPicture.asset(
                        balance < 0 ? AppIcons.vectoeIc2 : AppIcons.vectoeIc5,
                        width: responsive.iconSizeMedium,
                        height: responsive.iconSizeMedium,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildTransactionsList(
    LedgerDetailController controller,
    AdvancedResponsiveHelper responsive,
    bool isDark,
  ) {
    return Obx(() {
      if (controller.isTransactionsLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
            strokeWidth: 1.0,
          ),
        );
      }

      final history = controller.transactionHistory.value;
      if (history == null || history.data.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => controller.refreshAll(),
          color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
          backgroundColor: isDark ? AppColors.containerDark : AppColorsLight.white,
          child: ListView(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: responsive.hp(30)),
              Center(
                child: AppText.searchbar1(
                  'No transactions found',
                  color: isDark
                      ? AppColors.textSecondary
                      : AppColorsLight.textSecondary,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.refreshAll(),
        color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
        backgroundColor: isDark ? AppColors.containerDark : AppColorsLight.white,
        child: Obx(() {
          // 🔥 FIX: Don't filter deleted transactions - show them with underline instead
          final allTransactions = history.data;
          final isLoadingMore = controller.isLoadingMore.value;
          final hasMoreData = controller.hasMoreData.value;

          debugPrint('🎨 ========== UI RENDERING - TRANSACTION LIST ==========');
          debugPrint('📊 Total transactions loaded: ${allTransactions.length}/${controller.totalTransactionCount.value}');
          debugPrint('🗑️ Deleted transactions: ${history.data.where((t) => t.isDelete).length}');
          debugPrint('📄 Has more data: $hasMoreData, Loading more: $isLoadingMore');
          debugPrint('================================================');

          return ListView.builder(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              bottom: responsive.hp(18),  // Increased padding for floating button visibility
            ),
            // Add 1 for loading indicator when loading more
            itemCount: allTransactions.length + (isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the end
              if (index == allTransactions.length) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: responsive.hp(2)),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
                      strokeWidth: 2.0,
                    ),
                  ),
                );
              }

              final transaction = allTransactions[index];
              return _buildTransactionItem(
                transaction,
                controller.ledgerDetail.value?.partyName ?? '',
                responsive,
                isDark,
              );
            },
          );
        }),
      );
    });
  }

  Widget _buildTransactionItem(
    dynamic transaction,
    String partyName,
    AdvancedResponsiveHelper responsive,
    bool isDark,
  ) {
    // ✅ FIX: Use BalanceHelper for consistent logic
    final isPositive = BalanceHelper.isPositive(
      transactionType: transaction.transactionType,
      itemName: 'LedgerDetail Transaction: ${transaction.description ?? "No note"}',
    );

    // Format amount - remove currency symbol as ListItemWidget adds it
    final formattedAmount = transaction.amount.toStringAsFixed(2);

    // Format date for subtitle using Formatters utility (time first, then date)
    // Use transactionDate to show original transaction date (not updatedAt which changes on edit)
    final formattedDate = Formatters.formatStringToTimeAndDate(transaction.transactionDate);

    // ✅ Use note/description as title, fallback to "No note" if empty
    final noteTitle = (transaction.description != null && transaction.description.toString().trim().isNotEmpty)
        ? transaction.description.toString()
        : 'No note added';

    // 🔥 FIX: Use isDelete for underline, not transaction type
    // Amount color: IN = Blue, OUT = RED (unchanged)
    // Underline: Only for DELETED transactions
    final isDeleted = transaction.isDelete;

    // ✅ Use API's currentBalance (server-calculated running balance)
    // This is correct because it matches closing balance
    final runningBalance = transaction.currentBalance;

    // ✅ KHATABOOK LOGIC for balance color:
    // Positive balance (> 0) = RED (Customer owes you - You will RECEIVE)
    // Negative balance (< 0) = GREEN (You owe customer - You will GIVE)
    final isBalancePositive = runningBalance > 0;  // For +/- sign display

    // 🧪 DEBUG: Show running balance info (Khatabook logic)
    debugPrint('   💰 Subtitle Balance - ID: ${transaction.id}, Balance: ₹$runningBalance, Color: ${runningBalance > 0 ? "RED (Receivable)" : runningBalance < 0 ? "GREEN (Payable)" : "Neutral"}');

    return ListItemWidget(
      title: noteTitle,
      subtitle: formattedDate,
      subtitleColor: isDark ? AppColors.textDisabled : AppColorsLight.black,
      titlePrefixIcon: SvgPicture.asset(
        isPositive ? AppIcons.arrowInIc : AppIcons.arrowOutIc,
        width: responsive.iconSizeMedium,
        height: responsive.iconSizeMedium,
        colorFilter: ColorFilter.mode(
          isDark ? AppColors.white : AppColorsLight.black,
          BlendMode.srcIn,
        ),
      ),
      subtitleSuffix: AppText.headlineMedium(
        // ✅ Add +/- sign based on balance: Positive = +, Negative = -
        'Bal. ₹ ${NumberFormat('#,##,##0.00',).format(runningBalance.abs())}',
        color: isDark ? AppColors.textDisabled : AppColorsLight.black,       // 🔴 Red for negative (देना है)
        fontWeight: FontWeight.w400,
      ),
      subtitleFontWeight: FontWeight.w400,
      amount: formattedAmount,
      isPositiveAmount: isPositive,  // IN = Blue, OUT = RED ✅
      amountDecoration: isDeleted ? TextDecoration.lineThrough : null,  // Strikethrough for deleted
      showBorder: true,
      // 🔥 FIX: Underline ONLY for deleted transactions
      titleDecoration: isDeleted ? TextDecoration.lineThrough : null,
      titleColor: isDeleted
          ? (isDark ? AppColors.textSecondary : AppColorsLight.textSecondary)
          : null,
      onTap: () => _showTransactionDetails(
        transaction,
        partyName,
        isPositive,
      ),
    );
  }

  void _showTransactionDetails(
    dynamic transaction,
    String partyName,
    bool isPositive,
  ) {
    final context = Get.context;
    if (context == null) {
      debugPrint('ERROR: Context is null, cannot show bottom sheet');
      return;
    }

    debugPrint('🔍 ========== TRANSACTION CLICKED ==========');
    debugPrint('📊 Transaction ID: ${transaction.id}');
    debugPrint('💰 Amount: ${transaction.amount}');
    debugPrint('📝 Type: ${transaction.transactionType}');
    debugPrint('📅 Date: ${transaction.transactionDate}');
    debugPrint('🗑️ Is Deleted: ${transaction.isDelete}');
    debugPrint('📂 Ledger ID: ${transaction.ledgerId}');
    debugPrint('==========================================');

    // Get area from ledger detail (only show area, not full address)
    final location = controller.ledgerDetail.value?.area ?? '';

    // Show transaction detail bottom sheet
    TransactionDetailBottomSheet.show(
      context,
      transactionId: transaction.id,
      ledgerId: controller.ledgerId,
      partyName: partyName,
      location: location,
      amount: transaction.amount,
      transactionDate: transaction.transactionDate, // Raw ISO date for formatting
      entryDate: transaction.updatedAt, // Raw ISO date for formatting
      remarks: transaction.description,
      isPositive: isPositive,
      rawTransactionDate: transaction.transactionDate, // Pass original ISO date for API calls
      closingBalance: transaction.currentBalance, // Pass closing balance after this transaction
      onEdit: () async {
        debugPrint('✅ Edit callback - Refreshing ledger detail data...');
        await controller.refreshAll();
        debugPrint('✅ Ledger detail data refreshed successfully');
      },
      onDelete: () async {
        debugPrint('🗑️ Delete callback triggered - Transaction ID: ${transaction.id}');
        debugPrint('🔄 Starting ledger detail refresh after deletion...');
        await controller.refreshAll();
        debugPrint('✅ Ledger detail data refreshed successfully after deletion');
      },
    );
  }


  Widget _buildAddEntryButton(
    AdvancedResponsiveHelper responsive,
    bool isDark,
  ) {
    final controller = Get.find<LedgerDetailController>();
    return Container(
      width: double.infinity,
      height: 56,
      margin: EdgeInsets.all(responsive.wp(3)),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.containerDark, AppColors.containerDark]
              : [AppColorsLight.white, AppColorsLight.gradientColor2],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(color: isDark ? AppColors.driver : AppColors.driver),
        borderRadius: BorderRadius.circular(responsive.borderRadiusExtraLarge2),
      ),
      child: Row(
        children: [
          // IN Button (Left Side)
          Expanded(
            child: InkWell(
              onTap: () async {
                final detail = controller.ledgerDetail.value;
                final result = await Get.toNamed(
                  AppRoutes.addTransaction,
                  arguments: {
                    'ledgerId': controller.ledgerId,
                    'customerName': detail?.partyName ?? 'Customer',
                    'customerLocation': detail?.area ?? '',
                    'closingBalance': detail?.currentBalance ?? 0.0,
                    'accountType': detail?.partyType ?? 'CUSTOMER',
                    'defaultTransactionType': 'IN', // Pre-select IN
                  },
                );

                if (result == true) {
                  await controller.refreshAll();
                }
              },
              child: Container(
                width: double.infinity,
                height: 65,
                margin: EdgeInsets.all(responsive.wp(2)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primeryamount,
                      AppColors.primeryamount
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(responsive.borderRadiusExtraLarge1),

                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AppIcons.arrowInIc,
                      width: responsive.iconSizeLarge,
                      height: responsive.iconSizeLarge,
                      colorFilter: ColorFilter.mode(
                        AppColors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: responsive.spacing(8)),
                    AppText.searchbar1(
                      'IN',
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // OUT Button (Right Side)
          Expanded(
            child: InkWell(
              onTap: () async {
                final detail = controller.ledgerDetail.value;
                final result = await Get.toNamed(
                  AppRoutes.addTransaction,
                  arguments: {
                    'ledgerId': controller.ledgerId,
                    'customerName': detail?.partyName ?? 'Customer',
                    'customerLocation': detail?.area ?? '',
                    'closingBalance': detail?.currentBalance ?? 0.0,
                    'accountType': detail?.partyType ?? 'CUSTOMER',
                    'defaultTransactionType': 'OUT', // Pre-select OUT
                  },
                );

                if (result == true) {
                  await controller.refreshAll();
                }
              },
              child: Container(
                width: double.infinity,
                height: 65,
                margin: EdgeInsets.all(responsive.wp(2)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.red500,
                      AppColors.red500
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(responsive.borderRadiusExtraLarge1),

                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AppIcons.arrowOutIc,
                      width: responsive.iconSizeLarge,
                      height: responsive.iconSizeLarge,
                      colorFilter: ColorFilter.mode(
                        AppColors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: responsive.spacing(8)),
                    AppText.searchbar1(
                      'OUT',
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
