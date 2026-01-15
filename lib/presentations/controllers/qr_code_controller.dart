import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../data/models/qr_code_model.dart';
import '../../data/services/qr_code_service.dart';

/// QR Code Controller
/// Manages state for QR code generation and payment
class QrCodeController extends GetxController {
  final QrCodeService _qrCodeService = QrCodeService();

  // Observable variables
  final Rx<QrCodeModel?> qrCodeData = Rx<QrCodeModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt remainingTime = 600.obs; // 10 minutes in seconds

  // Payment details
  String? _currentAmount;
  String? _currentPlanName;
  String? _currentPlanDuration;

  /// Generate QR code for payment
  Future<void> generateQrCode({
    required String amount,
    required String planName,
    required String planDuration,
  }) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      _currentAmount = amount;
      _currentPlanName = planName;
      _currentPlanDuration = planDuration;

      debugPrint('🔄 QrCodeController: Generating QR code...');

      final result = await _qrCodeService.generateQrCode(
        amount: amount,
        planName: planName,
        planDuration: planDuration,
      );

      if (result.success) {
        qrCodeData.value = result;
        remainingTime.value = result.expiryTime ?? 600;
        debugPrint('✅ QR code generated successfully');
        debugPrint('   URL: ${result.qrCodeUrl}');
        debugPrint('   Transaction ID: ${result.transactionId}');
      } else {
        hasError.value = true;
        errorMessage.value = result.message ?? 'Failed to generate QR code';
        debugPrint('❌ QR code generation failed: ${result.message}');
      }

    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error: ${e.toString()}';
      debugPrint('❌ QrCodeController Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh/Regenerate QR code
  Future<void> refreshQrCode() async {
    if (_currentAmount != null && _currentPlanName != null && _currentPlanDuration != null) {
      await generateQrCode(
        amount: _currentAmount!,
        planName: _currentPlanName!,
        planDuration: _currentPlanDuration!,
      );
    }
  }

  /// Verify payment status
  Future<bool> verifyPayment() async {
    if (qrCodeData.value?.transactionId == null) {
      debugPrint('❌ No transaction ID available');
      return false;
    }

    try {
      isLoading.value = true;

      final result = await _qrCodeService.verifyPayment(
        qrCodeData.value!.transactionId!,
      );

      if (result['success'] == true && result['status'] == 'completed') {
        debugPrint('✅ Payment verified successfully');
        return true;
      } else {
        debugPrint('❌ Payment not completed: ${result['message']}');
        return false;
      }

    } catch (e) {
      debugPrint('❌ Payment verification error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get QR code image URL
  String? get qrCodeUrl => qrCodeData.value?.qrCodeUrl;

  /// Get transaction ID
  String? get transactionId => qrCodeData.value?.transactionId;

  /// Check if QR code is available
  bool get hasQrCode => qrCodeData.value?.qrCodeUrl != null;

  /// Clear QR code data
  void clearData() {
    qrCodeData.value = null;
    isLoading.value = false;
    hasError.value = false;
    errorMessage.value = '';
    remainingTime.value = 600;
    _currentAmount = null;
    _currentPlanName = null;
    _currentPlanDuration = null;
  }

  @override
  void onClose() {
    clearData();
    super.onClose();
  }
}