import 'package:equatable/equatable.dart';

/// Replacement for `firebase_auth.User`.
///
/// Carries only the data the app actually reads after login: identity,
/// contact details, the active mosque id, and the first-login flag.
class AuthUser extends Equatable {
  /// Backend user UUID. Plays the role of the old `User.uid`.
  final String id;
  final String email;
  final String? phone;
  final String? fullName;
  final String? activeMosqueId;
  final bool isActive;
  final bool passwordChangeRequired;
  final DateTime? createdAt;

  const AuthUser({
    required this.id,
    required this.email,
    this.phone,
    this.fullName,
    this.activeMosqueId,
    this.isActive = true,
    this.passwordChangeRequired = false,
    this.createdAt,
  });

  /// Backwards-compatible getter so call sites using the firebase_auth API
  /// (`user.uid`) keep building unchanged.
  String get uid => id;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      fullName: json['fullName']?.toString(),
      activeMosqueId: json['activeMosqueId']?.toString(),
      isActive: json['isActive'] != false,
      passwordChangeRequired: json['passwordChangeRequired'] == true,
      createdAt: json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        if (phone != null) 'phone': phone,
        if (fullName != null) 'fullName': fullName,
        if (activeMosqueId != null) 'activeMosqueId': activeMosqueId,
        'isActive': isActive,
        'passwordChangeRequired': passwordChangeRequired,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  AuthUser copyWith({
    String? email,
    String? phone,
    String? fullName,
    String? activeMosqueId,
    bool? isActive,
    bool? passwordChangeRequired,
  }) {
    return AuthUser(
      id: id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      activeMosqueId: activeMosqueId ?? this.activeMosqueId,
      isActive: isActive ?? this.isActive,
      passwordChangeRequired:
          passwordChangeRequired ?? this.passwordChangeRequired,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        phone,
        fullName,
        activeMosqueId,
        isActive,
        passwordChangeRequired,
        createdAt,
      ];
}
