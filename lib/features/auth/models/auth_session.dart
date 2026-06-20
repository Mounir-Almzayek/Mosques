import 'package:equatable/equatable.dart';

import 'auth_user.dart';

/// Replacement for `firebase_auth.UserCredential`.
///
/// Returned by [IAuthRepository.login] so call sites can read `session.user`
/// the same way they used to read `credential.user`.
class AuthSession extends Equatable {
  final AuthUser user;
  final String accessToken;
  final String refreshToken;
  final int? expiresInSeconds;

  /// Active mosque the backend selected at login (if any).
  final Map<String, dynamic>? activeMosque;

  /// All mosques the user has access to.
  final List<Map<String, dynamic>> mosques;

  /// Permission keys the backend granted.
  final List<String> permissions;

  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.expiresInSeconds,
    this.activeMosque,
    this.mosques = const [],
    this.permissions = const [],
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final userJson = (json['user'] as Map?)?.cast<String, dynamic>() ?? {};
    final mosquesJson = (json['mosques'] as List?) ?? const [];
    final permsJson = (json['permissions'] as List?) ?? const [];
    return AuthSession(
      user: AuthUser.fromJson(userJson),
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      expiresInSeconds: (json['expiresInSeconds'] as num?)?.toInt(),
      activeMosque: (json['activeMosque'] as Map?)?.cast<String, dynamic>(),
      mosques: mosquesJson
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      permissions: permsJson.map((e) => e.toString()).toList(),
    );
  }

  @override
  List<Object?> get props => [
        user,
        accessToken,
        refreshToken,
        expiresInSeconds,
        activeMosque,
        mosques,
        permissions,
      ];
}
