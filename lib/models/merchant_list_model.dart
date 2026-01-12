/// Model for merchant address from /api/merchant/all response
class MerchantAddressModel {
  final int id;
  final String? area;
  final String? address;
  final String? city;
  final String? location;
  final String? state;
  final String? country;
  final String? pinCode;
  final String? createdBy;
  final String? updatedBy;
  final String? createdAt;
  final String? updatedAt;
  final int? addressId;

  MerchantAddressModel({
    required this.id,
    this.area,
    this.address,
    this.city,
    this.location,
    this.state,
    this.country,
    this.pinCode,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.addressId,
  });

  factory MerchantAddressModel.fromJson(Map<String, dynamic> json) {
    return MerchantAddressModel(
      id: json['id'] ?? 0,
      area: json['area'],
      address: json['address'],
      city: json['city'],
      location: json['location'],
      state: json['state'],
      country: json['country'],
      pinCode: json['pinCode'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      addressId: json['addressId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'area': area,
      'address': address,
      'city': city,
      'location': location,
      'state': state,
      'country': country,
      'pinCode': pinCode,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'addressId': addressId,
    };
  }

  /// Get full formatted address
  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (area != null && area!.isNotEmpty) parts.add(area!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);

    // Only add country if address doesn't already end with it (avoid duplicates)
    if (country != null && country!.isNotEmpty) {
      final currentAddress = parts.join(', ');
      if (!currentAddress.toUpperCase().endsWith(country!.toUpperCase())) {
        parts.add(country!);
      }
    }

    if (pinCode != null && pinCode!.isNotEmpty) parts.add(pinCode!);
    return parts.join(', ');
  }

  @override
  String toString() {
    return 'MerchantAddressModel(id: $id, address: $address, city: $city, country: $country)';
  }
}

/// Model for merchant list item from /api/merchant/all
class MerchantListModel {
  final int merchantId;
  final String phone;
  final String countryCode;
  final String businessName;
  final String action; // ALL, VIEW, ADMIN, etc.
  final bool isMainAccount;

  // Additional fields from API
  final int? id;
  final String? category;
  final String? businessType;
  final String? manager; // Assigned manager
  final String? emailId;
  final String? mobileNumber;
  final String? backupPhoneNumber;
  final String? adminMobileNumber;
  final bool isActive;
  final bool isOnboarded;
  final bool isVerified;
  final bool isBlocked;
  final bool isDelete;
  final String? createdBy;
  final String? updatedBy;
  final String? createdAt;
  final String? updatedAt;
  final int? addressId;
  final MerchantAddressModel? address;

  MerchantListModel({
    required this.merchantId,
    required this.phone,
    required this.countryCode,
    required this.businessName,
    required this.action,
    required this.isMainAccount,
    this.id,
    this.category,
    this.businessType,
    this.manager,
    this.emailId,
    this.mobileNumber,
    this.backupPhoneNumber,
    this.adminMobileNumber,
    this.isActive = true,
    this.isOnboarded = false,
    this.isVerified = false,
    this.isBlocked = false,
    this.isDelete = false,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.addressId,
    this.address,
  });

  /// Create model from JSON response
  factory MerchantListModel.fromJson(Map<String, dynamic> json) {
    // Parse address - handle both nested object and root level fields
    MerchantAddressModel? addressModel;

    if (json['address'] != null && json['address'] is Map<String, dynamic>) {
      // Case 1: Address is a nested object
      addressModel = MerchantAddressModel.fromJson(json['address'] as Map<String, dynamic>);
    } else if (json['city'] != null || json['state'] != null || json['pinCode'] != null || json['area'] != null) {
      // Case 2: Address fields are at root level
      addressModel = MerchantAddressModel(
        id: json['addressId'] ?? 0,
        address: json['address'] is String ? json['address'] : null,
        area: json['area'],
        city: json['city'],
        state: json['state'],
        country: json['country'],
        pinCode: json['pinCode'],
        location: json['location'],
        addressId: json['addressId'],
      );
    }

    return MerchantListModel(
      merchantId: json['merchantId'] ?? 0,
      phone: json['phone'] ?? '',
      countryCode: json['countryCode'] ?? '+91',
      businessName: json['businessName'] ?? '',
      action: json['action'] ?? 'VIEW',
      isMainAccount: json['isMainAccount'] ?? false,
      // Additional fields
      id: json['id'],
      category: json['category'],
      businessType: json['businessType'],
      manager: json['manager'],
      emailId: json['emailId'],
      mobileNumber: json['mobileNumber'],
      backupPhoneNumber: json['backupPhoneNumber'],
      adminMobileNumber: json['adminMobileNumber'],
      isActive: json['isActive'] ?? true,
      isOnboarded: json['isOnboarded'] ?? false,
      isVerified: json['isVerified'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
      isDelete: json['isDelete'] ?? false,
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      addressId: json['addressId'],
      address: addressModel,
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
      'id': id,
      'category': category,
      'businessType': businessType,
      'manager': manager,
      'emailId': emailId,
      'mobileNumber': mobileNumber,
      'backupPhoneNumber': backupPhoneNumber,
      'adminMobileNumber': adminMobileNumber,
      'isActive': isActive,
      'isOnboarded': isOnboarded,
      'isVerified': isVerified,
      'isBlocked': isBlocked,
      'isDelete': isDelete,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'addressId': addressId,
      'address': address?.toJson(),
    };
  }


  /// Get formatted phone number with country code
  String get formattedPhone => '$countryCode $phone';

  /// Check if user has full access (ALL permission)
  bool get hasFullAccess => action == 'ALL';

  /// Check if user has admin access
  bool get hasAdminAccess => action == 'ADMIN' || action == 'ALL';

  /// Get formatted address string
  String get formattedAddress => address?.fullAddress ?? '';

  /// Get display email (empty string if null)
  String get displayEmail => emailId ?? '';

  /// Get display category
  String get displayCategory => category ?? 'Not specified';

  /// Get display business type
  String get displayBusinessType => businessType ?? 'Not specified';

  /// Get display manager
  String get displayManager => manager ?? 'Not assigned';

  @override
  String toString() {
    return 'MerchantListModel(merchantId: $merchantId, businessName: $businessName, phone: $phone, isMainAccount: $isMainAccount, action: $action, isActive: $isActive, isVerified: $isVerified)';
  }
}
