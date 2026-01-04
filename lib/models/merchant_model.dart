class MerchantModel {
  final String merchantName;
  final String businessName;
  final String mobileNumber;
  final String address;
  final String city;
  final String area;
  final String state;
  final String country;
  final String pinCode;
  final MerchantLocation? location; // GPS coordinates
  final String masterMobileNumber;
  final String? otp; // Optional - only needed if master number is different

  MerchantModel({
    required this.merchantName,
    required this.businessName,
    required this.mobileNumber,
    required this.address,
    required this.city,
    required this.area,
    required this.state,
    required this.country,
    required this.pinCode,
    this.location,
    required this.masterMobileNumber,
    this.otp,
  });

  // Convert model to JSON for API request
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'merchantName': merchantName,
      'businessName': businessName,
      'mobileNumber': mobileNumber,
      'address': address,
      'country': country,
      'masterMobileNumber': masterMobileNumber,
    };

    // TODO: Uncomment when backend supports these fields
    // Add required fields
    // if (city.isNotEmpty) data['city'] = city;
    // if (area.isNotEmpty) data['area'] = area;
    // if (state.isNotEmpty) data['state'] = state;
    // if (pinCode.isNotEmpty) data['pinCode'] = pinCode;

    // TODO: Uncomment when GPS location is needed
    // Add location if provided
    // if (location != null) {
    //   data['location'] = location!.toJson();
    // }

    // ✅ CRITICAL FIX: Only add OTP if provided AND not null/empty
    // When mobileNumber == masterMobileNumber, otp will be null (don't send it)
    // When mobileNumber != masterMobileNumber, otp will be the verified OTP (send it)
    if (otp != null && otp!.isNotEmpty) {
      data['otp'] = otp;
    }

    return data;
  }

  // Create model from JSON response
  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    return MerchantModel(
      merchantName: json['merchantName'] ?? '',
      businessName: json['businessName'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      area: json['area'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? 'INDIA',
      pinCode: json['pinCode'] ?? '',
      location: json['location'] != null
          ? MerchantLocation.fromJson(json['location'])
          : null,
      masterMobileNumber: json['masterMobileNumber'] ?? '',
      otp: json['otp'],
    );
  }

  // Copy with method for easy updates
  MerchantModel copyWith({
    String? merchantName,
    String? businessName,
    String? mobileNumber,
    String? address,
    String? city,
    String? area,
    String? state,
    String? country,
    String? pinCode,
    MerchantLocation? location,
    String? masterMobileNumber,
    String? otp,
  }) {
    return MerchantModel(
      merchantName: merchantName ?? this.merchantName,
      businessName: businessName ?? this.businessName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      area: area ?? this.area,
      state: state ?? this.state,
      country: country ?? this.country,
      pinCode: pinCode ?? this.pinCode,
      location: location ?? this.location,
      masterMobileNumber: masterMobileNumber ?? this.masterMobileNumber,
      otp: otp ?? this.otp,
    );
  }

  @override
  String toString() {
    return 'MerchantModel(merchantName: $merchantName, mobileNumber: $mobileNumber, masterMobileNumber: $masterMobileNumber)';
  }
}

// Location model for GPS coordinates
class MerchantLocation {
  final double latitude;
  final double longitude;

  MerchantLocation({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory MerchantLocation.fromJson(Map<String, dynamic> json) {
    return MerchantLocation(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }

  @override
  String toString() {
    return 'MerchantLocation(latitude: $latitude, longitude: $longitude)';
  }
}
