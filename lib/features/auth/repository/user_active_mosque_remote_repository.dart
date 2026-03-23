import 'package:cloud_firestore/cloud_firestore.dart';

/// جلب `active_mosque_id` من Firestore — يتطلب اتصالاً و [uid] صالحاً.
class UserActiveMosqueRemoteRepository {
  UserActiveMosqueRemoteRepository._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// يعيد `null` إن لم يوجد المستند أو الحقل أو حدث خطأ.
  static Future<String?> fetchActiveMosqueId(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    final data = doc.data()!;
    final id = data['active_mosque_id'];
    if (id is String && id.isNotEmpty) return id;
    return null;
  }
}
