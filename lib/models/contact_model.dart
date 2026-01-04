import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:azlistview/azlistview.dart';

/// Contact model for share functionality and contact management
/// This model will be used for API integration in the future
/// Extends ISuspensionBean for AzListView support
class ContactItem extends ISuspensionBean {
  final String? id;
  final String name;
  final String phone;
  final String initials;
  final String? email;
  final String? avatarUrl;
  final bool? isOnline;
  final DateTime? lastSeen;
  final Map<String, dynamic>? additionalData;

  // ✅ AzListView support: Tag index for alphabet sections (A, B, C, etc.)
  String tagIndex = '#';

  ContactItem({
    this.id,
    required this.name,
    required this.phone,
    required this.initials,
    this.email,
    this.avatarUrl,
    this.isOnline,
    this.lastSeen,
    this.additionalData,
  });

  /// Create ContactItem from API JSON response
  factory ContactItem.fromJson(Map<String, dynamic> json) {
    return ContactItem(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      initials: json['initials'] ?? _generateInitials(json['name'] ?? ''),
      email: json['email'],
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
      isOnline: json['is_online'] ?? json['isOnline'],
      lastSeen: json['last_seen'] != null 
          ? DateTime.tryParse(json['last_seen']) 
          : null,
      additionalData: json['additional_data'] ?? json['additionalData'],
    );
  }

  /// Convert ContactItem to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'initials': initials,
      'email': email,
      'avatar_url': avatarUrl,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
      'additional_data': additionalData,
    };
  }

  /// Generate initials from name
  static String _generateInitials(String name) {
    if (name.isEmpty) return '';
    
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    } else {
      return words.take(2)
          .map((word) => word.substring(0, 1).toUpperCase())
          .join();
    }
  }

  /// Create a copy with modified values
  ContactItem copyWith({
    String? id,
    String? name,
    String? phone,
    String? initials,
    String? email,
    String? avatarUrl,
    bool? isOnline,
    DateTime? lastSeen,
    Map<String, dynamic>? additionalData,
  }) {
    return ContactItem(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      initials: initials ?? this.initials,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  /// Get formatted display name
  String get displayName => name.isNotEmpty ? name : phone;

  /// Get formatted phone for display
  String get formattedPhone {
    if (phone.startsWith('+91')) {
      return phone;
    } else if (phone.startsWith('91') && phone.length == 12) {
      return '+$phone';
    } else if (phone.length == 10) {
      return '+91-$phone';
    }
    return phone;
  }

  /// Check if contact has profile image
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  /// Get online status text
  String get onlineStatus {
    if (isOnline == true) return 'Online';
    if (lastSeen != null) {
      final now = DateTime.now();
      final difference = now.difference(lastSeen!);
      
      if (difference.inMinutes < 1) return 'Just now';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      if (difference.inDays < 7) return '${difference.inDays}d ago';
      return 'Last seen ${difference.inDays}d ago';
    }
    return 'Offline';
  }

  @override
  String toString() {
    return 'ContactItem(id: $id, name: $name, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContactItem &&
        other.id == id &&
        other.name == name &&
        other.phone == phone;
  }

  @override
  int get hashCode => Object.hash(id, name, phone);

  // ✅ AzListView implementation: Return the tag for alphabet sections
  @override
  String getSuspensionTag() => tagIndex;
}
