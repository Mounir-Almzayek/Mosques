import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../../core/cache/cache.dart';
import '../../core/constants/firestore_schema.dart';
import '../../core/enums/app_language.dart';
import '../models/mosque/mosque_model.dart';
import 'interfaces/mosque_repository_interface.dart';

class MosqueRepository implements IMosqueRepository {
  final FirebaseFirestore? _firestore;
  final String? Function()? _getActiveMosqueId;
  final Future<void> Function(String)? _syncActiveMosque;
  final JsonCache<MosqueModel> _cache;
  final CacheFirstLoader<MosqueModel> _loader;
  final Stream<MosqueModel?> Function()? _remoteStreamOverride;

  MosqueRepository({
    required FirebaseFirestore firestore,
    required String? Function() getActiveMosqueId,
    required Future<void> Function(String) syncActiveMosque,
    required JsonCache<MosqueModel> cache,
    ImageSyncService? imageSync,
  })  : _firestore = firestore,
        _getActiveMosqueId = getActiveMosqueId,
        _syncActiveMosque = syncActiveMosque,
        _cache = cache,
        _remoteStreamOverride = null,
        _loader = CacheFirstLoader<MosqueModel>(
          cache,
          onValue: imageSync?.syncMosque,
        );

  MosqueRepository.forTest({
    required JsonCache<MosqueModel> cache,
    Stream<MosqueModel?> Function()? remoteStream,
  })  : _firestore = null,
        _getActiveMosqueId = null,
        _syncActiveMosque = null,
        _cache = cache,
        _remoteStreamOverride = remoteStream,
        _loader = CacheFirstLoader<MosqueModel>(cache);

  /// Reference to the active mosque document
  DocumentReference? get _mosqueRef {
    if (_firestore == null) return null;
    final id = _getActiveMosqueId!();
    if (id == null || id.isEmpty) return null;
    return _firestore.collection(FirestoreSchema.mosquesCollection).doc(id);
  }

  @override
  Stream<MosqueModel?> get streamActiveMosque =>
      _loader.stream(remote: _remoteStreamOverride ?? _firestoreSnapshots);

  Stream<MosqueModel?> _firestoreSnapshots() {
    final ref = _mosqueRef;
    if (ref == null) return Stream.value(null);
    return ref.snapshots().map((doc) =>
        (!doc.exists || doc.data() == null)
            ? null
            : MosqueModel.fromMap(doc.data()! as Map<String, dynamic>, doc.id));
  }

  /// Get the active mosque data
  @override
  Future<MosqueModel?> getActiveMosque() async {
    final uid = _getActiveMosqueId?.call();
    if (uid != null) await _syncActiveMosque!(uid);
    return _loader.once(remote: () async {
      final ref = _mosqueRef;
      if (ref == null) return null;
      final doc = await ref.get();
      if (!doc.exists || doc.data() == null) return null;
      return MosqueModel.fromMap(doc.data()! as Map<String, dynamic>, doc.id);
    }).last;
  }

  @override
  Future<MosqueModel?> fetchActiveMosqueFromServer() async {
    final uid = _getActiveMosqueId?.call();
    if (uid != null) {
      await _syncActiveMosque!(uid);
    }

    final ref = _mosqueRef;
    if (ref == null) return null;

    try {
      final doc = await ref.get(const GetOptions(source: Source.server));
      if (!doc.exists || doc.data() == null) return null;
      final mosque = MosqueModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
      await _cache.save(mosque);
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
    // Drop legacy album fields (migration safety)
    data['photo_studio_urls'] = FieldValue.delete();
    data['background_album_urls'] = FieldValue.delete();
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
  Future<void> updateMosqueTextList(
    MosqueModel mosque,
    MosqueTextListKind kind,
  ) async {
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
      FirestoreSchema.mosqueAds: mosque.announcements
          .map((a) => a.toMap())
          .toList(),
      FirestoreSchema.updatedAt: FieldValue.serverTimestamp(),
      FirestoreSchema.lastSeen: FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateActiveAlerts(MosqueModel mosque) async {
    final ref = _mosqueRef;
    if (ref == null) throw Exception('No active mosque');

    await ref.update({
      FirestoreSchema.activeAlerts: mosque.savedAlerts
          .map((a) => a.toMap())
          .toList(),
      FirestoreSchema.updatedAt: FieldValue.serverTimestamp(),
      FirestoreSchema.lastSeen: FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateLastSeen() async {
    final ref = _mosqueRef;
    if (ref == null) return;

    await ref.update({FirestoreSchema.lastSeen: FieldValue.serverTimestamp()});
  }
}
