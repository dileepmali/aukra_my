import 'package:aukra_anantkaya_space/presentations/widgets/custom_single_border_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/constants/app_icons.dart';
import '../../app/themes/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_text.dart';
import '../../controllers/ledger_detail_controller.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/responsive_layout/padding_navigation.dart';
import '../widgets/custom_app_bar/custom_app_bar.dart';
import '../widgets/custom_app_bar/model/app_bar_config.dart';
import '../widgets/list_item_widget.dart';
import '../routes/app_routes.dart';
import '../widgets/bottom_sheets/transaction_detail_bottom_sheet.dart';

class LedgerDetailScreen extends GetView<LedgerDetailController> {
  const LedgerDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
                      final address = detail?.address ?? '';

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
                                          AppColorsLight.gradientColor1,
                                          AppColorsLight.gradientColor2,
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: AppText.custom(
                                  getInitials(name),
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: responsive.fontSize(18),
                                    fontWeight: FontWeight.w700,
                                  ),
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
                                  AppText.custom(
                                    name,
                                    style: TextStyle(
                                      color: isDark
                                          ? AppColors.white
                                          : AppColorsLight.textPrimary,
                                      fontSize: responsive.fontSize(16),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    minFontSize: 12,
                                  ),
                                  SizedBox(height: responsive.hp(0.2)),
                
                                  // Mobile Number + Address (Subtitle)
                                  AppText.custom(
                                    [
                                      if (mobile.isNotEmpty) mobile,
                                      if (address.isNotEmpty) address,
                                    ].join(' • '),
                                    style: TextStyle(
                                      color: isDark
                                          ? AppColors.textDisabled
                                          : AppColorsLight.textSecondary,
                                      fontSize: responsive.fontSize(12.5),
                                      fontWeight: FontWeight.w400,
                                    ),
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
                    _buildIconButton(
                      context,
                      AppIcons.callIc,
                      () {
                        debugPrint('More options tapped');
                      },
                      responsive,
                      isDark,
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color:
                  isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
              strokeWidth: 1.0,
            ),
          );
        }

