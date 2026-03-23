class LoginRequest {
  String email;
  String password;
  String deviceToken;

  LoginRequest({
    this.email = '',
    this.password = '',
    this.deviceToken = '',
  });

  /// Create a copy of LoginRequest with updated fields
  LoginRequest copyWith({
    String? email,
    String? password,
    String? deviceToken,
  }) {
    return LoginRequest(
      email: email ?? this.email,
      password: password ?? this.password,
      deviceToken: deviceToken ?? this.deviceToken,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'device_token': deviceToken,
    };
  }
}
