# Firebase → mosques-backend Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Flutter app's Firebase stack (Auth + Cloud Firestore datastore + Firebase-shaped domain models) with a clean Flutter stack built **natively around `mosques-backend`**, then cut over and delete Firebase wholesale. Firebase is not a long-term dependency — neither the SDKs nor the Firestore-shaped models survive past the cutover.

**Strategy: parallel clean stack, then cutover.** The new backend-native stack is built in `lib/backend/` (its own tree, no DI flag toggles, no adapters that preserve Firebase shapes). The existing Firebase app keeps running unchanged on the old code paths during construction — both stacks coexist in the repo but are not bridged. When the new stack passes its acceptance gate, the app's entry points (DI, `main.dart`, splash, top-level blocs) are repointed at the new stack in a single cutover commit, and the Firebase tree is deleted in the following commit. There is no per-domain `BackendFlags` switch and no `IMosqueRepository`/`IAuthRepository` interface preserved from the Firebase side — the new stack defines its own interfaces from scratch against the backend's DTOs.

**Backend-native domain.** `mosques-backend` is the source of truth for the data model. The new Flutter stack defines detailed entities matching the backend (`Mosque`, `PrayerSettings`, `DisplaySettings`, `ContentItem`, `Announcement`, `PlatformAnnouncement`, `AppUser`, `AuthSession`) plus an optional aggregate `MosqueBootstrap { mosque, prayerSettings, displaySettings, content[], announcements[], platformAnnouncements[], syncRevision, publicSlug }` for the bootstrap/snapshot payload. There is no `MosqueModel` god-object; the old one is deleted at cutover. JSON parsing is `json_serializable`-generated (no hand-written `fromMap`/`toMap`). Blocs/widgets/UI bind directly to these new entities — anything currently coupled to `MosqueModel` or Firebase types is rewritten as part of the cutover step, not adapted.

**Realtime + auth shape.**
- **Public display screen:** the backend's public WebSocket `/api/v1/display/mosques/{publicSlug}/ws` is the only data source. Every (re)connect yields a fresh full `MosqueBootstrap` snapshot — there is no resume-by-revision and no local mosque-state cache feeding the display.
- **Authenticated app (rest of the screens):** REST against `/api/v1/mobile/*` over a dio client with bearer + single-flight refresh on `401/token_expired`. After every successful write, the response's new `syncRevision` is captured; on app foreground / pull-to-refresh / scheduled poll, the client compares the cached `syncRevision` against a cheap revision probe and re-fetches `GET .../bootstrap` when stale. No live socket on the authenticated side.

**Tech Stack:**
- Runtime (kept through cutover, removed after): `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_messaging`.
- New (added now, permanent): `dio`, `flutter_secure_storage`, `web_socket_channel`, `json_annotation`, `equatable` (if not already present).
- Dev: `json_serializable`, `build_runner`, `http_mock_adapter`, `bloc_test`, `mocktail`.
- **Entity style (locked):** plain `@JsonSerializable` immutable classes extending `Equatable`. No `freezed`. Every entity defines `const` constructor, `fromJson` (generated), `toJson` (generated where needed for writes), `copyWith` (hand-written, minimal — only for fields the UI actually mutates), and `List<Object?> get props` from `Equatable`.
- Post-cutover: only `firebase_messaging` (+ its transitive `firebase_core`) survives, for FCM receive. Push tokens register via `PUT /api/v1/mobile/devices/current` — no Firestore writes from the app, ever.
- Flutter (Dart SDK ^3.10.7), flutter_bloc, get_it, Hive (cache; see constraints below). Backend: FastAPI + Postgres + Redis (not modified except as last resort).

## Global Constraints

- **Backend is the source of truth, end-to-end.** Every new entity, DTO, and repository in `lib/backend/` is named and shaped after the backend's API contract (§"Backend API Contract" below). Firestore field names, Firestore document IDs (`legacyCompatibility.firestoreDocumentId`), and the old `MosqueModel`/sub-model shapes do not appear anywhere in `lib/backend/`. The new stack is what survives; everything else is scheduled for deletion.
- **Two stacks coexist until cutover.** During Steps 1–4, the old Firebase tree (`lib/core/`, `lib/data/`, `lib/features/`) is left running untouched so the app keeps working. The new stack lives entirely under `lib/backend/` (or an equivalent isolated root) and is exercised via its own test suite and a dedicated `lib/main_backend.dart` entry point, not by flag-flipping inside the existing DI. There is no `BackendFlags` per-domain switch.
- **No interface preservation.** New repositories define their own interfaces from scratch (`MosqueRepository`, `AuthRepository`, `AppSettingsRepository`, `PlatformAnnouncementsRepository`, `DisplayRealtimeRepository`) against the new entities. The existing `IMosqueRepository`, `IAuthRepository`, etc. are NOT extended or implemented by the new code — they are deleted at cutover.
- **No `MosqueModel` god-object.** The new stack uses fine-grained entities (`Mosque`, `PrayerSettings`, `DisplaySettings`, `ContentItem`, `Announcement`) and the `MosqueBootstrap` aggregate. Blocs hold whichever entities they actually need, not a single bag.
- **UI rewrites are in-scope.** Any bloc/widget/screen that depends on `MosqueModel` or Firebase-specific types is rewritten against the new entities during the cutover step (Step 5). This is expected, not avoided.
- **Hive cache is rebuilt, not reused.** The existing `CacheFirstLoader`/`JsonCache`/`ICacheStore` are coupled to `MosqueModel` and get deleted at cutover. The new stack ships its own light caching (Hive boxes keyed by backend entity + `syncRevision`, or simple in-memory + secure storage for tokens/active mosque) — see Step 3.
- **All backend paths are prefixed `/api/v1`.** e.g. `POST /api/v1/mobile/auth/login`.
- **Branch on `error.code`, never on English message text** (backend error contract).
- **Response `latitude`/`longitude` are STRINGS; request lat/long are floats.** Parse defensively at the DTO boundary.
- **`display-settings` PUT is a full replacement** (send all fields); profile/content PATCH are partial.
- **Religious-content items use `order`; general content items use `displayOrder`.**
- **`offsets` includes `sunrise`; `iqamaOffsets` includes `jummah` (no sunrise).**
- **Tokens live in `flutter_secure_storage` only.** Never in Hive/SharedPreferences.
- **TDD:** every code task writes a failing test first, then minimal code, then green, then commit. Repository tests use a fake `Dio`/`ApiClient` or `http_mock_adapter`; never hit a live server in unit tests. The new stack carries its own `test/backend/` tree.
- **Commit after every task** with a conventional-commit message.
- **No git repo at project root currently.** Task 0.1 initializes one; if the user declines, replace each `git commit` step with "save checkpoint" and skip commit commands.
- **flutter_bloc major version is not bumped as part of this migration** — keep whatever the pubspec already declares.

---

## Backend API Contract (authoritative reference for all tasks)

Envelope: `{ "success": bool, "data": {...}, "meta": { "requestId": str, "pagination": {...}|null } }`.
Error: `{ "success": false, "error": { "code": str, "message": str, "details": {}, "requestId": str } }`.
Error codes: `internal_error, validation_error, unauthenticated, invalid_credentials, token_expired, refresh_token_revoked, permission_denied, password_change_required, not_found, conflict, rate_limited, subscription_required, token_allowance_exceeded, ai_service_unavailable, service_unavailable, ai_session_expired, fcm_delivery_failed`.

**Auth**
- `POST /api/v1/mobile/auth/login` → req `{email, password, device?:{deviceId?, deviceKind, notificationProvider?, pushToken?, clientInfo}}` → data `{accessToken, refreshToken, tokenType, expiresInSeconds, user, activeMosque, mosques[], permissions[]}`.
- `POST /api/v1/mobile/auth/refresh` → req `{refreshToken}` → data `{accessToken, refreshToken, tokenType, expiresInSeconds}`.
- `POST /api/v1/mobile/auth/logout` → req `{refreshToken, revokeDevice}` → data `{}`.
- `POST /api/v1/mobile/auth/logout-other-sessions` (auth) → req `{refreshToken}` → data `{revokedCount}`.
- `POST /api/v1/mobile/auth/change-password` (auth) → req `{currentPassword, newPassword}` → data `{accessToken, refreshToken, tokenType, expiresInSeconds}`.
- `user` = `{id, email, phone?, fullName?, activeMosqueId?, isActive, passwordChangeRequired, createdAt?}`.
- `AuthMosqueSummary` = `{id, publicSlug, name, city, countryCode?, latitude(str), longitude(str), timezone, languageCode, defaultRiwayahCode, syncRevision}`.

**User / device**
- `GET /api/v1/mobile/me` → data `{user, activeMosque?, mosques[], permissions[]}`.
- `PATCH /api/v1/mobile/me` → req `{fullName?, phone?, activeMosqueId?}` → data `{user}`.
- `PUT /api/v1/mobile/devices/current` → req `{deviceId?, deviceKind, notificationProvider?, pushToken?, clientInfo}` → data `{device:{id, deviceKind, notificationProvider?, lastSeenAt?, clientInfo}}`.

**App bootstrap**
- `GET /api/v1/mobile/app/bootstrap?platform=&version=` → data `{supportPhone, backgroundLibraryUrls[], backgroundFolderUrl, aboutCategories[], update:{latestVersion, androidLink, windowsLink, iosLink, macosLink, linuxLink, releaseNotes, isUpdateAvailable}, latestRelease?:{platform, version, downloadUrl, releaseNotes, isUpdateAvailable}}`.

