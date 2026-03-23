import 'login_data.dart';

class LoginResponse {
  final bool status;
  final LoginData? data;
  final String message;

  LoginResponse({required this.status, this.data, required this.message});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] ?? false,
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'data': data?.toJson(), 'message': message};
  }
}
