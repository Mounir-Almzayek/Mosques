class LoginData {
  final String token;

  LoginData({required this.token});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    // Support both 'token' and 'accessToken' (web uses accessToken)
    final token = json['token'] ?? json['accessToken'] ?? '';
    return LoginData(token: token);
  }

  Map<String, dynamic> toJson() {
    return {'token': token};
  }
}
