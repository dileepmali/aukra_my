/// Model for merchant list item from /api/merchant/all
class MerchantListModel {
  final int merchantId;
  final String phone;
  final String countryCode;
  final String businessName;
  final String action; // ALL, VIEW, etc.
  final bool isMainAccount;

  MerchantListModel({
    required this.merchantId,
    required this.phone,
    required this.countryCode,
    required this.businessName,
    required this.action,
    required this.isMainAccount,
  });

  /// Create model from JSON response
  factory MerchantListModel.fromJson(Map<String, dynamic> json) {
    return MerchantListModel(
      merchantId: json['merchantId'] ?? 0,
      phone: json['phone'] ?? '',
      countryCode: json['countryCode'] ?? '+91',
      businessName: json['businessName'] ?? '',
      action: json['action'] ?? 'VIEW',
      isMainAccount: json['isMainAccount'] ?? false,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'merchantId': merchantId,
      'phone': phone,
      'countryCode': countryCode,
      'businessName': businessName,
      'action': action,
      'isMainAccount': isMainAccount,
    };
  }

  /// Get formatted phone number with country code
  String get formattedPhone => '$countryCode $phone';

  /// Check if user has full access (ALL permission)
  bool get hasFullAccess => action == 'ALL';

  @override
  String toString() {
    return 'MerchantListModel(merchantId: $merchantId, businessName: $businessName, phone: $phone, isMainAccount: $isMainAccount, action: $action)';
  }
}
