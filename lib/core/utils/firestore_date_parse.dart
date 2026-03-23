import 'package:cloud_firestore/cloud_firestore.dart';

/// يدعم [Timestamp] من Firestore وأرقام الميلي ثانية المحفوظة في Hive.
DateTime? parseFirestoreOrMillis(dynamic v) {
  if (v == null) return null;
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
  if (v is double) return DateTime.fromMillisecondsSinceEpoch(v.round());
  return null;
}
