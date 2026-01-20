/// QR Code Response Model
/// This model represents the QR code data received from the API
class QrCodeModel {
  final String? qrCodeUrl;
  final String? qrCodeData;
  final String? transactionId;
  final String? amount;
  final String? planName;
  final String? merchantName;
  final String? upiId;
  final int? expiryTime; // in seconds
  final bool success;
  final String? message;

  QrCodeModel({
    this.qrCodeUrl,
    this.qrCodeData,
    this.transactionId,
    this.amount,
    this.planName,
    this.merchantName,
    this.upiId,
    this.expiryTime,
    this.success = false,
    this.message,
  });

  /// Factory constructor to create QrCodeModel from JSON
  factory QrCodeModel.fromJson(Map<String, dynamic> json) {
    return QrCodeModel(
      qrCodeUrl: json['qr_code_url'] as String?,
      qrCodeData: json['qr_code_data'] as String?,
      transactionId: json['transaction_id'] as String?,
      amount: json['amount'] as String?,
      planName: json['plan_name'] as String?,
      merchantName: json['merchant_name'] as String?,
      upiId: json['upi_id'] as String?,
      expiryTime: json['expiry_time'] as int?,
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }

  /// Convert QrCodeModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'qr_code_url': qrCodeUrl,
      'qr_code_data': qrCodeData,
      'transaction_id': transactionId,
      'amount': amount,
      'plan_name': planName,
      'merchant_name': merchantName,
      'upi_id': upiId,
      'expiry_time': expiryTime,
      'success': success,
      'message': message,
    };
  }

  /// Create a dummy/mock QR code model for testing
  factory QrCodeModel.dummy({
    required String amount,
    required String planName,
  }) {
    // Generate dummy UPI payment URL
    final upiData = 'upi://pay?pa=merchant@upi&pn=Aukra&am=$amount&cu=INR&tn=$planName Plan Payment';

    // Using free QR code generator API for dummy setup
    final qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${Uri.encodeComponent(upiData)}';

    return QrCodeModel(
      qrCodeUrl: qrUrl,
      qrCodeData: upiData,
      transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      planName: planName,
      merchantName: 'Aukra',
      upiId: 'merchant@upi',
      expiryTime: 600, // 10 minutes
      success: true,
      message: 'QR code generated successfully',
    );
  }
}