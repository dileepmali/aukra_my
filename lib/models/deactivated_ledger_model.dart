/// Model for deactivated ledger item
class DeactivatedLedgerModel {
  final int id;
  final String partyName;
  final String mobileNumber;
  final String partyType;
  final DateTime? updatedAt; // When it was deactivated

  DeactivatedLedgerModel({
    required this.id,
    required this.partyName,
    required this.mobileNumber,
    required this.partyType,
    this.updatedAt,
  });

  factory DeactivatedLedgerModel.fromJson(Map<String, dynamic> json) {
    // Check multiple possible field names for mobile number
    final mobile = json['mobileNumber'] ?? json['mobile'] ?? json['phone'] ?? json['phoneNumber'] ?? '';

    return DeactivatedLedgerModel(
      id: json['id'] ?? 0,
      partyName: json['partyName'] ?? json['name'] ?? 'Unknown',
      mobileNumber: mobile.toString(),
      partyType: json['partyType'] ?? 'CUSTOMER',
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partyName': partyName,
      'mobileNumber': mobileNumber,
      'partyType': partyType,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

/// Response model for deactivated ledgers list
class DeactivatedLedgersResponse {
  final int count;
  final int totalCount;
  final List<DeactivatedLedgerModel> data;

  DeactivatedLedgersResponse({
    required this.count,
    required this.totalCount,
    required this.data,
  });

  factory DeactivatedLedgersResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return DeactivatedLedgersResponse(
      count: json['count'] ?? dataList.length,
      totalCount: json['totalCount'] ?? json['count'] ?? dataList.length,
      data: dataList
          .map((item) => DeactivatedLedgerModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Create from direct list (when API returns array directly)
  factory DeactivatedLedgersResponse.fromList(List<dynamic> list) {
    return DeactivatedLedgersResponse(
      count: list.length,
      totalCount: list.length,
      data: list
          .map((item) => DeactivatedLedgerModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}