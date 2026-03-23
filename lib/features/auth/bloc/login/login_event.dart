abstract class LoginEvent {}

/// تعديل البريد في نموذج الطلب
class UpdateEmail extends LoginEvent {
  final String email;

  UpdateEmail(this.email);
}

/// تعديل كلمة المرور في نموذج الطلب
class UpdatePassword extends LoginEvent {
  final String password;

  UpdatePassword(this.password);
}

/// تعديل رمز الجهاز في نموذج الطلب
class UpdateDeviceToken extends LoginEvent {
  final String deviceToken;

  UpdateDeviceToken(this.deviceToken);
}

/// إرسال طلب تسجيل الدخول
class SendLoginRequest extends LoginEvent {
  SendLoginRequest();
}

/// إعادة تعيين الحالة
class ResetState extends LoginEvent {
  ResetState();
}
