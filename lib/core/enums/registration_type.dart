/// يمثل أنواع التسجيل المتاحة للمستخدم الجديد.
enum RegistrationType {
  /// إنشاء جامع جديد تماماً برمز تعريف فريد.
  newMosque,

  /// الربط بجامع موجود مسبقاً (يتطلب تواصل مع الدعم الفني).
  existingMosque;

  bool get isNew => this == RegistrationType.newMosque;
  bool get isExisting => this == RegistrationType.existingMosque;
}
