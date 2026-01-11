class LedgerModel {
  final int? id; // Ledger ID from backend
  final String name;
  final double creditLimit;
  final int creditDay;
  final String interestType; // YEARLY, MONTHLY
  final double openingBalance;
  final double currentBalance; // Current balance (updates with transactions)
  final String transactionType; // IN, OUT
  final double interestRate;
  final String mobileNumber;
  final String area;
  final String address;
  final int merchantId;
  final String pinCode;
  final String partyType; // CUSTOMER, SUPPLIER
  final DateTime? createdAt; // Customer creation date/time
  final DateTime? updatedAt; // Last update date/time (transaction date)

  LedgerModel({
    this.id,
    required this.name,
    required this.creditLimit,
    required this.creditDay,
    required this.interestType,
    required this.openingBalance,
    required this.currentBalance,
    required this.transactionType,
    required this.interestRate,
    required this.mobileNumber,
    required this.area,
    required this.address,
    required this.merchantId,
    required this.pinCode,
    required this.partyType,
    this.createdAt,
    this.updatedAt,
  });

  // Convert to JSON for API request (CREATE)
  // NOTE: currentBalance is NOT sent - backend calculates it automatically
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'creditLimit': creditLimit,
      'creditDay': creditDay,
      'interestType': interestType,
      'openingBalance': openingBalance,
      // currentBalance is excluded - backend manages it
      'transactionType': transactionType,
      'interestRate': interestRate,
      'mobileNumber': mobileNumber,
      'area': area,
      'address': address,
      'merchantId': merchantId,
      'pinCode': pinCode,
      'partyType': partyType,
    };
  }

  // Convert to JSON for UPDATE API (PUT)
  // Excludes: id, openingBalance, transactionType, merchantId, partyType, mobileNumber
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'creditLimit': creditLimit,
      'creditDay': creditDay,
      'interestType': interestType,
      'interestRate': interestRate,
      // 🔥 FIX: mobileNumber removed - backend doesn't accept it for updates
      'area': area,
      'address': address,
      'pinCode': pinCode,
    };
  }

  // Create from JSON
  factory LedgerModel.fromJson(Map<String, dynamic> json) {
    return LedgerModel(
      id: json['id'],
      name: json['partyName'] ?? json['name'] ?? '',  // API returns 'partyName'
      creditLimit: (json['creditLimit'] ?? 0).toDouble(),
      creditDay: json['creditDay'] ?? 0,
      interestType: json['interestType'] ?? 'YEARLY',
      openingBalance: (json['openingBalance'] ?? 0).toDouble(),
      currentBalance: (json['currentBalance'] ?? json['openingBalance'] ?? 0).toDouble(),
      transactionType: json['transactionType'] ?? 'IN',
      interestRate: (json['interestRate'] ?? 0).toDouble(),
      mobileNumber: json['mobileNumber'] ?? '',
      area: json['area'] ?? '',
      address: json['address'] ?? '',
      merchantId: json['merchantId'] ?? 0,
      pinCode: json['pinCode'] ?? '',
      partyType: json['partyType'] ?? 'CUSTOMER',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  // Copy with method for updating fields
  LedgerModel copyWith({
    int? id,
    String? name,
    double? creditLimit,
    int? creditDay,
    String? interestType,
    double? openingBalance,
    double? currentBalance,
    String? transactionType,
    double? interestRate,
    String? mobileNumber,
    String? area,
    String? address,
    int? merchantId,
    String? pinCode,
    String? partyType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LedgerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      creditLimit: creditLimit ?? this.creditLimit,
      creditDay: creditDay ?? this.creditDay,
      interestType: interestType ?? this.interestType,
      openingBalance: openingBalance ?? this.openingBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      transactionType: transactionType ?? this.transactionType,
      interestRate: interestRate ?? this.interestRate,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      area: area ?? this.area,
      address: address ?? this.address,
      merchantId: merchantId ?? this.merchantId,
      pinCode: pinCode ?? this.pinCode,
      partyType: partyType ?? this.partyType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// API Response Models
class LedgerCreateResponse {
  final String message;

  LedgerCreateResponse({required this.message});

  factory LedgerCreateResponse.fromJson(Map<String, dynamic> json) {
    return LedgerCreateResponse(
      message: json['message'] ?? 'Created successfully',
    );
  }
}

class LedgerErrorResponse {
  final int statusCode;
  final String message;
  final List<FieldError>? errors;

  LedgerErrorResponse({
    required this.statusCode,
    required this.message,
    this.errors,
  });

  factory LedgerErrorResponse.fromJson(Map<String, dynamic> json) {
    return LedgerErrorResponse(
      statusCode: json['statusCode'] ?? 400,
      message: json['message'] ?? 'Invalid request data',
      errors: json['errors'] != null
          ? (json['errors'] as List)
              .map((e) => FieldError.fromJson(e))
              .toList()
          : null,
    );
  }

  String getErrorMessages() {
    if (errors != null && errors!.isNotEmpty) {
      return errors!.map((e) => '${e.field}: ${e.error}').join('\n');
    }
    return message;
  }
}

class FieldError {
  final String field;
  final String error;

  FieldError({
    required this.field,
    required this.error,
  });

  factory FieldError.fromJson(Map<String, dynamic> json) {
    return FieldError(
      field: json['field'] ?? '',
      error: json['error'] ?? '',
    );
  }
}
