/// Logout Response Model
/// Represents the response from logout API
class LogoutResponse {
  final String? message;
  final bool success;

  LogoutResponse({
    this.message,
    required this.success,
  });

  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(
      message: json['message'] as String?,
      success: json['success'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
    };
  }
}