        return Column(
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
        );
      }),
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
                  AppColorsLight.gradientColor1,
                  AppColorsLight.gradientColor2
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
        borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
      ),
      child: Obx(() {
        final detail = controller.ledgerDetail.value;
        if (detail == null) return SizedBox.shrink();

        final balance = detail.currentBalance;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.custom(
                  'Closing Balance',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.8),
                    fontSize: responsive.fontSize(15),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: responsive.hp(1)),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: responsive.hp(1.0)), // Fine-tune vertical position
                      child: SvgPicture.asset(
                        AppIcons.vectoeIc3,
                        width: responsive.iconSizeSmall + 5 ,
                        height: responsive.iconSizeSmall + 5,
                        colorFilter: ColorFilter.mode(
                          isDark ? AppColors.white : AppColorsLight.textPrimary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(width: responsive.wp(1),),
                    AppText.custom(
                          '${NumberFormat('#,##,##0.00', 'en_IN').format(balance.abs())}',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: responsive.fontSize(28),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                  ],
                ),
              ],
            ),
            // Stack with 3 SVG icons
            SizedBox(
              width: responsive.iconSizeExtraLarge * 1.5,
              height: responsive.iconSizeExtraLarge * 1.5,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Base SVG icon - original colors
                  SvgPicture.asset(
                    AppIcons.vectoeIc1,
                    width: responsive.iconSizeExtraLarge,
                    height: responsive.iconSizeExtraLarge,
                  ),
                  // Third stacked icon - CENTER of vectoeIc1 - original colors
                  SvgPicture.asset(
                    AppIcons.vectoeIc3,
                    width: responsive.iconSizeSmall + 5,
                    height: responsive.iconSizeSmall + 5,
                  ),
                  // Second stacked icon - top right - original colors
                  Positioned(
                    top: 5,
                    right: 5,
                    child: SvgPicture.asset(
                      AppIcons.vectoeIc2,
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
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: responsive.hp(30)),
              Center(
                child: AppText.custom(
                  'No transactions found',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColorsLight.textSecondary,
                    fontSize: responsive.fontSize(16),
                  ),
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
        child: Builder(
          builder: (context) {
            // 🔥 FIX: Don't filter deleted transactions - show them with underline instead
            final allTransactions = history.data;

            debugPrint('🎨 ========== UI RENDERING - TRANSACTION LIST ==========');
            debugPrint('📊 Total transactions from API: ${history.data.length}');
            debugPrint('🗑️ Deleted transactions: ${history.data.where((t) => t.isDelete).length}');
            debugPrint('✅ All transactions to render: ${allTransactions.length}');
            debugPrint('📋 Transaction IDs: ${allTransactions.map((t) => 'ID:${t.id}(deleted:${t.isDelete})').toList()}');
            debugPrint('================================================');

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: responsive.hp(10),
              ),
              itemCount: allTransactions.length,
              itemBuilder: (context, index) {
                final transaction = allTransactions[index];
                debugPrint('   Rendering item $index: Transaction ID ${transaction.id} (isDelete: ${transaction.isDelete})');
                return _buildTransactionItem(
                  transaction,
                  controller.ledgerDetail.value?.partyName ?? '',
                  responsive,
                  isDark,
                );
              },
            );
          },
        ),
      );
    });
  }

  Widget _buildTransactionItem(
    dynamic transaction,
    String partyName,
    AdvancedResponsiveHelper responsive,
    bool isDark,
  ) {
    // Determine if transaction is positive (IN) or negative (OUT)
    final isPositive = transaction.transactionType == 'IN';

    // Format amount - remove currency symbol as ListItemWidget adds it
    final formattedAmount = transaction.amount.toStringAsFixed(2);

    // Format date for subtitle using Formatters utility (time first, then date)
    final formattedDate = Formatters.formatStringToTimeAndDate(transaction.transactionDate);

    // ✅ Use note/description as title, fallback to "No note" if empty
    final noteTitle = (transaction.description != null && transaction.description.toString().trim().isNotEmpty)
        ? transaction.description.toString()
        : 'No note added';

    // 🔥 FIX: Use isDelete for underline, not transaction type
    // Amount color: IN = Blue, OUT = RED (unchanged)
    // Underline: Only for DELETED transactions
    final isDeleted = transaction.isDelete;

    return ListItemWidget(
      title: noteTitle,
      subtitle: formattedDate,
      titlePrefixIcon: SvgPicture.asset(
        isPositive ? AppIcons.arrowInIc : AppIcons.arrowOutIc,
        width: responsive.iconSizeMedium,
        height: responsive.iconSizeMedium,
        colorFilter: ColorFilter.mode(
          AppColors.white,
          BlendMode.srcIn,
        ),
      ),
      subtitleSuffix: AppText.custom(
        'Bal. ${NumberFormat('#,##,##0.00', 'en_IN').format(transaction.lastBalance)}',
        style: TextStyle(
          color: isPositive
              ? AppColors.textDisabled
              : AppColors.textSecondary,
          fontSize: responsive.fontSize(13),
          fontWeight: isPositive ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      subtitleFontWeight: isPositive ? FontWeight.w600 : FontWeight.w400,
      amount: formattedAmount,
      isPositiveAmount: isPositive,  // IN = Blue, OUT = RED ✅
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

    // Get location from ledger detail
    final location = controller.ledgerDetail.value?.address ?? '';

    // Format dates for bottom sheet
    final transactionDateFormatted = _formatDateForBottomSheet(transaction.transactionDate);
    final entryDateFormatted = _formatDateForBottomSheet(transaction.updatedAt);

    // Show transaction detail bottom sheet
    TransactionDetailBottomSheet.show(
      context,
      transactionId: transaction.id,
      ledgerId: controller.ledgerId,
      partyName: partyName,
      location: location,
      amount: transaction.amount,
      transactionDate: transactionDateFormatted,
      entryDate: entryDateFormatted,
      remarks: transaction.description,
      isPositive: isPositive,
      rawTransactionDate: transaction.transactionDate, // Pass original ISO date for API calls
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

  String _formatDateForBottomSheet(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('hh:mma, dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
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
          colors: [
            AppColors.containerDark,
            AppColors.containerDark
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(color: isDark ? AppColors.driver : AppColorsLight.black),
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
                    'customerLocation': detail?.address ?? 'Location',
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
                    AppText.custom(
                      'IN',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: responsive.fontSize(18),
                        fontWeight: FontWeight.w600,
                      ),
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
                    'customerLocation': detail?.address ?? 'Location',
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
                    AppText.custom(
                      'OUT',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: responsive.fontSize(18),
                        fontWeight: FontWeight.w600,
                      ),
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
