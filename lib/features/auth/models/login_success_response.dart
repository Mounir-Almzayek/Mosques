import 'package:equatable/equatable.dart';

/// نتيجة نجاح تسجيل الدخول (مستقلة عن استجابة REST إن وُجدت لاحقاً).
class LoginSuccessResponse extends Equatable {
  final String uid;
  final String message;
  final bool passwordChangeRequired;

  const LoginSuccessResponse({
    required this.uid,
    required this.message,
    this.passwordChangeRequired = false,
  });

  @override
  List<Object?> get props => [uid, message, passwordChangeRequired];
}
