import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/realtime/snapshot_sync.dart';
import '../../core/services/api_exception.dart';
import '../../core/services/api_service.dart';
import '../models/mosque/mosque_bootstrap.dart';

/// HTTP + WebSocket access to a mosque's data, returning typed
/// [MosqueBootstrap] models directly (no document/adapter layer).
///
/// Reads: `GET /mobile/mosques/{id}/bootstrap` for the initial snapshot, then
/// the public display WebSocket (`/display/mosques/{slug}/ws`) for live
/// updates. Writes: one typed method per backend route.
class MosqueRemoteDataSource {
  final ApiService _api;
  final SnapshotSync _sync;

  /// publicSlug by mosque id, learned from the bootstrap payload so the WS can
  /// join the live channel.
  final Map<String, String> _slugById = {};

  MosqueRemoteDataSource({
    required ApiService api,
    required SnapshotSync sync,
  })  : _api = api,
        _sync = sync;

  // ---------------------------------------------------------------------------
  // Reads
  // ---------------------------------------------------------------------------

  Future<MosqueBootstrap?> fetchBootstrap(String mosqueId) async {
    if (mosqueId.isEmpty) return null;
    try {
      final raw = await _api.get(ApiEndpoints.mosqueBootstrap(mosqueId));
      final bootstrap = MosqueBootstrap.fromJson(raw);
      if (bootstrap.mosque.publicSlug.isNotEmpty) {
        _slugById[mosqueId] = bootstrap.mosque.publicSlug;
      }
      return bootstrap;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Live stream: emits the HTTP bootstrap first, then every WebSocket snapshot.
  Stream<MosqueBootstrap?> watchBootstrap(String mosqueId) {
    if (mosqueId.isEmpty) return Stream.value(null);

    final controller = StreamController<MosqueBootstrap?>();
    StreamSubscription<Map<String, dynamic>>? wsSub;

    controller.onCancel = () async {
      await wsSub?.cancel();
      final slug = _slugById[mosqueId];
      if (slug != null) await _sync.close(slug);
    };

    () async {
      MosqueBootstrap? bootstrap;
      try {
        bootstrap = await fetchBootstrap(mosqueId);
        if (!controller.isClosed) controller.add(bootstrap);
      } catch (e, st) {
        if (!controller.isClosed) controller.addError(e, st);
      }

      final slug = _slugById[mosqueId];
      if (slug == null || slug.isEmpty) {
        if (kDebugMode) {
          debugPrint('MosqueRemoteDataSource: no slug for $mosqueId; no WS');
        }
        return;
      }

      wsSub = _sync.watch(slug).listen(
        (snapshot) {
          // The WS snapshot omits legacyCompatibility; preserve the id we
          // already know from the HTTP bootstrap.
          final merged = MosqueBootstrap.fromJson(snapshot).copyWith(
            firestoreDocumentId: bootstrap?.firestoreDocumentId,
          );
          if (!controller.isClosed) controller.add(merged);
        },
        onError: (Object error) {
          if (kDebugMode) {
            debugPrint('MosqueRemoteDataSource WS error: $error');
          }
        },
      );
    }();

    return controller.stream;
  }

  // ---------------------------------------------------------------------------
  // Writes
  // ---------------------------------------------------------------------------

  /// Top-level mosque profile fields (name, city, lat/long, languageCode, …).
  Future<void> patchMosque(String mosqueId, Map<String, dynamic> fields) async {
    if (fields.isEmpty) return;
    await _api.patch(ApiEndpoints.mosque(mosqueId), body: fields);
  }

  Future<void> putPrayerSettings(
    String mosqueId,
    PrayerSettings settings,
  ) async {
    await _api.put(
      ApiEndpoints.mosquePrayerSettings(mosqueId),
      body: settings.toRequestBody(),
    );
  }

  Future<void> putDisplaySettings(
    String mosqueId,
    DisplaySettings settings,
  ) async {
    await _api.put(
      ApiEndpoints.mosqueDisplaySettings(mosqueId),
      body: settings.toRequestBody(),
    );
  }

  /// Religious content is replaced wholesale, grouped by kind.
  Future<void> putReligiousContent(
    String mosqueId,
    List<ContentItem> content,
  ) async {
    final grouped = <String, List<Map<String, dynamic>>>{
      'hadiths': [],
      'verses': [],
      'duas': [],
      'adhkar': [],
    };
    for (final item in content) {
      final entry = item.toReligiousRequestItem();
      switch (item.kind) {
        case 'hadith':
          grouped['hadiths']!.add(entry);
          break;
        case 'ayah':
        case 'verse':
          grouped['verses']!.add(entry);
          break;
        case 'dua':
          grouped['duas']!.add(entry);
          break;
        case 'dhikr':
        case 'adhkar':
          grouped['adhkar']!.add(entry);
          break;
      }
    }
    await _api.put(
      ApiEndpoints.mosqueReligiousContent(mosqueId),
      body: grouped,
    );
  }

  /// Diffs [previous] against [next] for a single `announcementType` and emits
  /// the per-entry create/update/delete calls the backend supports.
  Future<void> reconcileAnnouncements(
    String mosqueId, {
    required String announcementType,
    required List<Announcement> previous,
    required List<Announcement> next,
  }) async {
    final previousById = <String, Announcement>{};
    for (final a in previous) {
      if (a.id.isNotEmpty) previousById[a.id] = a;
    }

    final seen = <String>{};
    for (final entry in next) {
      final body = entry
          .copyWith(announcementType: announcementType, audience: 'display')
          .toRequestBody();
      if (entry.id.isEmpty || !previousById.containsKey(entry.id)) {
        await _api.post(ApiEndpoints.mosqueAnnouncements(mosqueId), body: body);
        continue;
      }
      seen.add(entry.id);
      if (_changed(previousById[entry.id]!, entry)) {
        await _api.patch(
          ApiEndpoints.mosqueAnnouncement(mosqueId, entry.id),
          body: body,
        );
      }
    }

    for (final id in previousById.keys) {
      if (seen.contains(id)) continue;
      try {
        await _api.delete(ApiEndpoints.mosqueAnnouncement(mosqueId, id));
      } catch (e) {
        if (kDebugMode) debugPrint('Delete announcement $id failed: $e');
      }
    }
  }

  bool _changed(Announcement a, Announcement b) {
    return a.title != b.title ||
        a.subtitle != b.subtitle ||
        a.startAt != b.startAt ||
        a.endAt != b.endAt ||
        a.qrCodeUrl != b.qrCodeUrl ||
        a.isActive != b.isActive ||
        a.isPriority != b.isPriority ||
        a.displayDurationSeconds != b.displayDurationSeconds ||
        a.displayOrder != b.displayOrder;
  }
}
