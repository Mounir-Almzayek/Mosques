import 'package:equatable/equatable.dart';

/// نتيجة نجاح تسجيل الدخول (مستقلة عن استجابة REST إن وُجدت لاحقاً).
class LoginSuccessResponse extends Equatable {
  final String uid;
  final String message;

  const LoginSuccessResponse({
    required this.uid,
    required this.message,
  });

  @override
  List<Object?> get props => [uid, message];
}