**Mosque read**
- `GET /api/v1/mobile/mosques` (auth) → data `{items:[MosqueSummary]}`.
- `GET /api/v1/mobile/mosques/{mosqueId}/bootstrap` (perm mosque.view) → data `{mosque, prayerSettings, displaySettings, content[], announcements[], platformAnnouncements[], syncRevision, legacyCompatibility:{firestoreDocumentId}}`.
- `MosqueSummary` = AuthMosqueSummary + `ownerUserId?`.
- `prayerSettings` = `{mosqueId, calculationMethod, offsets:{fajr,sunrise,dhuhr,asr,maghrib,isha}, iqamaOffsets:{fajr,dhuhr,asr,maghrib,isha,jummah}, preAdhanMinutes, adhanMomentDurationSeconds}`.
- `displaySettings` = `{mosqueId, backgroundType, backgroundValue, albumImageUrls[], publishedAlbumUrl?, publishedAlbumAt?, publishedAlbumDurationSeconds?, publishedAlbumFit, publishedAlbumExpiresAt?(resp-only), publishedAlbumActive(resp-only), primaryColor, secondaryColor, activeCardColor, activeCardTextColor, inactiveCardColor, prayerOverlayColor, inactiveCardTextColor, countdownTextColor, countdownBackgroundColor, alertTextColor, alertBackgroundColor, clockFontSize, mosqueInfoFontSize, prayersFontSize, announcementsFontSize, contentFontSize, tickerSpeed, stripSpeed, prayerCardScale, religiousContentWaitSeconds, religiousContentDisplaySeconds, numeralFormat, fontFamily}`.
- `ContentItem` = `{id, kind, text, narrator, source, isActive, displayOrder, createdAt, updatedAt}`.
- `Announcement` = `{id, scope, audience, announcementType, title, subtitle?, startAt, endAt, qrCodeUrl?, isActive, isPriority, displayDurationSeconds, displayOrder, createdAt, updatedAt}`.

**Mosque writes** (all mutation responses include `syncRevision`)
- `PATCH /api/v1/mobile/mosques/{id}` → req `{publicSlug?, name?, city?, countryCode?, latitude?(float), longitude?(float), timezone?, languageCode?, defaultRiwayahCode?}` → `{mosque, syncRevision}`.
- `PUT /api/v1/mobile/mosques/{id}/prayer-settings` → req `{calculationMethod, offsets{6}, iqamaOffsets{6}, preAdhanMinutes, adhanMomentDurationSeconds}` → `{prayerSettings, syncRevision}`.
- `PUT /api/v1/mobile/mosques/{id}/display-settings` → req = all DisplaySettings req fields (full replace) → `{displaySettings, syncRevision}`.
- `POST /api/v1/mobile/mosques/{id}/display-settings/published-album` → req `{url, durationSeconds, fit}` → `{displaySettings, syncRevision}`.
- `DELETE /api/v1/mobile/mosques/{id}/display-settings/published-album` → `{displaySettings, syncRevision}`.
- `GET /api/v1/mobile/mosques/{id}/religious-content` (perm mosque.view) → `{hadiths[], verses[], duas[], adhkar[]}`, item = `{id, text, source, narrator, isActive, order}`.
- `PUT /api/v1/mobile/mosques/{id}/religious-content` → req same 4 groups, item `{id?, text, source, narrator, isActive, order}` → `{hadiths[], verses[], duas[], adhkar[], syncRevision}`.
- Content CRUD under `/api/v1/mobile/mosques/{id}/content` (`POST/PATCH/DELETE`).
- Announcements CRUD under `/api/v1/mobile/mosques/{id}/announcements`.
- Alerts: `POST /alerts` (forces type=alert, audience=display, isPriority=true), `PATCH /alerts/{id}/cancel`, `DELETE /alerts` (all).

**Display (public, no auth)**
- `GET /api/v1/display/mosques/{publicSlug}/snapshot` → data `{mosque, prayerSettings, displaySettings, content[], announcements[], platformAnnouncements[], serverTime, syncRevision}`.
- `WS /api/v1/display/mosques/{publicSlug}/ws`. Server frames: `{type:"display.snapshot", syncRevision, snapshot}`, `{type:"heartbeat", serverTime}`, `{type:"display.snapshot.updated", syncRevision, snapshot}`, `{type:"error", code, message?}`. Client may send `{type:"hello", lastSyncRevision?}` (currently ignored by server). No resume-by-revision: every (re)connect yields a fresh full snapshot. Close codes: 1000 normal, 1008 policy (rate_limited/not_found), 1013 try-again-later.

---

## File Structure

The entire new stack lives under `lib/backend/`. Nothing in `lib/core/`, `lib/data/`, or `lib/features/` is modified during Steps 1–4 — those trees keep running the Firebase app unchanged. Only at cutover (Step 5) do `main.dart` / DI / a small set of top-level wiring points get repointed, immediately followed by deletion of the entire Firebase tree.

**`lib/backend/` — the new clean stack (the only thing that survives cutover):**

```
lib/backend/
  network/
    api_config.dart              # base URL, platform, version (from --dart-define)
    api_envelope.dart            # ApiException + envelope unwrap helpers
    token_store.dart             # secure access/refresh tokens, active mosque id, per-mosque syncRevision
    auth_interceptor.dart        # bearer injection + single-flight refresh on 401/token_expired
    api_client.dart              # Dio wrapper -> typed get/post/put/patch/delete returning unwrapped data
  entities/                      # domain types — backend-shaped, json_serializable
    app_user.dart                # AppUser (backend /me shape)
    auth_session.dart            # AuthSession (login response: tokens + user + activeMosque + permissions)
    auth_mosque_summary.dart     # AuthMosqueSummary
    mosque.dart                  # Mosque (id, publicSlug, name, city, lat/long, timezone, languageCode, ...)
    prayer_settings.dart         # PrayerSettings + Offsets + IqamaOffsets
    display_settings.dart        # DisplaySettings (all visual config; full-replace shape)
    content_item.dart            # ContentItem (hadith/verse/dua/adhkar — kind, text, displayOrder, ...)
    announcement.dart            # Announcement (scope=mosque, audience, type=ad|alert, ...)
    platform_announcement.dart   # PlatformAnnouncement (scope=platform)
    mosque_bootstrap.dart        # MosqueBootstrap aggregate { mosque, prayerSettings, displaySettings, content[], announcements[], platformAnnouncements[], syncRevision, publicSlug }
    app_bootstrap.dart           # AppBootstrap (supportPhone, backgroundLibraryUrls, aboutCategories, update, ...)
    server_error.dart            # error code enum / typed errors
  data/                          # API clients — raw endpoint calls returning entities
    auth_api.dart                # /mobile/auth/* + /mobile/me + /mobile/devices/current
    mosque_api.dart              # /mobile/mosques/* (reads + writes, including religious-content, announcements, alerts, published-album)
    app_bootstrap_api.dart       # /mobile/app/bootstrap
    platform_announcements_api.dart  # /mobile/announcements?scope=platform
    display_api.dart             # /display/mosques/{publicSlug}/snapshot (REST snapshot for WS bootstrap fallback)
    display_socket.dart          # /display/mosques/{publicSlug}/ws (frame parsing, reconnect, backoff)
  repositories/                  # repository layer — caching, sync-revision tracking, exposes streams/futures to blocs
    auth_repository.dart         # login/logout/refresh/me/change-password/update-profile + currentUser stream + FCM token registration
    mosque_repository.dart       # MosqueBootstrap reads, all mutations, sync-revision tracked
    app_settings_repository.dart # AppBootstrap with stale-while-revalidate
    platform_announcements_repository.dart
    display_realtime_repository.dart  # public WebSocket -> Stream<MosqueBootstrap>
    sync_revision_poller.dart    # foreground/pull-to-refresh trigger -> bootstrap refresh when revision stale
  services/
    device_registrar.dart        # FCM token -> PUT /mobile/devices/current
    fcm_receiver.dart            # firebase_messaging receive-only wrapper (no Firestore, no auth coupling)
  cache/
    bootstrap_cache.dart         # Hive box for MosqueBootstrap keyed by mosqueId, gated by syncRevision
    app_bootstrap_cache.dart     # Hive box for AppBootstrap
  di/
    backend_module.dart          # get_it registrations for everything above
  ui/                            # NEW blocs + widgets bound to the new entities (replaces lib/features/* at cutover)
    auth/                        # LoginBloc, SplashRoutingBloc, ProfileBloc, ChangePasswordBloc
    mosque/                      # MosqueBloc (holds MosqueBootstrap), settings sub-blocs per entity
    display/                     # DisplayBloc bound to display_realtime_repository
    language/                    # LanguageBloc (auth-state-driven)
    common/                      # shared widgets the new screens need that don't already exist
  main_backend.dart              # standalone entrypoint to bring up the new stack for end-to-end testing during Steps 1–4
test/backend/
  ...                            # mirrors the lib/backend/ tree; never touches the Firebase tree
```

**New dependencies** (added in Step 0, all permanent except the build-time ones):
- runtime: `dio`, `flutter_secure_storage`, `web_socket_channel`, `json_annotation`, `freezed_annotation` (optional)
- dev: `json_serializable`, `build_runner`, `freezed` (if used), `http_mock_adapter`, `bloc_test`, `mocktail`

**Untouched during Steps 1–4** (live alongside, deleted at cutover):
- the entire `lib/core/`, `lib/data/`, `lib/features/` trees, including `MosqueModel` and all its sub-models, `IMosqueRepository` / `IAuthRepository` / `IAppSettingsRepository` / `IPlatformAnnouncementsRepository`, `CacheFirstLoader`/`JsonCache`/`ICacheStore`, every Firestore-shaped DTO/mapper, every `firebase_auth`/`cloud_firestore` import site.

**Touched ONLY at cutover (Step 5):**
- `lib/main.dart` — point `runApp` at the new top-level widget tree from `lib/backend/ui/`.
- `pubspec.yaml` — remove `cloud_firestore` + `firebase_auth` (keep `firebase_core` + `firebase_messaging` for receive).
- root config: delete `firestore.rules`, `firestore.indexes.json`, Firestore sections of `firebase.json`.

**Deleted at cutover (Step 5):** the entire Firebase tree listed under "Untouched during Steps 1–4".

---

## Step 0 — Foundations: networking core + dependencies + local backend

Goal: stand up the dio-based networking core under `lib/backend/network/`, add all new dependencies, initialize the repo if absent, and bring up the local `mosques-backend` so subsequent steps have a real server to talk to. Nothing in the existing Firebase app is modified — the Firebase app continues to run identically through this step and Steps 1–4.

### Task 0.1: Initialize git + plan baseline

- [ ] **Step 1:** Confirm whether a repo exists at the project root.

