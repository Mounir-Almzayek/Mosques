import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../../core/constants/firestore_schema.dart';
import '../../core/enums/app_language.dart';
import '../models/mosque/mosque_model.dart';
import 'interfaces/mosque_repository_interface.dart';
import 'mosque_local_repository.dart';

class MosqueRepository implements IMosqueRepository {
  final FirebaseFirestore _firestore;
  final String? Function() _getActiveMosqueId;
  final Future<void> Function(String) _syncActiveMosque;

  MosqueRepository({
    required FirebaseFirestore firestore,
    required String? Function() getActiveMosqueId,
    required Future<void> Function(String) syncActiveMosque,
  })  : _firestore = firestore,
        _getActiveMosqueId = getActiveMosqueId,
        _syncActiveMosque = syncActiveMosque;

  /// Reference to the active mosque document
  DocumentReference? get _mosqueRef {
    final id = _getActiveMosqueId();
    if (id == null || id.isEmpty) return null;
    return _firestore.collection(FirestoreSchema.mosquesCollection).doc(id);
  }

  /// Get the active mosque data
  @override
  Future<MosqueModel?> getActiveMosque() async {
    final uid = _getActiveMosqueId();
    if (uid != null) {
      await _syncActiveMosque(uid);
    }

    final ref = _mosqueRef;
    if (ref == null) return null;

    try {
      final doc = await ref.get();
      if (!doc.exists || doc.data() == null) {
        return MosqueLocalRepository.getCachedForActiveMosque();
      }

      final mosque =
          MosqueModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      await MosqueLocalRepository.saveMosque(mosque);
      return mosque;
    } catch (_) {
      return MosqueLocalRepository.getCachedForActiveMosque();
    }
  }

  @override
  Future<MosqueModel?> fetchActiveMosqueFromServer() async {
    final uid = _getActiveMosqueId();
    if (uid != null) {
      await _syncActiveMosque(uid);
    }

    final ref = _mosqueRef;
    if (ref == null) return null;

    try {
      final doc = await ref.get(const GetOptions(source: Source.server));
      if (!doc.exists || doc.data() == null) return null;
      final mosque =
          MosqueModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      await MosqueLocalRepository.saveMosque(mosque);
      return mosque;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateMosque(MosqueModel mosque) async {
    final ref = _mosqueRef;
    if (ref == null) throw Exception('No active mosque');

    final data = mosque.toMap();
    data[FirestoreSchema.updatedAt] = FieldValue.serverTimestamp();
    data[FirestoreSchema.lastSeen] = FieldValue.serverTimestamp();
    // Drop legacy logo URL (no longer using Firebase Storage for logos)
    data[FirestoreSchema.logoUrl] = FieldValue.delete();
    await ref.set(data, SetOptions(merge: true));
  }

  @override
  Future<void> updateDesignSettings(MosqueModel mosque) async {
    final ref = _mosqueRef;
    if (ref == null) throw Exception('No active mosque');

    await ref.update({
      FirestoreSchema.designSettings: mosque.designSettings.toMap(),
      FirestoreSchema.updatedAt: FieldValue.serverTimestamp(),
      FirestoreSchema.lastSeen: FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateLanguageCode(AppLanguage language) async {
    final ref = _mosqueRef;
    if (ref == null) throw Exception('No active mosque');

    await ref.update({
      FirestoreSchema.languageCode: language.code,
      FirestoreSchema.updatedAt: FieldValue.serverTimestamp(),
      FirestoreSchema.lastSeen: FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateIqamaSettings(MosqueModel mosque) async {
    final ref = _mosqueRef;
    if (ref == null) throw Exception('No active mosque');

    await ref.update({
      FirestoreSchema.iqamaOffsets: mosque.iqamaSettings.toMap(),
      FirestoreSchema.updatedAt: FieldValue.serverTimestamp(),
      FirestoreSchema.lastSeen: FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateMosqueTextList(MosqueModel mosque, MosqueTextListKind kind) async {
    final ref = _mosqueRef;
    if (ref == null) throw Exception('No active mosque');

    final field = switch (kind) {
      MosqueTextListKind.hadith => FirestoreSchema.hadiths,
      MosqueTextListKind.verse => FirestoreSchema.verses,
      MosqueTextListKind.dua => FirestoreSchema.duas,
      MosqueTextListKind.adhkar => FirestoreSchema.adhkar,
    };
    final list = mosque.listByKind(kind).map((e) => e.toMap()).toList();

    await ref.update({
      field: list,
      FirestoreSchema.updatedAt: FieldValue.serverTimestamp(),
      FirestoreSchema.lastSeen: FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateAnnouncements(MosqueModel mosque) async {
    final ref = _mosqueRef;
    if (ref == null) throw Exception('No active mosque');

    await ref.update({
      FirestoreSchema.mosqueAds: mosque.announcements.map((a) => a.toMap()).toList(),
      FirestoreSchema.updatedAt: FieldValue.serverTimestamp(),
      FirestoreSchema.lastSeen: FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateActiveAlerts(MosqueModel mosque) async {
    final ref = _mosqueRef;
    if (ref == null) throw Exception('No active mosque');

    await ref.update({
      FirestoreSchema.activeAlerts: mosque.activeAlerts.map((a) => a.toMap()).toList(),
      FirestoreSchema.updatedAt: FieldValue.serverTimestamp(),
      FirestoreSchema.lastSeen: FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateLastSeen() async {
    final ref = _mosqueRef;
    if (ref == null) return;

    await ref.update({
      FirestoreSchema.lastSeen: FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<MosqueModel?> get streamActiveMosque {
    final ref = _mosqueRef;
    if (ref == null) return Stream.value(null);

    return Stream<MosqueModel?>.multi((controller) {
      final sub = ref.snapshots().listen(
        (doc) async {
          if (!doc.exists || doc.data() == null) {
            controller.add(null);
            return;
          }
          final mosque =
              MosqueModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          await MosqueLocalRepository.saveMosque(mosque);
          controller.add(mosque);
        },
        onError: (error, stackTrace) async {
          final cached = await MosqueLocalRepository.getCachedForActiveMosque();
          if (cached != null) {
            controller.add(cached);
            return;
          }
          controller.addError(error, stackTrace);
        },
      );

      controller.onCancel = () => sub.cancel();
    });
  }
}
