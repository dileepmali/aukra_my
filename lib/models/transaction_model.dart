class TransactionModel {
  final int ledgerId;
  final int merchantId;
  final double transactionAmount;
  final String transactionType; // "IN" or "OUT"
  final String transactionDate; // ISO format
  final String? comments;
  final String partyMerchantAction;
  final List<int>? uploadedKeys;
  final String securityKey;

  TransactionModel({
    required this.ledgerId,
    required this.merchantId,
    required this.transactionAmount,
    required this.transactionType,
    required this.transactionDate,
    this.comments,
    this.partyMerchantAction = 'VIEW',
    this.uploadedKeys,
    required this.securityKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'ledgerId': ledgerId,
      'merchantId': merchantId,
      'transactionAmount': transactionAmount,
      'transactionType': transactionType,
      'transactionDate': transactionDate,
      if (comments != null && comments!.isNotEmpty) 'comments': comments,
      'partyMerchantAction': partyMerchantAction,
      if (uploadedKeys != null && uploadedKeys!.isNotEmpty)
        'uploadedKeys': uploadedKeys,
      'securityKey': securityKey,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      ledgerId: json['ledgerId'] ?? 0,
      merchantId: json['merchantId'] ?? 0,
      transactionAmount: (json['transactionAmount'] ?? 0).toDouble(),
      transactionType: json['transactionType'] ?? 'OUT',
      transactionDate: json['transactionDate'] ?? '',
      comments: json['comments'],
      partyMerchantAction: json['partyMerchantAction'] ?? 'VIEW',
      uploadedKeys: json['uploadedKeys'] != null
          ? List<int>.from(json['uploadedKeys'])
          : null,
      securityKey: json['securityKey'] ?? '',
    );
  }

  TransactionModel copyWith({
    int? ledgerId,
    int? merchantId,
    double? transactionAmount,
    String? transactionType,
    String? transactionDate,
    String? comments,
    String? partyMerchantAction,
    List<int>? uploadedKeys,
    String? securityKey,
  }) {
    return TransactionModel(
      ledgerId: ledgerId ?? this.ledgerId,
      merchantId: merchantId ?? this.merchantId,
      transactionAmount: transactionAmount ?? this.transactionAmount,
      transactionType: transactionType ?? this.transactionType,
      transactionDate: transactionDate ?? this.transactionDate,
      comments: comments ?? this.comments,
      partyMerchantAction: partyMerchantAction ?? this.partyMerchantAction,
      uploadedKeys: uploadedKeys ?? this.uploadedKeys,
      securityKey: securityKey ?? this.securityKey,
    );
  }
}