Run: `git -C "C:/Users/Mounir/Documents/FlutterProject/mosques" rev-parse --is-inside-work-tree`
Expected: errors with "not a git repository" (per environment). If it prints `true`, skip to Step 3.

- [ ] **Step 2:** Initialize the repo (only if Step 1 failed). Ask the user first whether they want version control at the project root.

Run: `git -C "C:/Users/Mounir/Documents/FlutterProject/mosques" init && git -C "C:/Users/Mounir/Documents/FlutterProject/mosques" add -A`

- [ ] **Step 3:** Baseline commit.

```bash
git commit -m "chore: baseline before Firebase to backend rewrite"
```

> If the user declines git at the root, replace every later `git commit` step with a manual checkpoint (copy changed files aside) and skip the commit commands.

### Task 0.2: Add dependencies + scaffold `lib/backend/`

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/backend/.gitkeep`, `test/backend/.gitkeep` (empty dirs to anchor the tree)

- [ ] **Step 1:** Add runtime deps under `dependencies:` (verify versions against the SDK floor `^3.10.7` — pin to the highest compatible if pub resolution complains):

```yaml
  # Backend-native stack (clean rewrite)
  dio: ^5.7.0
  flutter_secure_storage: ^9.2.2
  web_socket_channel: ^3.0.1
  json_annotation: ^4.9.0
  equatable: ^2.0.5            # only if not already declared
```

- [ ] **Step 2:** Add dev deps under `dev_dependencies:`:

```yaml
  json_serializable: ^6.8.0
  build_runner: ^2.4.13
  http_mock_adapter: ^0.6.1
  bloc_test: ^9.1.7
  mocktail: ^1.0.4
```

- [ ] **Step 3:** Resolve.

Run: `flutter pub get`
Expected: "Got dependencies!" with no conflicts.

- [ ] **Step 4:** Create the directory anchors.

Run: `mkdir -p lib/backend/network lib/backend/entities lib/backend/data lib/backend/repositories lib/backend/services lib/backend/cache lib/backend/di lib/backend/ui test/backend`
Then place a `.gitkeep` in `lib/backend/` and `test/backend/`.

- [ ] **Step 5:** Commit.

```bash
git add pubspec.yaml pubspec.lock lib/backend test/backend
git commit -m "build: add backend-stack deps; scaffold lib/backend/ tree"
```

### Task 0.3: ApiConfig

**Files:**
- Create: `lib/backend/network/api_config.dart`
- Test: `test/backend/network/api_config_test.dart`

**Interfaces:** `ApiConfig.baseUrl` / `ApiConfig.platform` / `ApiConfig.appVersion` / `ApiConfig.displayPublicSlug` (`String`), all resolved from `--dart-define`.

- [ ] **Step 1: Write the failing test**

```dart
// test/backend/network/api_config_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/backend/network/api_config.dart';

void main() {
  test('baseUrl has the /api/v1 prefix and a default', () {
    expect(ApiConfig.baseUrl, isNotEmpty);
    expect(ApiConfig.baseUrl.endsWith('/api/v1'), isTrue);
  });
}
```

> Verify the package name in `pubspec.yaml` (`name:` field). All test imports use `package:<pubspecName>/...`. If it differs from `Tebyan`, substitute the real name in every test in this plan.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/backend/network/api_config_test.dart`
Expected: FAIL — `api_config.dart` not found / `ApiConfig` undefined.

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/backend/network/api_config.dart
abstract final class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );
  static const String platform = String.fromEnvironment(
    'APP_PLATFORM',
    defaultValue: 'android',
  );
  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.1.0',
  );
  static const String displayPublicSlug = String.fromEnvironment(
    'DISPLAY_PUBLIC_SLUG',
    defaultValue: '',
  );
}
```

- [ ] **Step 4: Run test to verify it passes** — `flutter test test/backend/network/api_config_test.dart` → PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/backend/network/api_config.dart test/backend/network/api_config_test.dart
git commit -m "feat(backend/network): add ApiConfig"
```

### Task 0.4: Envelope + typed errors

**Files:**
- Create: `lib/backend/network/api_envelope.dart`
- Test: `test/backend/network/api_envelope_test.dart`

**Interfaces:**
- `class ApiException implements Exception { final String code; final String message; final Map<String,dynamic> details; final int? statusCode; }`
- `dynamic unwrapEnvelope(dynamic body, {int? statusCode})` — returns the `data` value (Map or List) on success; throws `ApiException` otherwise.
- `Never throwApiError(dynamic body, int? statusCode)` — builds an `ApiException` from an error envelope (fallback code `internal_error`).

- [ ] **Step 1: Write the failing test**

```dart
// test/backend/network/api_envelope_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/backend/network/api_envelope.dart';

void main() {
  test('unwraps success envelope to data (map)', () {
    final data = unwrapEnvelope({'success': true, 'data': {'x': 1}, 'meta': {}});
    expect((data as Map)['x'], 1);
  });

  test('unwraps success envelope to data (list)', () {
    final data = unwrapEnvelope({'success': true, 'data': [1, 2], 'meta': {}});
    expect(data, [1, 2]);
  });

  test('throws ApiException with code on error envelope', () {
    expect(
      () => unwrapEnvelope({
        'success': false,
        'error': {'code': 'token_expired', 'message': 'expired', 'details': {}},
      }),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 'token_expired')),
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails** — FAIL (undefined).

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/backend/network/api_envelope.dart
class ApiException implements Exception {
  final String code;
  final String message;
  final Map<String, dynamic> details;
  final int? statusCode;
  const ApiException({
    required this.code,
    required this.message,
    this.details = const {},
    this.statusCode,
  });
  @override
  String toString() => 'ApiException($code): $message';
}

dynamic unwrapEnvelope(dynamic body, {int? statusCode}) {
  if (body is Map && body['success'] == true) {
    return body['data'];
  }
  throwApiError(body, statusCode);
}

Never throwApiError(dynamic body, int? statusCode) {
  if (body is Map && body['error'] is Map) {
    final err = Map<String, dynamic>.from(body['error'] as Map);
    throw ApiException(
      code: err['code']?.toString() ?? 'internal_error',
      message: err['message']?.toString() ?? 'Unknown error',
      details: err['details'] is Map
          ? Map<String, dynamic>.from(err['details'] as Map)
          : const {},
      statusCode: statusCode,
    );
  }
  throw ApiException(
    code: 'internal_error',
    message: 'Malformed response',
    statusCode: statusCode,
  );
}
```

- [ ] **Step 4: Run test** → PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/backend/network/api_envelope.dart test/backend/network/api_envelope_test.dart
git commit -m "feat(backend/network): envelope unwrap + ApiException"
```

### Task 0.5: TokenStore

**Files:**
- Create: `lib/backend/network/token_store.dart`
- Test: `test/backend/network/token_store_test.dart`

**Interfaces:** `class TokenStore { TokenStore(FlutterSecureStorage storage); Future<String?> readAccess(); Future<String?> readRefresh(); Future<void> saveTokens({required String access, required String refresh}); Future<void> clear(); Future<void> saveActiveMosqueId(String id); Future<String?> readActiveMosqueId(); Future<void> saveSyncRevision(String mosqueId, int rev); Future<int?> readSyncRevision(String mosqueId); Future<void> saveDisplayPublicSlug(String slug); Future<String?> readDisplayPublicSlug(); }`. Constructor takes `FlutterSecureStorage` for testability.

Tests + implementation follow the same TDD shape as the original plan's Task 0.5 — see the historical implementation in this file's prior revisions for the secure-storage key constants (`backend_access_token`, `backend_refresh_token`, `backend_active_mosque_id`, `backend_sync_rev_<id>`, `backend_display_public_slug`).

- [ ] **Step 1:** Write the failing test (mirrors the 0.5 test from prior plan, plus a `displayPublicSlug` round-trip case).
- [ ] **Step 2:** Run → FAIL.
- [ ] **Step 3:** Implement under `lib/backend/network/token_store.dart` with the keys above.
- [ ] **Step 4:** Run → PASS.
- [ ] **Step 5:** Commit `feat(backend/network): TokenStore in secure storage`.

### Task 0.6: AuthInterceptor (single-flight refresh) + ApiClient

**Files:**
- Create: `lib/backend/network/auth_interceptor.dart`
- Create: `lib/backend/network/api_client.dart`
- Test: `test/backend/network/api_client_test.dart`

**Interfaces:**
- `class ApiClient { ApiClient(Dio dio, TokenStore tokens); Future<dynamic> get(String path, {Map<String,dynamic>? query}); Future<dynamic> post(String path, {Object? body, Map<String,String>? headers}); Future<dynamic> put(String path, {Object? body}); Future<dynamic> patch(String path, {Object? body}); Future<dynamic> delete(String path, {Object? body}); }` — each returns the unwrapped `data` (callers cast to Map or List as appropriate); throws `ApiException`.
- `class AuthInterceptor extends QueuedInterceptor { AuthInterceptor(Dio dio, TokenStore tokens, {void Function()? onAuthCleared}); }` — bearer injection; on 401 with `token_expired`/`unauthenticated` runs one shared refresh via `POST /mobile/auth/refresh`, retries the original request once, clears tokens + fires `onAuthCleared` on refresh failure.

Implementation pattern is identical to the prior plan's Task 0.6 (single-flight via shared `Future<bool>? _refreshing`; `extra['skipAuth']` to opt the refresh call itself out of bearer injection; `extra['retried']` guard). Adapt the unit tests so they assert against `dynamic` returns (callers cast) rather than the prior `Map<String, dynamic>` returns.

- [ ] **Step 1–5:** Same TDD shape as 0.4/0.5. Commit `feat(backend/network): ApiClient + single-flight refresh interceptor`.

### Task 0.7: backend DI module skeleton

**Files:**
- Create: `lib/backend/di/backend_module.dart`
- Test: `test/backend/di/backend_module_test.dart`

**Interfaces:** `Future<void> registerBackendModule(GetIt sl)` — registers `FlutterSecureStorage`, `TokenStore`, `Dio` (with `AuthInterceptor` attached), `ApiClient`. Uses its **own** `GetIt` instance API surface; **does not** touch the existing app's `setupServiceLocator()`. The Firebase app's DI remains untouched.

- [ ] **Step 1:** Failing test that calls `registerBackendModule(GetIt.asNewInstance())` and resolves `Dio`, `TokenStore`, `ApiClient`.

> Use `GetIt.asNewInstance()` (or `GetIt.instance` after `reset()`) — the new module never reuses any registration from `lib/core/di/service_locator.dart`. The two DI graphs are entirely independent until cutover.

- [ ] **Step 2:** FAIL.
- [ ] **Step 3:** Implement `registerBackendModule`.
- [ ] **Step 4:** PASS.
- [ ] **Step 5:** Commit `feat(backend/di): backend module skeleton`.

### Task 0.8: Stand up backend locally + import dry-run (ops, no app code)

- [ ] **Step 1:** Configure backend env.

Run: `cp mosques-backend/.env.example mosques-backend/.env` and edit to point at local Postgres/Redis and (for the importer) the Firebase service-account JSON in the repo root.

- [ ] **Step 2:** Start services.

Run: `cd mosques-backend && docker compose up -d postgres redis api`
Expected: `docker compose ps` shows `api` healthy; `GET http://localhost:8000/health` returns 200.

