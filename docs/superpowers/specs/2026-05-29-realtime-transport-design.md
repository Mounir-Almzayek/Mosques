# RealtimeTransport Layer — Design Spec

**Date:** 2026-05-29
**Status:** Approved (Approach A), implementing.

## Goal

Make the real-time data layer an excellent, clean, maintainable structure. All
`cloud_firestore` usage in the three real-time repositories is isolated behind a
single transport interface, so the repos hold only domain logic. Swapping the
backend later (e.g. WebSocket) means writing one new class, touching no repo,
model, BLoC, or widget. Transport-swappability is a *consequence* of the clean
boundary, not the primary aim.

## Non-goals

- Not abandoning Firestore. Firestore remains the live backend.
- Not migrating auth (`auth_repository`, `user_active_mosque_*`) — a separate
  bounded concern that uses Firestore for user docs. Out of scope.
- No new caching/offline behavior. `CacheFirstLoader` is unchanged.

## The neutral boundary

The transport contract uses **only plain Dart types**: `String`, `num`, `bool`,
`DateTime`, `List`, `Map`, plus `RemoteFieldValue` write sentinels. **No Firestore
type crosses the boundary.** A half-abstraction that leaks `Timestamp` would give
a false sense of decoupling, so dates are normalized at the boundary.

### New module: `lib/core/realtime/`

- `remote_field_value.dart` — `enum RemoteFieldValue { serverTimestamp, delete }`
  Transport-neutral write sentinels.
- `remote_document.dart` — `class RemoteDocument { final String id; final Map<String, dynamic> data; }`
  A `null` document means "absent / does not exist" (replaces `doc.exists` checks).
- `realtime_transport.dart` — the interface:
  ```dart
  abstract interface class RealtimeTransport {
    Stream<RemoteDocument?> watchDocument(String collection, String id);
    Stream<List<RemoteDocument>> watchCollection(String collection);
    Future<RemoteDocument?> getDocument(String collection, String id, {bool serverOnly = false});
    Future<List<RemoteDocument>> getCollection(String collection, {bool serverOnly = false});
    Future<void> setDocument(String collection, String id, Map<String, dynamic> data, {bool merge = false});
    Future<void> updateDocument(String collection, String id, Map<String, dynamic> data);
  }
  ```
- `firestore_transport.dart` — the **only** file importing `cloud_firestore`.
  Implements the interface. Deep-converts both directions:
  - **read (`_decode`):** `Timestamp` → `DateTime`, recursively through maps/lists.
  - **write (`_encode`):** `DateTime` → `Timestamp`, `RemoteFieldValue.serverTimestamp`
    → `FieldValue.serverTimestamp()`, `RemoteFieldValue.delete` → `FieldValue.delete()`,
    recursively. `serverOnly` → `GetOptions(source: Source.server)`.

## Repository refactor (3 repos)

Each repo drops its `FirebaseFirestore?` field, its `_firestore*Stream`/`_mosqueRef`
helpers, and the `.forTest` constructor + `_remoteStreamOverride`. A single
constructor now takes `RealtimeTransport transport`. Public interfaces and method
signatures are unchanged — BLoCs/widgets untouched.

- **MosqueRepository**: `watchDocument(mosques, id)` for the stream;
  `getDocument(..., serverOnly:)` for fetch; writes go through
  `setDocument(merge:true)` / `updateDocument`, using `RemoteFieldValue` sentinels
  for `updated_at`/`last_seen` and `RemoteFieldValue.delete` for the legacy fields.
  Null/empty active-mosque id → `Stream.value(null)` (unchanged behavior).
- **AppSettingsRepository**: `watchDocument(appSettings, globalDoc)` /
  `getDocument(...)`.
- **PlatformAnnouncementsRepository**: `watchCollection(...)` (repo still filters
  out the settings doc and re-applies the time window — domain logic stays in repo),
  `watchDocument(...)` for settings, `getCollection(..., serverOnly:true)` for fetch.

## Model & cache cleanup (remove leaked Firestore types)

- `mosque_model`, `announcement_model`, `settings_announcement_model`: `toMap()`
  emits `DateTime` directly instead of `Timestamp.fromDate(...)`; drop the
  `cloud_firestore` import. Read path already tolerates `DateTime` via the date
  parser.
- `core/utils/firestore_date_parse.dart` → renamed `date_parse.dart`, function
  `parseFirestoreOrMillis` → `parseDateOrMillis`; drop the `Timestamp` branch and
  the `cloud_firestore` import (Timestamps never reach models anymore — the
  transport already decoded them). Handles `DateTime` / `int` / `double` millis.
- `core/cache/hive_cache_store.dart`: drop the `Timestamp` branch + import
  (`DateTime` branch already covers it).
- `core/di/service_locator.dart`: register
  `RealtimeTransport` → `FirestoreTransport(sl<FirebaseFirestore>())`; pass
  `transport:` to the three repos; simplify the announcements `fromJson` closures
  (no more `Timestamp.fromMillisecondsSinceEpoch` reconstruction — `parseDateOrMillis`
  reads `int` millis directly); drop the `cloud_firestore` import. The
  `FirebaseFirestore` registration stays (auth still needs it).

## Testing

- New `test/support/fake_realtime_transport.dart`: a `FakeRealtimeTransport`
  returning empty streams / `null` by default — enough to exercise cache-first reads.
- The three existing repo tests switch from `.forTest(remoteStream:)` to the real
  constructor with `FakeRealtimeTransport()`; the announcements test drops its
  `Timestamp` usage (uses `DateTime` directly).
- A focused `firestore_transport_test.dart` is **not** added (would require a
  Firestore fake); the encode/decode logic is covered indirectly and is the single
  swappable seam.

## Verification

`flutter analyze` clean (no new lints) and `flutter test` green (39+ tests).
After the change, `cloud_firestore` is imported only by: `firestore_transport.dart`
and the out-of-scope auth/firebase/image-picker files.
