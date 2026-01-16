/// Transaction Detail Model
/// Response from GET /api/ledgerTransaction/details/{transactionId}
class TransactionDetailModel {
  final int id;
  final String? transactionId;
  final int? senderLedgerId;
  final int? senderMerchantId;
  final int? ownerId;
  final int? receiverMerchantId;
  final int? receiverLedgerId;
  final int? ledgerId;
  final double amount;
  final double lastBalance;
  final double currentBalance;
  final String? description;
  final String? transactionDate;
  final int creditDay;
  final double interestRate;
  final bool isDelete;
  final String? createdBy;
  final String? sessionId;
  final String? updatedBy;
  final String? createdAt;
  final String? updatedAt;
  final List<TransactionAttachment> attachments;
  final int version;
  final List<TransactionHistoryItem> transactionHistory;
  final MerchantInfo? senderMerchant;
  final MerchantInfo? receiverMerchant;
  final String? transactionType;
  final String? customerName;

  TransactionDetailModel({
    required this.id,
    this.transactionId,
    this.senderLedgerId,
    this.senderMerchantId,
    this.ownerId,
    this.receiverMerchantId,
    this.receiverLedgerId,
    this.ledgerId,
    required this.amount,
    required this.lastBalance,
    required this.currentBalance,
    this.description,
    this.transactionDate,
    this.creditDay = 0,
    this.interestRate = 0,
    this.isDelete = false,
    this.createdBy,
    this.sessionId,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    required this.attachments,
    this.version = 0,
    this.transactionHistory = const [],
    this.senderMerchant,
    this.receiverMerchant,
    this.transactionType,
    this.customerName,
  });

  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) {
    return TransactionDetailModel(
      id: json['id'] ?? 0,
      transactionId: json['transactionId'],
      senderLedgerId: json['senderLedgerId'],
      senderMerchantId: json['senderMerchantId'],
      ownerId: json['ownerId'],
      receiverMerchantId: json['receiverMerchantId'],
      receiverLedgerId: json['receiverLedgerId'],
      ledgerId: json['ledgerId'],
      amount: (json['amount'] ?? 0).toDouble(),
      lastBalance: (json['lastBalance'] ?? 0).toDouble(),
      currentBalance: (json['currentBalance'] ?? 0).toDouble(),
      description: json['description'],
      transactionDate: json['transactionDate'],
      creditDay: json['creditDay'] ?? 0,
      interestRate: (json['interestRate'] ?? 0).toDouble(),
      isDelete: json['isDelete'] ?? false,
      createdBy: json['createdBy'],
      sessionId: json['sessionId'],
      updatedBy: json['updatedBy'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      attachments: (json['attachment'] ?? json['attachments']) != null
          ? ((json['attachment'] ?? json['attachments']) as List)
              .map((item) => TransactionAttachment.fromJson(item))
              .toList()
          : [],
      version: json['version'] ?? 0,
      transactionHistory: json['transactionHistory'] != null
          ? (json['transactionHistory'] as List)
              .map((item) => TransactionHistoryItem.fromJson(item))
              .toList()
          : [],
      senderMerchant: json['senderMerchant'] != null
          ? MerchantInfo.fromJson(json['senderMerchant'])
          : null,
      receiverMerchant: json['receiverMerchant'] != null
          ? MerchantInfo.fromJson(json['receiverMerchant'])
          : null,
      transactionType: json['transactionType'],
      customerName: json['customerName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionId': transactionId,
      'senderLedgerId': senderLedgerId,
      'senderMerchantId': senderMerchantId,
      'ownerId': ownerId,
      'receiverMerchantId': receiverMerchantId,
      'receiverLedgerId': receiverLedgerId,
      'ledgerId': ledgerId,
      'amount': amount,
      'lastBalance': lastBalance,
      'currentBalance': currentBalance,
      'description': description,
      'transactionDate': transactionDate,
      'creditDay': creditDay,
      'interestRate': interestRate,
      'isDelete': isDelete,
      'createdBy': createdBy,
      'sessionId': sessionId,
      'updatedBy': updatedBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'version': version,
      'transactionHistory': transactionHistory.map((h) => h.toJson()).toList(),
      'senderMerchant': senderMerchant?.toJson(),
      'receiverMerchant': receiverMerchant?.toJson(),
      'transactionType': transactionType,
      'customerName': customerName,
    };
  }

  /// Check if transaction has attachments
  bool get hasAttachments => attachments.isNotEmpty;

  /// Get attachment count
  int get attachmentCount => attachments.length;

  /// Get all attachment URLs
  List<String> get attachmentUrls =>
      attachments.map((a) => a.presignedUrl).where((url) => url.isNotEmpty).toList();

  /// Check if transaction is IN type
  bool get isInTransaction => transactionType == 'IN';

  /// Check if transaction is OUT type
  bool get isOutTransaction => transactionType == 'OUT';

  /// Get history count
  int get historyCount => transactionHistory.length;

  /// Check if transaction has been edited
  bool get hasHistory => transactionHistory.isNotEmpty;
}

/// Transaction Attachment Model
/// Maps to attachment objects in API response
class TransactionAttachment {
  final int id;
  final String key;
  final String presignedUrl;
  final String? fileName;

  TransactionAttachment({
    required this.id,
    required this.key,
    required this.presignedUrl,
    this.fileName,
  });

  factory TransactionAttachment.fromJson(Map<String, dynamic> json) {
    return TransactionAttachment(
      id: json['id'] ?? 0,
      key: json['key'] ?? '',
      presignedUrl: json['presignedUrl'] ?? json['url'] ?? '',
      fileName: json['fileName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'presignedUrl': presignedUrl,
      'fileName': fileName,
    };
  }
}

/// Transaction History Item Model
/// Represents each version/edit of a transaction
class TransactionHistoryItem {
  final int id;
  final int version;
  final double transactionAmount;
  final String? transactionDate;
  final String? description;
  final List<TransactionAttachment> attachments;
  final String? updatedBy;
  final String? updatedAt;

  TransactionHistoryItem({
    required this.id,
    required this.version,
    required this.transactionAmount,
    this.transactionDate,
    this.description,
    required this.attachments,
    this.updatedBy,
    this.updatedAt,
  });

  factory TransactionHistoryItem.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryItem(
      id: json['id'] ?? 0,
      version: json['version'] ?? 0,
      transactionAmount: (json['transactionAmount'] ?? 0).toDouble(),
      transactionDate: json['transactionDate'],
      description: json['description'],
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((item) => TransactionAttachment.fromJson(item))
              .toList()
          : [],
      updatedBy: json['updatedBy'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'transactionAmount': transactionAmount,
      'transactionDate': transactionDate,
      'description': description,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'updatedBy': updatedBy,
      'updatedAt': updatedAt,
    };
  }

  /// Check if this history item has attachments
  bool get hasAttachments => attachments.isNotEmpty;
}

/// Merchant Info Model
class MerchantInfo {
  final int id;
  final String? mobileNumber;
  final String? businessName;

  MerchantInfo({
    required this.id,
    this.mobileNumber,
    this.businessName,
  });

  factory MerchantInfo.fromJson(Map<String, dynamic> json) {
    return MerchantInfo(
      id: json['id'] ?? 0,
      mobileNumber: json['mobileNumber'],
      businessName: json['businessName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mobileNumber': mobileNumber,
      'businessName': businessName,
    };
  }
}