- [ ] **Step 3:** Apply migrations + seed.

Run: `cd mosques-backend && docker compose run --rm api alembic upgrade head && docker compose run --rm api python -m mosque_backend.scripts.seed`
> Verify the exact alembic/seed invocation against the backend repo's own README; use whatever it documents.

- [ ] **Step 4:** Dry-run the Firebase importer to validate that existing Firestore data maps cleanly into the backend schema.

Run: `cd mosques-backend && docker compose run --rm api firebase-import --dry-run`
Expected: a mapping report listing mosques/users/content with NO errors. Note any mosque missing a derivable `public_slug` (needed for the display WS) and confirm FCM tokens map to `user_devices`.

- [ ] **Step 5:** Record findings in `mosques-backend/docs/import-dryrun-notes.md` — especially the password caveat (Firebase password hashes don't transfer → migrated users need the `password_change_required` flow), any `public_slug` gaps that would break the display screen post-cutover, and any field-level data normalization the importer applies.

- [ ] **Step 6:** Commit the notes (the backend dir is its own git repo).

```bash
cd mosques-backend && git add docs/import-dryrun-notes.md && git commit -m "docs: firebase import dry-run findings"
```

**Gate (Step 0):** the Firebase app still runs identically (no `lib/core/`/`lib/data/`/`lib/features/` files were modified); `lib/backend/network/` builds and is fully unit-tested; the backend is reachable locally; the importer dry-run is clean. The new stack has no entities, repos, or UI yet — that's Steps 1–4.

---

## Step 1 — Backend-native entities + DTOs

Goal: define every domain entity the new stack will use, shaped exactly to the backend's API contract. `json_serializable` (and optionally `freezed`) handle the JSON; there are no hand-written `fromMap`/`toMap`. Each entity ships with a unit test that round-trips a real backend payload sample.

**Entity inventory** (one task per entity unless trivially grouped):

| Task | File | Entity |
|---|---|---|
| 1.1 | `app_user.dart` | `AppUser` |
| 1.1 | `auth_mosque_summary.dart` | `AuthMosqueSummary` |
| 1.1 | `auth_session.dart` | `AuthSession` (login response) |
| 1.2 | `mosque.dart` | `Mosque` (full mosque profile from bootstrap) |
| 1.3 | `prayer_settings.dart` | `PrayerSettings`, `PrayerOffsets`, `IqamaOffsets` |
| 1.4 | `display_settings.dart` | `DisplaySettings` |
| 1.5 | `content_item.dart` | `ContentItem` (+ `ContentKind` enum: hadith/verse/dua/adhkar — confirm exact backend enum values from importer output) |
| 1.6 | `announcement.dart` | `Announcement` (+ `AnnouncementType` enum incl. `ad`/`alert`; + `AnnouncementScope`/`AnnouncementAudience` if exposed in payload) |
| 1.6 | `platform_announcement.dart` | `PlatformAnnouncement` (or reuse `Announcement` with `scope=platform` — choose during 1.6 based on whether platform announcements carry distinct fields) |
| 1.7 | `mosque_bootstrap.dart` | `MosqueBootstrap` aggregate |
| 1.8 | `app_bootstrap.dart` | `AppBootstrap` + `AppUpdate` + `AboutCategory` |
| 1.9 | `server_error.dart` | `ServerErrorCode` enum + extensions |

### Task 1.x pattern (applied to every task above)

**Files (per task):**
- Create: `lib/backend/entities/<entity>.dart`
- Test: `test/backend/entities/<entity>_test.dart`

**Interfaces:** the entity class itself (immutable; `@JsonSerializable` or `@freezed`); `fromJson(Map<String, dynamic>)` / `toJson()`.

- [ ] **Step 1: Capture a real backend payload sample** for the entity. Source the JSON by curl'ing the local backend from Task 0.8 (e.g. `curl http://localhost:8000/api/v1/mobile/me -H 'Authorization: Bearer <token>'` after seeding a test user), or copy verbatim from the backend repo's OpenAPI/example fixtures. Save the trimmed sample under `test/backend/fixtures/<entity>.json`.

- [ ] **Step 2: Write the failing test** asserting `Entity.fromJson(sampleJson)` parses every field correctly and `toJson()` round-trips for request shapes (response-only fields like `createdAt` are read-only and don't need round-trip).

```dart
// test/backend/entities/app_user_test.dart (template — adapt per entity)
import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/backend/entities/app_user.dart';

void main() {
  test('AppUser parses backend payload', () {
    final u = AppUser.fromJson({
      'id': 'u1', 'email': 'a@b.com', 'phone': '+1', 'fullName': 'A',
      'activeMosqueId': 'm1', 'isActive': true, 'passwordChangeRequired': true,
    });
    expect(u.id, 'u1');
    expect(u.activeMosqueId, 'm1');
    expect(u.passwordChangeRequired, true);
  });
}
```

- [ ] **Step 3: Run → FAIL** (entity undefined).

- [ ] **Step 4: Write the entity.** Style is locked to **plain `@JsonSerializable` + `Equatable`** for every entity (no freezed). Example:

```dart
// lib/backend/entities/app_user.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_user.g.dart';

@JsonSerializable()
class AppUser extends Equatable {
  final String id;
  final String email;
  final String? phone;
  final String? fullName;
  final String? activeMosqueId;
  final bool isActive;
  final bool passwordChangeRequired;

  const AppUser({
    required this.id,
    required this.email,
    this.phone,
    this.fullName,
    this.activeMosqueId,
    required this.isActive,
    required this.passwordChangeRequired,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
  Map<String, dynamic> toJson() => _$AppUserToJson(this);

  // copyWith is hand-written and ONLY covers fields the UI mutates.
  // For entities that are never mutated (e.g. ContentItem from server), omit copyWith entirely.

  @override
  List<Object?> get props => [
        id, email, phone, fullName, activeMosqueId, isActive, passwordChangeRequired,
      ];
}
```

> **Lat/long handling** (applies to `Mosque`, `AuthMosqueSummary`): the backend sends these as **strings** in responses but expects **floats** in writes. Define the entity field as `double?` (or `double`) and use a custom `@JsonKey(fromJson: _strToDouble, toJson: _doubleToStr)` converter at the field, OR a dedicated `LatLongConverter` — whichever the chosen serialization style supports cleanly. Include a unit test that fails if a numeric string isn't parsed.
>
> **`syncRevision`** is an `int` on responses; never optional in mutation responses, sometimes absent in nested error responses — model as `int` with `@JsonKey(defaultValue: 0)`.
>
> **`MosqueBootstrap`** (Task 1.7) wraps the bootstrap data map and additionally carries `publicSlug` (lifted from `mosque.publicSlug`) at the aggregate level for convenience — define it as a top-level field even though the JSON nests it; populate it in `fromJson` via a manual factory if json_serializable can't do it natively.

- [ ] **Step 5: Run code generation** — `dart run build_runner build --delete-conflicting-outputs` — and re-run the test → PASS.

- [ ] **Step 6: Commit** — `feat(backend/entities): add <Entity>`.

### Task 1.10: Acceptance — full bootstrap fixture round-trip

**Files:**
- Test: `test/backend/entities/bootstrap_roundtrip_test.dart`
- Fixture: `test/backend/fixtures/mosque_bootstrap.json` (real backend response captured against the local backend with seeded data)

- [ ] **Step 1:** Capture a complete `GET /api/v1/mobile/mosques/{id}/bootstrap` response from the local backend, save to the fixture path.

- [ ] **Step 2: Write the failing test** that parses the fixture into a `MosqueBootstrap` and asserts every nested entity (mosque, prayer settings, display settings, every kind of content item, both announcement types) round-trips cleanly.

- [ ] **Step 3:** Run → FAIL if any field is missed in the entities.

- [ ] **Step 4:** Fix the offending entity (add the missing field) and re-run.

- [ ] **Step 5:** PASS. Commit `test(backend/entities): full bootstrap round-trip acceptance`.

**Gate (Step 1):** every backend response shape from the contract is represented by a Dart entity in `lib/backend/entities/`; the full `MosqueBootstrap` fixture round-trips; no hand-written `fromMap`/`toMap` remains in the new code; no entity references `MosqueModel` or any Firebase type.

---

## Step 2 — API clients (raw endpoint calls)

Goal: thin classes per endpoint group that turn an `ApiClient` call + the Step 1 entities into a typed method. No caching, no state, no `syncRevision` tracking yet — that lives in Step 3's repositories. Each API client returns entities (or void) directly.

### Task 2.1: AuthApi

**Files:**
- Create: `lib/backend/data/auth_api.dart`
- Test: `test/backend/data/auth_api_test.dart`

**Interfaces:**

```dart
class AuthApi {
  AuthApi(ApiClient client);
  Future<AuthSession> login(String email, String password, {Device? device});
  Future<Tokens> refresh(String refreshToken);                 // returns new tokens; entity Tokens = subset of AuthSession
  Future<void> logout(String refreshToken, {bool revokeDevice = false});
  Future<int> logoutOtherSessions(String refreshToken);        // returns revokedCount
  Future<Tokens> changePassword(String current, String next);
  Future<AppUser> me();                                        // unwraps data.user
  Future<MeBundle> meFull();                                   // returns AppUser + activeMosque? + mosques[] + permissions[]
  Future<AppUser> patchMe({String? fullName, String? phone, String? activeMosqueId});
  Future<RegisteredDevice> putDevice(Device device);
}
```

Add small helper records / data classes (`Tokens`, `MeBundle`, `Device`, `RegisteredDevice`) under `lib/backend/data/_dtos.dart` — these are request/response wrappers that don't belong in `entities/` because they aren't first-class domain concepts.

- [ ] **Step 1–5:** Standard TDD with `http_mock_adapter`. One test per method exercises the success path (asserts the right verb/path/body and that the response parses into the right entity); one error path test per method asserts `ApiException(code)` is raised for the expected error envelope.

> **`AuthApi.refresh` lives outside the interceptor.** The dio `AuthInterceptor` (Task 0.6) calls `POST /mobile/auth/refresh` directly via the `Dio` it holds, bypassing `AuthApi` to avoid recursion. `AuthApi.refresh` is exposed for manual refresh-on-demand (logout-other-sessions, etc.). Both call the same endpoint — keep request/response shapes identical.

- [ ] **Step 5:** Commit `feat(backend/data): AuthApi`.

### Task 2.2: MosqueApi

**Files:**
- Create: `lib/backend/data/mosque_api.dart`
- Test: `test/backend/data/mosque_api_test.dart`

**Interfaces (read):**

```dart
class MosqueApi {
  MosqueApi(ApiClient client);
  Future<List<MosqueSummary>> list();                              // GET /mobile/mosques
  Future<MosqueBootstrap> bootstrap(String mosqueId);              // GET /mobile/mosques/{id}/bootstrap
  Future<ReligiousContent> religiousContent(String mosqueId);      // GET .../religious-content; returns {hadiths, verses, duas, adhkar}
}
```

**Interfaces (write — each returns the updated entity + new `syncRevision`):**

```dart
  Future<MosqueWriteResult<Mosque>> patchProfile(String mosqueId, MosqueProfilePatch patch);
  Future<MosqueWriteResult<PrayerSettings>> putPrayerSettings(String mosqueId, PrayerSettings settings);
  Future<MosqueWriteResult<DisplaySettings>> putDisplaySettings(String mosqueId, DisplaySettings settings);
  Future<MosqueWriteResult<DisplaySettings>> postPublishedAlbum(String mosqueId, {required String url, required int durationSeconds, required String fit});
  Future<MosqueWriteResult<DisplaySettings>> deletePublishedAlbum(String mosqueId);
  Future<MosqueWriteResult<ReligiousContent>> putReligiousContent(String mosqueId, ReligiousContent content);  // full replace of all 4 groups
  // Content CRUD (per-item, NOT bulk PUT — confirmed by contract)
  Future<MosqueWriteResult<ContentItem>> createContentItem(String mosqueId, ContentItemCreate input);
  Future<MosqueWriteResult<ContentItem>> patchContentItem(String mosqueId, String itemId, ContentItemPatch patch);
  Future<MosqueWriteResult<void>> deleteContentItem(String mosqueId, String itemId);
  // Announcements CRUD
  Future<MosqueWriteResult<Announcement>> createAnnouncement(String mosqueId, AnnouncementCreate input);
  Future<MosqueWriteResult<Announcement>> patchAnnouncement(String mosqueId, String id, AnnouncementPatch patch);
  Future<MosqueWriteResult<void>> deleteAnnouncement(String mosqueId, String id);
  // Alerts (alerts are announcements with forced server-side flags)
  Future<MosqueWriteResult<Announcement>> createAlert(String mosqueId, AlertCreate input);
  Future<MosqueWriteResult<void>> cancelAlert(String mosqueId, String id);
  Future<MosqueWriteResult<void>> cancelAllAlerts(String mosqueId);
```

`MosqueWriteResult<T>` is `{T? value, int syncRevision}` (or `({T? value, int syncRevision})` record).

> **Religious content shape — confirmed.** Per the API contract above, `PUT .../religious-content` takes the four named groups (`{hadiths[], verses[], duas[], adhkar[]}`), not a flat items array. `ReligiousContent` is a small entity holding all four lists; `putReligiousContent` sends all four at once. Single-list edits in the UI populate `ReligiousContent` from the current cached state and replace the one list.
>
> **Announcements / alerts shape — confirmed.** Per-item CRUD. The bulk-PUT shape from the previous plan revision is gone. The `MosqueRepository` (Step 3) is responsible for diffing the user's edited list against the server state and issuing the right sequence of create/patch/delete calls; `MosqueApi` is per-item only.

- [ ] **Step 1–5:** TDD per method group. Group commits by area: `feat(backend/data): MosqueApi reads`, `... profile + prayer/display writes`, `... religious content`, `... content CRUD`, `... announcements CRUD`, `... alerts`. Keep each commit small and reviewable.

### Task 2.3: AppBootstrapApi

**Files:**
- Create: `lib/backend/data/app_bootstrap_api.dart`
- Test: `test/backend/data/app_bootstrap_api_test.dart`

**Interfaces:** `class AppBootstrapApi { AppBootstrapApi(ApiClient client); Future<AppBootstrap> fetch(); }` → `GET /mobile/app/bootstrap?platform=&version=`.

- [ ] **Step 1–5:** Standard TDD. Commit `feat(backend/data): AppBootstrapApi`.

### Task 2.4: PlatformAnnouncementsApi

**Files:**
- Create: `lib/backend/data/platform_announcements_api.dart`
- Test: `test/backend/data/platform_announcements_api_test.dart`

**Interfaces:** `class PlatformAnnouncementsApi { PlatformAnnouncementsApi(ApiClient client); Future<List<PlatformAnnouncement>> list({String audience = 'display'}); }` → `GET /mobile/announcements?scope=platform&audience=display`.

> Confirm the exact query contract against the backend route during integration; the contract section flags `scope`/`audience` as the filters.

- [ ] **Step 1–5:** TDD. Commit `feat(backend/data): PlatformAnnouncementsApi`.

### Task 2.5: DisplayApi (REST snapshot)

**Files:**
- Create: `lib/backend/data/display_api.dart`
- Test: `test/backend/data/display_api_test.dart`

**Interfaces:** `class DisplayApi { DisplayApi(ApiClient client); Future<MosqueBootstrap> snapshot(String publicSlug); }` → `GET /display/mosques/{publicSlug}/snapshot` (no auth; the `ApiClient` already supports `extra['skipAuth'] = true` per the interceptor).

> The snapshot response carries a `serverTime` field the bootstrap does not; capture it in `MosqueBootstrap` as an optional `DateTime?` and ignore it for the authenticated bootstrap (will be null there). Alternatively define a thin wrapper `DisplaySnapshot { MosqueBootstrap bootstrap; DateTime serverTime; }` — pick whichever feels cleaner; the display UI may want `serverTime` for clock-skew correction.

- [ ] **Step 1–5:** TDD. Commit `feat(backend/data): DisplayApi snapshot`.

### Task 2.6: DisplaySocket (public WebSocket)

**Files:**
- Create: `lib/backend/data/display_socket.dart`
- Test: `test/backend/data/display_socket_test.dart`

**Interfaces:**

```dart
class DisplaySocket {
  DisplaySocket({
    required String publicSlug,
    WebSocketChannel Function(Uri)? connect,    // seam for tests
  });
  Stream<MosqueBootstrap> get snapshots;        // emits on every display.snapshot / display.snapshot.updated
  Stream<DateTime> get heartbeats;              // serverTime from heartbeat frames
  Stream<SocketError> get errors;               // {code, message?, statusCode?} — close codes 1000/1008/1013
  Future<void> dispose();
}
```

Implementation requirements:
- Build the WS URI by rewriting `ApiConfig.baseUrl` http→ws / https→wss and appending `/display/mosques/{publicSlug}/ws`.
- Parse frames: `display.snapshot` and `display.snapshot.updated` → `MosqueBootstrap.fromJson(frame['snapshot'])` → push to `snapshots`. `heartbeat` → push `serverTime` to `heartbeats`. `error` → push to `errors`.
- Reconnect on close with exponential backoff (1s → 30s cap), reset backoff on first successful frame. Honor close codes per the contract: 1000 = clean (don't reconnect), 1008 = policy (emit error, then back off heavily), 1013 = try-again-later (immediate-ish retry with backoff).
- No resume-by-revision — every reconnect just yields a fresh full snapshot.

- [ ] **Step 1:** Failing test using a fake channel (StreamController-backed `WebSocketChannel` impl, or a `connect` seam returning an abstract `WsLike`) that pushes a `display.snapshot` JSON frame and expects a `MosqueBootstrap` on `snapshots`.

- [ ] **Step 2–5:** Standard TDD. Add a separate test for: heartbeat frame → emission on `heartbeats`; error frame → emission on `errors`; reconnect backoff (use a fake clock or short-circuited backoff for testability).

- [ ] **Step 5:** Commit `feat(backend/data): DisplaySocket with reconnect`.

**Gate (Step 2):** every backend endpoint group has a thin typed API client returning Step 1 entities; full test suite for all clients passes against `http_mock_adapter`; the display WebSocket parses real frames from the local backend (manual integration check: run `lib/backend/main_backend.dart` with a smoke harness against `localhost:8000` — see Step 4 — and confirm a snapshot arrives). The Firebase app is still untouched and still runs.

---

## Step 3 — Repositories + caching + sync-revision

Goal: stateful, cache-aware repositories sitting on top of the API clients. They are what the UI (Step 4) actually binds to. Each repository owns its own caching strategy and (where relevant) `syncRevision` tracking. Cache lives in fresh Hive boxes scoped to the backend stack; the old `CacheFirstLoader`/`JsonCache`/`ICacheStore` are NOT reused.

### Task 3.1: Bootstrap cache

**Files:**
- Create: `lib/backend/cache/bootstrap_cache.dart` (Hive box for `MosqueBootstrap` keyed by `mosqueId`, value JSON-encoded)
- Create: `lib/backend/cache/app_bootstrap_cache.dart` (single-entry Hive box for `AppBootstrap`)
- Test: `test/backend/cache/bootstrap_cache_test.dart`

**Interfaces:**
- `class BootstrapCache { Future<void> init(); Future<MosqueBootstrap?> read(String mosqueId); Future<void> write(MosqueBootstrap bootstrap); Future<void> clear(String mosqueId); Future<void> clearAll(); }`
- `class AppBootstrapCache { Future<void> init(); Future<AppBootstrap?> read(); Future<void> write(AppBootstrap b); Future<void> clear(); }`

Notes:
- Box names: `backend.bootstrap`, `backend.app_bootstrap` (the `backend.` prefix prevents collision with any Hive box the Firebase app already uses).
- Values stored as `Map<String, dynamic>` JSON (the entity's `toJson()`), so schema changes don't require a Hive type adapter regeneration.
- `init()` is idempotent; the DI module calls it once during `registerBackendModule`.

- [ ] **Step 1–5:** Standard TDD with Hive's in-memory test backend (`Hive.init(tempDir)` in `setUp`). Commit `feat(backend/cache): bootstrap caches`.

### Task 3.2: AuthRepository

**Files:**
- Create: `lib/backend/repositories/auth_repository.dart`
- Test: `test/backend/repositories/auth_repository_test.dart`

**Interfaces:**

```dart
class AuthRepository {
  AuthRepository(AuthApi api, TokenStore tokens, DeviceRegistrar registrar);

  // State
  AppUser? get currentUser;
  Stream<AppUser?> get currentUserChanges;
  String? get activeMosqueId;
  bool get passwordChangeRequired;

  // Lifecycle
  Future<AppUser?> restore();                       // call at app start: read tokens -> GET /me -> emit user
  Future<AuthSession> login(String email, String password);
  Future<void> logout();
  Future<void> logoutOtherSessions();

  // Profile
  Future<AppUser> updateProfile({String? fullName, String? phone, String? activeMosqueId});
  Future<void> changePassword(String current, String next);

  // Push
  Future<void> registerFcmToken(String token);      // delegates to DeviceRegistrar
}
```

Behavior:
- `restore()`: if access token present, call `me()`; on success emit user, persist `activeMosqueId` to `TokenStore`. On failure, clear tokens silently and return null.
- `login()`: persist tokens + `activeMosqueId` + (if surfaced) the active mosque's `publicSlug` to `TokenStore`; emit user; fire-and-forget call `DeviceRegistrar.register(<current FCM token>)`.
- `changePassword()`: capture the new tokens returned by `/auth/change-password` and update `TokenStore`.
- `updateProfile()`: call `PATCH /me`, re-emit the updated user. If `activeMosqueId` changed, also update `TokenStore`.

- [ ] **Step 1–5:** TDD with `mocktail` faking `AuthApi`/`DeviceRegistrar`; assert token persistence in a real `TokenStore` over `FlutterSecureStorage.setMockInitialValues({})`. Commit `feat(backend/repositories): AuthRepository`.

### Task 3.3: DeviceRegistrar + FcmReceiver

**Files:**
- Create: `lib/backend/services/device_registrar.dart`
- Create: `lib/backend/services/fcm_receiver.dart`
- Test: `test/backend/services/device_registrar_test.dart`

**Interfaces:**
- `class DeviceRegistrar { DeviceRegistrar(AuthApi api); Future<void> register(String pushToken, {String? deviceId}); }` — builds `{deviceId?, deviceKind: ApiConfig.platform, notificationProvider: 'fcm', pushToken, clientInfo:{platform, appVersion}}` and calls `auth_api.putDevice(...)`. Swallows `ApiException` (logs only).
- `class FcmReceiver { FcmReceiver(AuthRepository auth); Future<void> start(); }` — wraps `firebase_messaging`: initialize Firebase if not already; request permission on iOS; subscribe to `onTokenRefresh` → `auth.registerFcmToken(token)`; surface foreground/background message streams for the UI to handle. **Touches `firebase_messaging` only** — no `firebase_auth`, no `cloud_firestore`. This is the only Firebase coupling the new stack has, and it survives cutover.

- [ ] **Step 1–5:** Standard TDD for `DeviceRegistrar` (mock `AuthApi`, assert payload). `FcmReceiver` is integration-tested via the smoke harness in Step 4 — its unit test is a thin one asserting it wires `onTokenRefresh` to `auth.registerFcmToken`. Commit `feat(backend/services): DeviceRegistrar + FcmReceiver`.

### Task 3.4: MosqueRepository (reads + cache + syncRevision)

**Files:**
- Create: `lib/backend/repositories/mosque_repository.dart`
- Test: `test/backend/repositories/mosque_repository_test.dart`

**Interfaces (this task = reads only):**

```dart
class MosqueRepository {
  MosqueRepository(MosqueApi api, BootstrapCache cache, TokenStore tokens, AuthRepository auth);

  Stream<MosqueBootstrap?> get current;     // emits cached value immediately, then refreshes from server

  Future<MosqueBootstrap?> load({bool forceRefresh = false});  // cache-first; if forceRefresh, bypass cache
  Future<MosqueBootstrap> refresh();         // always hits the server; updates cache + syncRevision

  int? get cachedSyncRevision;
}
```

Behavior:
- `load(forceRefresh: false)`: emit cached value (if any) immediately, kick off a background refresh, emit the fresh value when it arrives. If no cache, just refresh.
- `refresh()`: `api.bootstrap(activeMosqueId)` → write to `BootstrapCache` → save `syncRevision` to `TokenStore` → emit on `current`.
- The active mosque id comes from `auth.activeMosqueId`. If null, `current` emits `null` and `load`/`refresh` throw a `StateError('No active mosque')`.

- [ ] **Step 1–5:** TDD: cache-then-server emission order, write-through to cache, syncRevision persistence. Commit `feat(backend/repositories): MosqueRepository reads`.

### Task 3.5: MosqueRepository (writes)

**Files:**
- Modify: `lib/backend/repositories/mosque_repository.dart`
- Test: extend `test/backend/repositories/mosque_repository_test.dart`

**Interfaces (added):**

```dart
  Future<void> updateProfile(MosqueProfilePatch patch);
  Future<void> updatePrayerSettings(PrayerSettings settings);
  Future<void> updateDisplaySettings(DisplaySettings settings);
  Future<void> postPublishedAlbum({required String url, required int durationSeconds, required String fit});
  Future<void> removePublishedAlbum();
  Future<void> replaceReligiousContent(ReligiousContent content);

  // Content CRUD — repo owns the diffing between the user's edited list and the server's list
  Future<void> applyContentChanges({
    required List<ContentItemCreate> creates,
    required List<ContentItemPatch> patches,    // each carries id
    required List<String> deleteIds,
  });

  // Announcements CRUD — same pattern
  Future<void> applyAnnouncementChanges({
    required List<AnnouncementCreate> creates,
    required List<AnnouncementPatch> patches,
    required List<String> deleteIds,
  });

  // Alerts
  Future<void> sendAlert(AlertCreate alert);
  Future<void> cancelAlert(String id);
  Future<void> cancelAllAlerts();
```

Behavior shared by every write:
1. Call the matching `MosqueApi` method.
2. Capture the returned `syncRevision`; persist to `TokenStore`.
3. Refresh the bootstrap (`api.bootstrap(...)` → cache → emit on `current`). Don't optimistically merge in the response's partial entity — always re-fetch the full bootstrap, since announcements/content CRUD return only the changed item and the cached bootstrap needs to reflect the full new state.

> The full re-fetch costs one extra round-trip per write; it's the price of not maintaining a cross-entity diff/merge layer. If a specific write becomes hot (e.g. dragging to reorder content items), add an optimistic in-cache update for that path later — but treat optimism as an optimization, not the default.

- [ ] **Step 1–5:** TDD per write group. Commit `feat(backend/repositories): MosqueRepository writes (<group>)` per area.

### Task 3.6: AppSettingsRepository (stale-while-revalidate)

**Files:**
- Create: `lib/backend/repositories/app_settings_repository.dart`
- Test: `test/backend/repositories/app_settings_repository_test.dart`

**Interfaces:**

```dart
class AppSettingsRepository {
  AppSettingsRepository(AppBootstrapApi api, AppBootstrapCache cache);
  Stream<AppBootstrap?> get current;
  Future<AppBootstrap?> load();      // cache-first, background refresh
  Future<AppBootstrap> refresh();
}
```

`AppBootstrap` is near-static (support phone, background library, update banner, about categories). Cache-first with a single background refresh per session is sufficient — no `syncRevision` here.

- [ ] **Step 1–5:** TDD. Commit `feat(backend/repositories): AppSettingsRepository`.

### Task 3.7: PlatformAnnouncementsRepository

**Files:**
- Create: `lib/backend/repositories/platform_announcements_repository.dart`
- Test: `test/backend/repositories/platform_announcements_repository_test.dart`

**Interfaces:**

```dart
class PlatformAnnouncementsRepository {
  PlatformAnnouncementsRepository(PlatformAnnouncementsApi api);
  Future<List<PlatformAnnouncement>> list();
  Stream<List<PlatformAnnouncement>> watch();   // emits once on subscribe (fresh fetch); optionally polls every N minutes
}
```

Active-window filtering (`startAt <= now <= endAt && isActive`) is the **UI's** responsibility — the repository returns everything the server returns; the bloc filters by current time. This keeps the repo simple and lets the UI re-filter as the wall clock advances without a refetch.

- [ ] **Step 1–5:** TDD. Commit `feat(backend/repositories): PlatformAnnouncementsRepository`.

### Task 3.8: DisplayRealtimeRepository (WS + REST fallback)

**Files:**
- Create: `lib/backend/repositories/display_realtime_repository.dart`
- Test: `test/backend/repositories/display_realtime_repository_test.dart`

**Interfaces:**

```dart
class DisplayRealtimeRepository {
  DisplayRealtimeRepository(DisplayApi rest, DisplaySocket Function(String) socketFactory);
  Stream<MosqueBootstrap> watch(String publicSlug);  // emits REST snapshot first, then WS frames
  Stream<DateTime> heartbeats(String publicSlug);
  Future<void> dispose();
}
```

Behavior:
- On `watch(slug)`: fire `DisplayApi.snapshot(slug)` for an immediate first emission (the WS will also yield a snapshot shortly, but the REST call lets the UI paint without waiting for the socket handshake). Then open the socket and forward `snapshots` onward. Heartbeats stream lets the UI show a connection indicator.
- One active socket per slug at a time; calling `watch` again with the same slug returns the same broadcast stream. Different slugs → separate sockets.

- [ ] **Step 1–5:** TDD using fakes for both `DisplayApi` and `DisplaySocket`. Commit `feat(backend/repositories): DisplayRealtimeRepository`.

### Task 3.9: SyncRevisionPoller

**Files:**
- Create: `lib/backend/repositories/sync_revision_poller.dart`
- Test: `test/backend/repositories/sync_revision_poller_test.dart`

**Interfaces:**

```dart
class SyncRevisionPoller {
  SyncRevisionPoller(MosqueRepository mosque, TokenStore tokens, {Duration pollInterval = const Duration(minutes: 5)});
  void start();
  void stop();
  Future<void> refreshIfStale();   // call from app-lifecycle resume / pull-to-refresh
}
```

Behavior:
- The backend doesn't currently expose a cheap "head revision" endpoint, so `refreshIfStale()` simply calls `mosque.refresh()` (the full bootstrap GET). The interface name is forward-looking: if the backend later adds `GET .../mosques/{id}/sync-revision`, swap the implementation without changing callers. Document this in the file's header comment.
- `start()`: optional periodic timer firing `refreshIfStale` every `pollInterval`. Off by default — the UI calls `refreshIfStale` on resume/pull-to-refresh. The poller is provided for screens that want true background freshness.

> The previous plan revision over-engineered this with "compare revision" logic the backend doesn't support. Keep it simple: the authenticated app refreshes its bootstrap on resume / pull / after writes. If the user reports staleness in practice, add server-side polling support and revisit.

- [ ] **Step 1–5:** TDD. Commit `feat(backend/repositories): SyncRevisionPoller`.

### Task 3.10: Wire repositories into the backend DI module

**Files:**
- Modify: `lib/backend/di/backend_module.dart`
- Modify: `test/backend/di/backend_module_test.dart`

- [ ] **Step 1:** Extend the test to resolve every new repository / API / cache type registered.

- [ ] **Step 2:** FAIL.

- [ ] **Step 3:** Register everything: all 5 API clients (Task 2.x), both caches (3.1), all 5 repositories (3.2/3.4/3.6/3.7/3.8), `SyncRevisionPoller` (3.9), `DeviceRegistrar` (3.3), `FcmReceiver` (3.3). Run `BootstrapCache.init()` and `AppBootstrapCache.init()` inside `registerBackendModule` before any consumer can resolve them.

- [ ] **Step 4:** PASS.

- [ ] **Step 5:** Commit `feat(backend/di): wire repositories + caches + services`.

**Gate (Step 3):** the new stack can, given a logged-in token in `TokenStore`, fetch + cache + emit a full `MosqueBootstrap` for the active mosque; write paths persist and re-fetch; the display socket emits live snapshots; the auth repository drives login/logout/profile/password without a single Firebase call. The Firebase app is still untouched and still runs.

---

## Step 4 — UI rebuild + end-to-end harness

Goal: rebuild the user-facing app (blocs + widgets + screens + routing) on top of the new entities and repositories. The previous Firebase-backed UI under `lib/features/` is left untouched; the new UI lives under `lib/backend/ui/` and ships with a `main_backend.dart` entry point that runs the entire new stack end-to-end against the local backend. This is where the bulk of the implementation work happens.

> **Scope of UI work.** Read the inventory under `lib/features/` once at the start of Step 4 and produce a list (`docs/superpowers/plans/step4-ui-inventory.md`) of every screen/bloc the Firebase app exposes today: splash, login, change-password, home, prayer settings, iqama settings, religious content (per kind), announcements, alerts, album/published album, design settings, profile, language picker, about, support, display screen, etc. Each item in the inventory becomes a sub-task under 4.x with the corresponding new bloc/widget. Whatever shared widgets the new screens need (buttons, dialogs, form fields, list rows) that don't already exist in a Firebase-coupled state are added under `lib/backend/ui/common/`.

> **Reusable widgets caveat.** Some widgets in `lib/features/` may not depend on `MosqueModel` or Firebase types — pure presentation. The Step 4 sub-tasks may import those directly without porting, but only if the import does NOT pull a Firebase/MosqueModel transitive dependency. Verify by `grep -rIn 'package:firebase\|MosqueModel' lib/features/<widget_path>.dart` — clean means safe to import.

### Task 4.0: Standalone entrypoint + smoke harness

**Files:**
- Create: `lib/backend/main_backend.dart`
- Create: `lib/backend/ui/_smoke_app.dart`

A throwaway `runApp` target that:
1. Initializes Hive + Firebase (for `firebase_messaging` only).
2. Calls `registerBackendModule(GetIt.asNewInstance())` into a private locator.
3. Calls `AuthRepository.restore()`.
4. Shows a tiny "smoke" widget tree with login / show-bootstrap / display-WS / logout buttons. Not a real UI — just enough to verify the stack end-to-end against the local backend.

- [ ] **Step 1:** Implement the harness. No tests required (it's not user-facing).
- [ ] **Step 2:** Run it.

```bash
flutter run -t lib/backend/main_backend.dart \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1 \
  --dart-define=DISPLAY_PUBLIC_SLUG=<slug-from-seed>
```

Manually verify: login with a seeded user → bootstrap renders → display WS streams snapshots → logout clears tokens → relaunch session restores.

- [ ] **Step 3:** Commit `feat(backend/ui): standalone smoke harness for end-to-end testing`.

### Tasks 4.1–4.N: Per-screen rebuild

For each item in the inventory file, run a sub-task with the standard shape:

**Files (per sub-task):**
- Create: `lib/backend/ui/<feature>/<screen>_screen.dart`
- Create: `lib/backend/ui/<feature>/bloc/<feature>_bloc.dart` (+ `event.dart`, `state.dart` if multi-file blocs are the project style)
- Test: `test/backend/ui/<feature>/<feature>_bloc_test.dart`

**Per sub-task TDD shape:**

- [ ] **Step 1: Write the failing bloc test** using `bloc_test`, mocking the repositories the bloc consumes. Drive the bloc through its happy path + at least one error path; assert state transitions and repository method calls.

- [ ] **Step 2:** Run → FAIL.

- [ ] **Step 3: Implement the bloc** binding to the new entities and repositories. The bloc holds only what this feature needs (e.g. `PrayerSettings` for the prayer-settings screen) — not the whole `MosqueBootstrap`. Shared state (current `MosqueBootstrap`, current `AppUser`) comes via DI from the repositories' streams.

- [ ] **Step 4: Implement the widget** matching the existing Firebase UI's visual design — same colors, layout, copy — but bound to the new bloc + entities. Use Flutter's `flutter_test` widget tests where presentation logic is non-trivial.

- [ ] **Step 5:** Wire the screen into the harness's navigation graph so the smoke harness can drive it manually.

- [ ] **Step 6:** PASS. Commit `feat(backend/ui): <feature> screen + bloc`.

Group of sub-tasks (one Task per group, multiple sub-tasks of the shape above inside each):

- **4.1 Auth surface:** splash routing (token? → `restore()` → home or login or change-password), login, change-password, logout.
- **4.2 Profile + language:** profile screen (read user from `AuthRepository`, mutate via `updateProfile`); change-password (delegates to auth); language picker (drives `LanguageBloc` which reacts to `AuthRepository.currentUserChanges`).
- **4.3 Mosque header + home:** the home/landing screen showing the active mosque's name/city/prayer times — bound to `MosqueRepository.current` (`MosqueBootstrap` stream).
- **4.4 Prayer + iqama settings:** edit `PrayerSettings`, save via `MosqueRepository.updatePrayerSettings`.
- **4.5 Display/design settings:** edit `DisplaySettings`, save via `MosqueRepository.updateDisplaySettings` (full-replace). Includes the album/published-album sub-screen with `postPublishedAlbum`/`removePublishedAlbum`.
- **4.6 Religious content:** four screens (hadith/verse/dua/adhkar). Each shows the relevant list from `MosqueBootstrap.content` filtered by kind; edits assemble the new full `ReligiousContent` from the current cached state with the one edited list and call `replaceReligiousContent`.
- **4.7 Announcements:** list, create, edit, delete — calls `applyContentChanges`-style diffing built around `AnnouncementCreate`/`Patch`/`deleteIds` against the current `MosqueBootstrap.announcements`.
- **4.8 Alerts:** send alert, cancel, cancel all — direct `MosqueRepository.sendAlert`/`cancelAlert`/`cancelAllAlerts`.
- **4.9 App settings consumers:** about screen, support phone link, update banner — bound to `AppSettingsRepository`.
- **4.10 Platform announcements:** UI ticker / list bound to `PlatformAnnouncementsRepository`, with active-window filtering in the bloc.
- **4.11 Display screen:** bound to `DisplayRealtimeRepository.watch(publicSlug)`. The `publicSlug` comes from `AuthRepository.activeMosque.publicSlug` for a logged-in device, or from `--dart-define=DISPLAY_PUBLIC_SLUG=` for a standalone display kiosk.
- **4.12 FCM glue:** `FcmReceiver.start()` is wired in `main_backend.dart`'s startup; foreground message handling shows the standard in-app notification surface (or whatever the existing UI does — match it).

### Task 4.Z: End-to-end acceptance

- [ ] **Step 1:** Run the full smoke harness against the local backend with seeded data.

```bash
flutter run -t lib/backend/main_backend.dart --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

- [ ] **Step 2:** Execute the acceptance checklist:

  - Login → splash → home shows mosque name + prayer times sourced from `bootstrap`.
  - Edit prayer settings → save → home reflects the change → kill app → relaunch → change persists.
  - Same loop for display settings, religious content (each kind), announcements, alerts.
  - Logout → relaunch → splash routes to login.
  - Migrated user with `passwordChangeRequired=true` → forced to change-password screen → after change, tokens rotate and routes to home.
  - Open display screen for the same mosque (`--dart-define=DISPLAY_PUBLIC_SLUG=`) → live snapshot renders → edit on the authenticated side → the display reflects the change within seconds.
  - FCM token registers (check `user_devices` table); a test push arrives via `firebase_messaging`.
  - Force-expire the access token (or wait its lifetime) → next protected call → `AuthInterceptor` refreshes once → call succeeds.

- [ ] **Step 3:** Fix any remaining gaps and re-run until the checklist is clean.

- [ ] **Step 4:** Commit `test(backend): end-to-end acceptance harness pass`.

**Gate (Step 4):** the entire feature surface the Firebase app exposes today is rebuilt under `lib/backend/ui/`; every flow on the acceptance checklist passes against the local backend; the new stack is ready for cutover. The Firebase app is STILL untouched and still runs unchanged on `lib/main.dart`.

---

## Step 5 — Cutover + delete Firebase

Goal: one coherent step. The new stack takes over `main.dart`, the Firebase tree is deleted, the Firebase SDK deps that are no longer needed are removed. The result is a single-stack codebase: `lib/backend/` plus whatever non-Firebase shared code (theming, l10n strings, assets) survives the deletion.

> **Pre-req:** Step 4's acceptance checklist passes against a real backend with imported production-shape data. The cutover is destructive; make a checkpoint branch / commit before starting.

### Task 5.1: Repoint `main.dart`

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1:** Replace `main.dart`'s body with the contents of `lib/backend/main_backend.dart`'s `main` function (Hive init + Firebase init for messaging + `registerBackendModule` + `AuthRepository.restore()` + `runApp(<new root widget>)`). The "new root widget" wraps the routing/navigation graph built in Step 4.

- [ ] **Step 2:** Run the app from `main.dart`.

```bash
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1 \
  --dart-define=DISPLAY_PUBLIC_SLUG=<slug>
```

Expected: the new stack starts. Login, navigation, every screen works exactly as it did under the smoke harness — because it IS the smoke harness now, just from the canonical entry point.

- [ ] **Step 3:** Commit `feat(cutover): point main.dart at the backend stack`.

### Task 5.2: Delete the Firebase tree

**Files (delete entirely):**
- `lib/core/` (every file — service locator, network primitives, services, realtime, config, constants, enums shared with Firestore)
- `lib/data/` (every file — old models incl. `MosqueModel`, repositories, datasources, interfaces, DTOs, cache layer)
- `lib/features/` (every file — old blocs, screens, widgets)
- `lib/backend/main_backend.dart` (the smoke harness is now redundant; `main.dart` is the entry point)
- `lib/backend/ui/_smoke_app.dart` if it's not used by the real navigation graph

**Files that survive:** `lib/backend/**`, `lib/main.dart`, `lib/l10n/**` (if locales exist there), `lib/assets/**` or wherever assets sit if not in `assets/` at the project root.

- [ ] **Step 1:** Delete. Be deliberate: `git rm -r lib/core lib/data lib/features` (followed by the manual removals listed). If anything is genuinely shared (e.g. an i18n loader, a global theme widget) and lives under one of those trees, MOVE it to `lib/backend/common/` (or `lib/shared/`, whichever the project standard is) BEFORE deletion — don't lose it in the sweep.

- [ ] **Step 2:** Run `flutter analyze`. Every error reported is a dangling import to a deleted file — these are the compile-time proof that the Firebase tree is gone. Fix each by removing the import (it should be unused now) or by porting the missing dependency into `lib/backend/`.

- [ ] **Step 3:** Run `flutter test`. The old `test/` subtrees that mirrored `lib/core/` / `lib/data/` / `lib/features/` must also be deleted — `git rm -r test/core test/data test/features` (or whatever paths exist). Only `test/backend/` remains.

- [ ] **Step 4:** Run the app.

Run: `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1`
Expected: identical behavior to Task 5.1 — the deletion changed nothing the user can see.

- [ ] **Step 5:** Commit `refactor(cutover): delete the entire Firebase tree`.

### Task 5.3: Remove Firebase SDKs that are no longer needed

**Files:**
- Modify: `pubspec.yaml` — remove `cloud_firestore` and `firebase_auth`. Keep `firebase_core` and `firebase_messaging`.
- Delete: `firestore.rules`, `firestore.indexes.json`, and any Firestore sections of `firebase.json`.

- [ ] **Step 1:** Edit `pubspec.yaml`, then `flutter pub get`.

- [ ] **Step 2:** Run `flutter analyze`. Any remaining reference to `cloud_firestore` or `firebase_auth` (there shouldn't be any after Task 5.2) fails to resolve. Fix by removing the import or the file.

- [ ] **Step 3:** Grep-clean proof — must return zero matches across `lib/` and `test/`:

```bash
grep -rIn --include=*.dart \
  -e 'cloud_firestore' -e 'firebase_auth' \
  -e 'FirebaseFirestore' -e 'FirebaseAuth' \
  -e 'RealtimeTransport' -e 'FirestoreSchema' \
  -e 'MosqueModel' -e 'BackendFlags' \
  lib/ test/
```

Expected: zero matches. (`firebase_core` / `firebase_messaging` matches in `lib/backend/services/fcm_receiver.dart` are allowed and expected.)

- [ ] **Step 4:** Delete the Firestore config files.

- [ ] **Step 5:** Run `flutter test` then `flutter run`. Both should succeed.

- [ ] **Step 6:** Commit `chore: remove cloud_firestore + firebase_auth deps and Firestore config`.

### Task 5.4: Final regression + housekeeping

- [ ] **Step 1:** Re-execute the Step 4.Z acceptance checklist verbatim from `main.dart` (not the smoke harness — that's deleted) against the backend, on each target platform you ship to (Android, iOS, Windows — whatever the project targets).

- [ ] **Step 2:** Update `README.md` / any developer docs in the repo to describe the new stack: `lib/backend/` layout, `--dart-define` knobs (`API_BASE_URL`, `APP_PLATFORM`, `APP_VERSION`, `DISPLAY_PUBLIC_SLUG`), how to run the backend locally, and the fact that Firestore is no longer used.

- [ ] **Step 3:** Delete the Firebase service-account JSON from the repo root **only if** it's not still used by the backend's `firebase-import` tool (it usually is, since the backend keeps importing during the transition window). If it stays, document why in the README.

- [ ] **Step 4:** Commit `docs: update for backend-stack rewrite`.

**Gate (Step 5):** the app compiles and runs entirely off `lib/backend/`. `flutter analyze` is clean; the grep proof is clean; `firebase_messaging` (only) still receives push and registers tokens through `PUT /devices/current`; the full Step 4.Z checklist passes from the canonical `main.dart` entry point on every shipped platform. The Firebase chapter is closed.

---

## Self-review (run before execution handoff)

- **Decision alignment:** every item in the user's 9-decision list is reflected in the plan structure:
  1. No Firebase / Firebase-shaped models long-term → Step 5 removes them; Step 1 forbids Firebase shapes in entities.
  2. mosques-backend is the model source → Step 1 names entities after backend DTOs verbatim.
  3. Clean new Flutter stack → `lib/backend/` houses everything, built fresh.
  4. Detailed backend-matching entities + optional `MosqueBootstrap` aggregate → Task 1.1–1.9 enumerates them; Task 1.7 is `MosqueBootstrap`.
  5. Public display WebSocket via `public_slug` → Task 2.6 (`DisplaySocket`) + Task 3.8 (`DisplayRealtimeRepository`) + Task 4.11 (display screen).
  6. REST + syncRevision/polling for the authenticated app → Task 3.4/3.5 (`MosqueRepository` with `syncRevision` capture on writes) + Task 3.9 (`SyncRevisionPoller`).
  7. Firebase app keeps running in parallel → Steps 1–4 never touch `lib/core/`/`lib/data/`/`lib/features/`; the existing app is byte-for-byte unchanged.
  8. Clean cutover + delete Firebase after the new stack is ready → Step 5 (`main.dart` repoint → delete Firebase tree → remove SDK deps).
  9. Modifying blocs/widgets is in scope → Step 4 rebuilds them from scratch under `lib/backend/ui/`.
- **No `BackendFlags`** anywhere; no DI flag-flipping; no Firebase-to-backend adapter layer; no preserved `IMosqueRepository` / `IAuthRepository` / `MosqueModel`. Verified by re-reading the plan top-down.
- **Verifications carried into execution** (resolve at the named gate, not before):
  - Pubspec `name:` — substitute the real package name in every test import (Task 0.3 note).
  - Backend `ContentItem.kind` enum values (`verse` vs `ayah`, `adhkar` vs `dhikr`) — confirm against importer output in Task 0.8, codify in `ContentKind` enum in Task 1.5.
  - Whether `PlatformAnnouncement` warrants its own entity vs. reusing `Announcement` with `scope=platform` — decide during Task 1.6 based on the actual response shape.
  - `MosqueBootstrap.serverTime` placement (top-level vs nested) — decide during Task 2.5.
  - Exact `POST /alerts` request body — confirm against backend before Task 2.2's alerts sub-commits.
  - `firebase_core` retention vs removal — kept (it's transitively required by `firebase_messaging`). Codified in Step 5 Task 5.3.
- **TDD discipline:** every code task (0.3 through 4.11, plus all 3.x repository tasks) carries explicit Step 1–5 RED/GREEN/COMMIT. Step 4 sub-tasks include both bloc tests and widget tests where appropriate.

---

## Execution Handoff

Plan updated and saved to `docs/superpowers/plans/2026-06-18-firebase-to-backend-migration.md`. The migration is now a clean parallel-stack rewrite culminating in a deletion, not a per-domain flag flip.

Two execution options:

1. **Subagent-Driven (recommended)** — dispatch a fresh subagent per task. Each task is independently committable; review between tasks. Fastest iteration for a plan this large.
2. **Inline Execution** — execute tasks in this session with checkpoints for review.

Which approach?
