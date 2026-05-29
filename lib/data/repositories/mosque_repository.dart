import 'dart:async';

import '../../core/cache/cache.dart';
import '../../core/constants/firestore_schema.dart';
import '../../core/enums/app_language.dart';
import '../../core/realtime/realtime_transport.dart';
import '../../core/realtime/remote_field_value.dart';
import '../models/mosque/mosque_model.dart';
import 'interfaces/mosque_repository_interface.dart';

class MosqueRepository implements IMosqueRepository {
  final RealtimeTransport _transport;
  final String? Function() _getActiveMosqueId;
  final Future<void> Function(String) _syncActiveMosque;
  final JsonCache<MosqueModel> _cache;
  final CacheFirstLoader<MosqueModel> _loader;

  MosqueRepository({
    required RealtimeTransport transport,
    required String? Function() getActiveMosqueId,
    required Future<void> Function(String) syncActiveMosque,
    required JsonCache<MosqueModel> cache,
    ImageSyncService? imageSync,
  })  : _transport = transport,
        _getActiveMosqueId = getActiveMosqueId,
        _syncActiveMosque = syncActiveMosque,
        _cache = cache,
        _loader = CacheFirstLoader<MosqueModel>(
          cache,
          onValue: imageSync?.syncMosque,
        );

  String _collection() => FirestoreSchema.mosquesCollection;

  /// Active mosque id, or null when none is selected.
  String? get _activeId {
    final id = _getActiveMosqueId();
    return (id == null || id.isEmpty) ? null : id;
  }

  String _requireActiveId() {
    final id = _activeId;
    if (id == null) throw Exception('No active mosque');
    return id;
  }

  @override
  Stream<MosqueModel?> get streamActiveMosque =>
      _loader.stream(remote: _remoteStream);

  Stream<MosqueModel?> _remoteStream() {
    final id = _activeId;
    if (id == null) return Stream.value(null);
    return _transport.watchDocument(_collection(), id).map(
          (doc) =>
              doc == null ? null : MosqueModel.fromMap(doc.data, doc.id),
        );
  }

  @override
  Future<MosqueModel?> getActiveMosque() async {
    final uid = _activeId;
    if (uid != null) await _syncActiveMosque(uid);
    return _loader.once(remote: () async {
      final id = _activeId;
      if (id == null) return null;
      final doc = await _transport.getDocument(_collection(), id);
      return doc == null ? null : MosqueModel.fromMap(doc.data, doc.id);
    }).last;
  }

  @override
  Future<MosqueModel?> fetchActiveMosqueFromServer() async {
    final uid = _activeId;
    if (uid != null) await _syncActiveMosque(uid);
    if (uid == null) return null;

    try {
      final doc = await _transport.getDocument(
        _collection(),
        uid,
        serverOnly: true,
      );
      if (doc == null) return null;
      final mosque = MosqueModel.fromMap(doc.data, doc.id);
      await _cache.save(mosque);
      return mosque;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateMosque(MosqueModel mosque) async {
    final id = _requireActiveId();
    final data = mosque.toMap();
    data[FirestoreSchema.updatedAt] = RemoteFieldValue.serverTimestamp;
    data[FirestoreSchema.lastSeen] = RemoteFieldValue.serverTimestamp;
    // Drop legacy logo URL (no longer using Firebase Storage for logos)
    data[FirestoreSchema.logoUrl] = RemoteFieldValue.delete;
    // Drop legacy album fields (migration safety)
    data['photo_studio_urls'] = RemoteFieldValue.delete;
    data['background_album_urls'] = RemoteFieldValue.delete;
    await _transport.setDocument(_collection(), id, data, merge: true);
  }

  @override
  Future<void> updateDesignSettings(MosqueModel mosque) async {
    await _transport.updateDocument(_collection(), _requireActiveId(), {
      FirestoreSchema.designSettings: mosque.designSettings.toMap(),
      FirestoreSchema.updatedAt: RemoteFieldValue.serverTimestamp,
      FirestoreSchema.lastSeen: RemoteFieldValue.serverTimestamp,
    });
  }

  @override
  Future<void> updateLanguageCode(AppLanguage language) async {
    await _transport.updateDocument(_collection(), _requireActiveId(), {
      FirestoreSchema.languageCode: language.code,
      FirestoreSchema.updatedAt: RemoteFieldValue.serverTimestamp,
      FirestoreSchema.lastSeen: RemoteFieldValue.serverTimestamp,
    });
  }

  @override
  Future<void> updateIqamaSettings(MosqueModel mosque) async {
    await _transport.updateDocument(_collection(), _requireActiveId(), {
      FirestoreSchema.iqamaOffsets: mosque.iqamaSettings.toMap(),
      FirestoreSchema.updatedAt: RemoteFieldValue.serverTimestamp,
      FirestoreSchema.lastSeen: RemoteFieldValue.serverTimestamp,
    });
  }

  @override
  Future<void> updateMosqueTextList(
    MosqueModel mosque,
    MosqueTextListKind kind,
  ) async {
    final field = switch (kind) {
      MosqueTextListKind.hadith => FirestoreSchema.hadiths,
      MosqueTextListKind.verse => FirestoreSchema.verses,
      MosqueTextListKind.dua => FirestoreSchema.duas,
      MosqueTextListKind.adhkar => FirestoreSchema.adhkar,
    };
    final list = mosque.listByKind(kind).map((e) => e.toMap()).toList();

    await _transport.updateDocument(_collection(), _requireActiveId(), {
      field: list,
      FirestoreSchema.updatedAt: RemoteFieldValue.serverTimestamp,
      FirestoreSchema.lastSeen: RemoteFieldValue.serverTimestamp,
    });
  }

  @override
  Future<void> updateAnnouncements(MosqueModel mosque) async {
    await _transport.updateDocument(_collection(), _requireActiveId(), {
      FirestoreSchema.mosqueAds:
          mosque.announcements.map((a) => a.toMap()).toList(),
      FirestoreSchema.updatedAt: RemoteFieldValue.serverTimestamp,
      FirestoreSchema.lastSeen: RemoteFieldValue.serverTimestamp,
    });
  }

  @override
  Future<void> updateActiveAlerts(MosqueModel mosque) async {
    await _transport.updateDocument(_collection(), _requireActiveId(), {
      FirestoreSchema.activeAlerts:
          mosque.savedAlerts.map((a) => a.toMap()).toList(),
      FirestoreSchema.updatedAt: RemoteFieldValue.serverTimestamp,
      FirestoreSchema.lastSeen: RemoteFieldValue.serverTimestamp,
    });
  }

  @override
  Future<void> updateLastSeen() async {
    final id = _activeId;
    if (id == null) return;
    await _transport.updateDocument(_collection(), id, {
      FirestoreSchema.lastSeen: RemoteFieldValue.serverTimestamp,
    });
  }
}
