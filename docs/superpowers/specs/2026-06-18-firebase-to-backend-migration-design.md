# Firebase → mosques-backend Migration Design

**Date:** 2026-06-18
**Status:** Approved design — no code changes yet
**Scope:** Replace the Flutter app's Firebase dependency (Auth + Cloud Firestore + FCM transport) with the existing `mosques-backend` (FastAPI + Postgres + Redis) REST/WebSocket API. This is a **planning document only**; implementation follows in a separate plan.

---

## 1. Guiding decisions (from the user)

These decisions are the foundation of the whole plan:

1. **The backend is the design source of truth.** We do **not** force the old Firebase/Firestore document shapes through an adapter. We **rebuild** the Flutter models, repositories, and data sources around `mosques-backend`'s actual API contract.
2. **Single source — no dual-source, no adapter/mapper layer.** (Revised 2026-06-18 per user direction.) We are **not** keeping a Firebase-vs-backend runtime switch and we are **not** translating backend DTOs into the old `MosqueModel` shape. We **delete the old models entirely** (`MosqueModel` and all its sub-models, `AppSettingsModel`, the Firestore-shaped `AnnouncementModel`, the `RealtimeTransport`/Firestore layer) and replace them with **new backend-native models** built from the backend's DTOs. Rationale (user): aligning the project to one source — even at the cost of touching many files — is correct and avoids a permanent translation layer that would make future expansion harder.
3. **New models are detailed entities, 1:1 with the backend.** Separate `Mosque`, `PrayerSettings`, `DisplaySettings`, `ContentItem`, `Announcement`, `AppConfig`, `AuthUser`/`AuthSession`, etc. — each a `json_serializable` class matching its backend DTO (camelCase), with a `MosqueBootstrap` aggregate that composes the per-mosque set for convenience. No reconstructed Firestore maps anywhere.
4. **Do not build a new backend.** `mosques-backend` already exists and is the target. We only *use* and (where unavoidable) *extend* it.
5. **Realtime model:** the **display screen** uses the backend's existing public WebSocket (`/display/mosques/{publicSlug}/ws`) keyed by `public_slug`; the **rest of the app** uses REST + `syncRevision`/polling.
6. **Cutover style:** **build the new stack in parallel, then one clean cutover.** Build the networking core, new models, data sources, and repositories as new files (fully unit-tested, not yet wired) while the app keeps running on Firebase untouched. Then perform a single focused cutover: repoint DI to the backend repositories and rewrite every consumer (blocs/states/events/widgets) to the new models, compiler-driven, feature by feature, then delete all Firebase code. There is **no** per-domain runtime flag. Consequence (accepted by user): during the cutover step the app will not compile/run until that step completes — this is the deliberate trade for a clean single source.
7. **HTTP stack:** **dio + flutter_secure_storage**, with interceptor-based auth header + single-flight refresh and a `{success, data, meta}` envelope unwrapper (survey-app architecture, adapted — not copied).
8. **Data migration:** run the backend's built-in `firebase-import` CLI to carry existing Firestore data (mosques, users, content) into Postgres before cutover.

---

## 2. Current state (verified)

### 2.1 Firebase surface area in the Flutter app

Only **three** Firebase services are used. No Storage, Functions, Analytics, Crashlytics, Remote Config, or Dynamic Links.

| Service | Used for | Key files |
|---|---|---|
| **Auth** (email/password only) | login, logout, session, change password | `lib/features/auth/repository/auth_repository.dart`, `lib/data/repositories/interfaces/auth_repository_interface.dart` |
| **Cloud Firestore** | the datastore for mosque, app settings, platform announcements, and per-user docs | `lib/core/realtime/firestore_transport.dart` (the single abstraction) + 3 direct-access user files |
| **FCM** | push notifications (token stored on user doc) | `lib/core/services/firebase_service.dart` |

No anonymous/phone/social auth. No custom claims/roles — authorization is purely `users/{uid}.active_mosque_id` checked in `firestore.rules`. No Firebase Storage — images are already plain external HTTP URLs.

### 2.2 The architecture that helps us

**Firestore is already abstracted behind one interface** (`lib/core/realtime/realtime_transport.dart`), exchanging only plain Dart types (`RemoteDocument`, `RemoteFieldValue`). Its doc comment states the intent: *"Swapping backends means adding one implementation — no repo, model, BLoC, or widget changes."* The three domain repositories (`MosqueRepository`, `AppSettingsRepository`, `PlatformAnnouncementsRepository`) depend only on this interface, and DI registers the implementation in one place (`lib/core/di/service_locator.dart`).

A backend-agnostic **cache-first layer** (`CacheFirstLoader`/`JsonCache` over Hive) sits above the transport and survives the migration unchanged.

### 2.3 The architecture that hurts us

- **Auth leaks Firebase types.** `IAuthRepository` returns `User` / `UserCredential`; these propagate into `LoginBloc`, `SplashRoutingBloc`, `ProfileBloc`, and a widget (`profile_info_card.dart`). `FirebaseAuth.instance` is called *directly* (not via DI) in `firebase_service.dart`, `language_bloc.dart`, and `profile_section.dart`.
- **Three user-doc files bypass the transport** and call Firestore directly: `auth_repository.dart`, `user_active_mosque_repository.dart`, `user_active_mosque_remote_repository.dart`.
- **Shape mismatch.** The app treats a mosque as one flat document with field-scoped writes; the backend decomposes it into `mosques` + `mosque_prayer_settings` + `mosque_display_settings` + `mosque_content_items` + `announcements`, each behind its own endpoint.

### 2.4 The backend (target)

FastAPI + SQLAlchemy(async) + Postgres 16 + Redis 7. Clean/DDD layering. All routes under `/api/v1`, two audiences: `/mobile/*` (our app) and `/dashboard/*` (admin). Unified `{success, data, meta.requestId}` envelope. JWT access (15 min) + rotating refresh (30 day) tokens. FCM fan-out via `firebase-admin` + a notification worker. A complete `firebase-import` CLI exists. The backend ships its own migration contract at `mosques-backend/docs/05-client-handoff.md`, which this plan follows.

---

## 3. Firebase → backend coverage map

For each Firebase need: the backend equivalent and readiness.

| Flutter need (Firebase) | Backend equivalent | Ready? |
|---|---|---|
| Email/password login | `POST /api/v1/mobile/auth/login` | Ready |
| Logout | `POST /api/v1/mobile/auth/logout` (+ `logout-other-sessions`) | Ready |
| Session / token | JWT access + rotating refresh; `POST /api/v1/mobile/auth/refresh` | Ready |
| Change password | `POST /api/v1/mobile/auth/change-password` | Ready |
| Current user (`currentUser`, phone, active mosque) | `GET /api/v1/mobile/me`, `PATCH /api/v1/mobile/me` | Ready |
| FCM token storage | `PUT /api/v1/mobile/devices/current` (`user_devices.push_token`) | Ready (shape differs: per-device rows, not an array) |
| Mosque read (the big `.snapshots()` doc) | `GET /api/v1/mobile/mosques/{mosqueId}/bootstrap` (returns `syncRevision` + `legacyCompatibility.firestoreDocumentId`) | Ready |
| Mosque profile write (name/city/lat/long/lang) | `PATCH /api/v1/mobile/mosques/{mosqueId}` | Ready |
| Prayer + iqama offsets, calc method write | `PUT /api/v1/mobile/mosques/{mosqueId}/prayer-settings` | Ready |
| Design settings write | `PUT /api/v1/mobile/mosques/{mosqueId}/display-settings` | Ready |
| Religious content (hadiths/verses/duas/adhkar) | `GET`/`PUT .../religious-content` (+ generic `content` CRUD) | Ready |
| Mosque ads / announcements | `.../announcements` CRUD (`mosqueAds`→content kind `ad`) | Ready |
| Active alerts | `POST/PATCH/DELETE .../alerts` (announcement type `alert`) | Ready |
| Album image URLs + published album | `mosque_display_settings.album_image_urls`; `POST/DELETE .../display-settings/published-album` | Ready |
| App settings (support phone, about, update info, bg library) | `GET /api/v1/mobile/app/bootstrap` | Ready |
| Platform announcements | `scope='platform'` announcements; surfaced via bootstrap / `includePlatform` | Ready (modeled as rows, not a settings doc + items array) |
| Send push notifications | `POST .../notifications` + notification worker | Ready |
| **Realtime live mosque updates (display)** | `WS /api/v1/display/mosques/{publicSlug}/ws` + `GET .../snapshot` | Ready but **unauthenticated, keyed by `public_slug`** |
| **Realtime live updates (authenticated app screens)** | REST + `syncRevision` reconciliation/polling | Pattern, not a push stream |

### 3.1 Gaps / things the backend does *not* give us as-is

These are **not missing features** so much as deliberate model differences to design around:

1. **No authenticated live-listener stream.** The authenticated app must use `syncRevision` polling; only the public display WS pushes. *(Accepted per decision 3.)*
2. **Public display WS requires `public_slug`.** Every mosque the display screen renders must have a `public_slug`, and the app must know it (returned in the mosque bootstrap as `legacyCompatibility.firestoreDocumentId` / slug). Confirm the import populates it.
3. **FCM token shape.** Single `fcm_token`/`fcm_tokens` array on the user doc → one `user_devices` row per install via `PUT /devices/current`. Client logic changes from "merge into array" to "upsert this device".
4. **Mosque is relational, not one document.** A single Firestore write that touched several fields now maps to several targeted endpoints. The new data source must route field groups to the right endpoint.
5. **Verify nothing else is missing.** Before each domain's cutover, confirm the specific fields the app reads/writes exist in that endpoint's response/request (a per-domain field-parity check — see §6 step gates).

**Anticipated backend additions (only if a parity gap is found):** none are expected to be required for read paths. The most likely candidate is a per-field-group write endpoint the app needs but the backend lumps differently (e.g. writing only `language_code`). The plan keeps backend changes as a *last resort* and scoped — we do not redesign the backend.

---

## 4. Target Flutter architecture

We rebuild the data layer around the backend, reusing the parts that are already backend-agnostic.

### 4.1 New networking core (`lib/core/network/`)

Adapted from survey-app's proven structure (not copied verbatim):

- `dio_client.dart` — single configured `Dio` (base URL from env, timeouts, logging in debug).
- `auth_interceptor.dart` — injects `Authorization: Bearer <access>`; on `401`/`token_expired` performs **single-flight refresh** (one in-flight refresh future shared by all queued requests; survey-app's `_inFlight` coalescing pattern adapted to *refresh* instead of *clear*) then retries; on refresh failure clears session and routes to login.
- `api_envelope.dart` — unwraps `{success, data, meta}`; turns `success:false` / non-2xx into a typed `ApiException` carrying backend `error.code` (clients branch on `code`, never English text — per handoff §"Client Error Handling").
- `token_store.dart` — access + refresh tokens in `flutter_secure_storage`; active mosque id + last `syncRevision` per mosque also persisted.
- `api_config.dart` — base URL per environment via `--dart-define` (the app already uses dart-define elsewhere).

### 4.2 New auth abstraction (kills the Firebase leak)

- Redefine `IAuthRepository` to return **app-owned types** (`AppUser`, `AuthSession`) — remove `User`/`UserCredential` entirely.
- New `BackendAuthRepository` implements it against `/mobile/auth/*` + `/mobile/me`.
- Update the ~5 leak sites (`LoginBloc`, `SplashRoutingBloc`, `ProfileBloc`, `profile_section.dart`, `profile_info_card.dart`, `language_bloc.dart`) to consume `AppUser` and resolve auth via DI instead of `FirebaseAuth.instance`.
- Active-mosque resolution moves from `users/{uid}` Firestore reads to `/mobile/me` (with the same SharedPreferences cache for offline tolerance).

### 4.3 New models, data sources & repositories (single source, rebuilt to the backend contract)

We **delete `RealtimeTransport`, `FirestoreTransport`, and every Firebase-shaped model** (`MosqueModel`, `DesignSettingsModel`/`DesignColorSettings`/`FontSizeSettings`/`DesignBackgroundSettings`, `IqamaSettingsModel`, `PrayerOffsetsModel`, `AnnouncementModel`, `MosqueTextEntryModel` + `HadithModel`/`VerseModel`/`DuaModel`/`AdhkarModel`, `AppSettingsModel`/`AppUpdateModel`/`AboutCategoryModel`). There is **no** adapter/mapper layer translating backend JSON into these shapes — the app's models **are** the backend's DTOs.

**New backend-native models** (`json_serializable`, camelCase fields matching the API verbatim, one Dart file per entity under `lib/data/models/`):

- `Mosque` — `id, publicSlug, name, city, countryCode, latitude(String), longitude(String), timezone, languageCode, defaultRiwayahCode, syncRevision`.
- `PrayerSettings` — `mosqueId, calculationMethod, offsets (PrayerOffsets: fajr/sunrise/dhuhr/asr/maghrib/isha), iqamaOffsets (IqamaOffsets: fajr/dhuhr/asr/maghrib/isha/jummah), preAdhanMinutes, adhanMomentDurationSeconds`.
- `DisplaySettings` — full field set per backend contract: all color fields, font/size fields, ticker/strip speeds, published-album fields (`albumImageUrls`, `publishedAlbumUrl`, `publishedAlbumActive`, `publishedAlbumExpiresAt`, etc.), `numeralFormat`, `fontFamily`.
- `ContentItem` — `id, kind, text, narrator, source, isActive, displayOrder, createdAt, updatedAt` (general content items use `displayOrder`; religious-content items use `order`).
- `Announcement` — `id, scope, audience, announcementType, title, subtitle, startAt, endAt, qrCodeUrl, isActive, isPriority, displayDurationSeconds, displayOrder, createdAt, updatedAt`.
- `AppConfig` — the `/mobile/app/bootstrap` response shape (support phone, background library URLs, about categories, update info).
- `AuthUser`, `AuthSession`, `AuthMosqueSummary` — the `/mobile/auth/login` response shapes (`latitude`/`longitude` on `AuthMosqueSummary` are Strings).
- `MosqueBootstrap` — aggregate matching `GET /mobile/mosques/{id}/bootstrap` exactly: `{mosque, prayerSettings, displaySettings, content[], announcements[], platformAnnouncements[], syncRevision, legacyCompatibility:{firestoreDocumentId}}`. This aggregate is what the display/settings repositories cache as a unit; individual screens read the sub-object they need.

**New data sources** (one per backend resource group, under `lib/data/datasources/`):

- `MosqueRemoteDataSource` → read: `GET .../mosques/{id}/bootstrap`; writes: one method per targeted endpoint (mosque PATCH, prayer-settings PUT, display-settings PUT, published-album POST/DELETE, religious-content GET/PUT, content CRUD, announcements CRUD, alerts POST/PATCH/DELETE). Every write returns the new `syncRevision`.
- `AppConfigRemoteDataSource` → `GET /mobile/app/bootstrap`.
- `AuthRemoteDataSource` → login, refresh, logout, change-password, get/patch me, register device.
- `DisplayWebSocketDataSource` → connects to `/display/mosques/{publicSlug}/ws`; applies full `display.snapshot` frames; reconnects with backoff; initial paint via `GET .../snapshot`.

**Repository interfaces are rewritten** (not preserved with old signatures): `IMosqueRepository`, `IAppConfigRepository` (renamed from `IAppSettingsRepository`), `IPlatformAnnouncementsRepository`, and `IAuthRepository` are all redefined in terms of the new models. The **cache-first pattern and Hive `JsonCache`/`ICacheStore` layer stay** — only the type parameter changes (e.g. `JsonCache<MosqueBootstrap>` instead of `JsonCache<MosqueModel>`). Every BLoC, state, event, and widget that references an old model type is rewritten to use the new one during the cutover step (§6).

### 4.4 Realtime

- **Display screen:** new `DisplayWebSocketDataSource` using `web_socket_channel`, connecting to `/display/mosques/{publicSlug}/ws`, applying full snapshots, reconnecting with `lastSyncRevision`, with backoff. Initial paint via `GET .../snapshot`.
- **Authenticated settings screens:** after each mutation, read returned `syncRevision`; refresh local mosque bootstrap if stale. Optional light polling while a settings screen is focused.

### 4.5 FCM

- Keep the `firebase_messaging` SDK for *receiving* push and acquiring the token.
- Replace token persistence: instead of writing to `users/{uid}`, call `PUT /mobile/devices/current` on token acquisition and on `onTokenRefresh`.
- Remove the `users/{uid}` FCM write path.

### 4.6 Cutover strategy (build in parallel, then one clean switch)

There is **no per-domain runtime flag and no dual-source DI selector.** The migration has three distinct stages:

1. **Build in parallel (app still runs on Firebase unchanged).** All new code — networking core, new models, new data sources, new repositories — is written as new files alongside the existing Firebase code. Unit tests are green. DI is **not** re-pointed yet. Firebase continues to serve the live app.

2. **One clean cutover (app does not compile until the step is complete — accepted trade-off).** In a single focused session: re-point DI to the new backend repositories; rewrite every consumer — blocs, states, events, widgets — to the new model types, feature by feature, following the compiler's type errors as a guide. There is no compatibility shim. The app is offline (won't compile) during this window.

3. **Delete all Firebase code.** Once the app compiles and passes regression, delete: `RealtimeTransport`, `FirestoreTransport`, all old models, the three direct-access user files, Firebase DI registrations, `firestore.rules`/`firestore.indexes.json`, and the `cloud_firestore`/`firebase_auth` deps (keep `firebase_messaging` for FCM receive only).

---

## 5. Data migration (Firestore → Postgres)

Before cutover (and re-runnable, since the importer is idempotent):

1. Configure `mosques-backend` `.env` with Firebase admin credentials (the service-account JSON already present in the repo root) and Postgres.
2. Run `firebase-import --dry-run` to validate mapping and review the report.
3. Run `firebase-import --apply` to load mosques/users/content into Postgres.
4. Verify: old Firestore mosque doc ID → `mosques.public_slug`; users carry `legacy_firebase_uid`; content kinds mapped (`ayah`/`hadith`/`dua`/`dhikr`/`ad`/`alert`); FCM tokens → `user_devices`.
5. **Critical check:** confirm every migrated mosque has a non-null `public_slug` (the display WS depends on it) and that user passwords are handled — Firebase passwords are *not* exportable, so plan a **first-login password reset / temporary-password** path for migrated users (the backend already supports `password_change_required`).

> **Password caveat:** Firebase Auth password hashes don't transfer. Migrated users will need a password-set flow (temporary password + forced change, or a reset link). This must be decided before cutover of the auth domain.

---

## 6. Migration sequence (safe, incremental, dual-source)

Each step ends with a **gate**: app still runs, migrated domain verified end-to-end against the backend, Firebase still serving the rest.

**Step 0 — Foundations (no behavior change).**
Add dio/secure_storage/web_socket_channel deps. Build `lib/core/network/` (client, interceptor, envelope, token store, config). Add the DI dual-source switch (default: all Firebase). Stand up the backend locally (docker-compose) and run `firebase-import --dry-run`. *Gate: app behaves exactly as today; new network core unit-tested in isolation.*

**Step 1 — Auth domain.**
Introduce `AppUser`/`AuthSession`, rewrite `IAuthRepository`, add `BackendAuthRepository`, fix the ~5 Firebase-type leak sites. Decide + implement the migrated-user password path. Flip auth to backend behind the switch. *Gate: login, logout, change-password, session restore, splash routing all work against the backend; FCM token now registered via `/devices/current`.*

**Step 2 — Read paths (app + mosque bootstrap, display).**
Rebuild `AppSettingsRemoteDataSource` and `MosqueRemoteDataSource` (read side) + backend models. Add the display `DisplayWebSocketDataSource`. Flip reads to backend. *Gate: display screen renders live from the WS; app settings/about/update load from `/app/bootstrap`; cache-first offline still works.*

**Step 3 — Platform announcements.**
Backend-shaped data source; flip. *Gate: announcements display correctly, active-window filtering preserved.*

**Step 4 — Write paths, feature by feature.**
General settings → prayer/iqama → religious content → announcements/ads → alerts → album/published-album → design settings → profile (phone/password). Each feature flips independently with a verify gate; `syncRevision` refresh wired per mutation. *Gate per feature: edit persists via REST, reflected on display via WS/snapshot.*

**Step 5 — Decommission Firebase.**
Once all domains are on the backend: remove the dual-source switch, delete Firebase data-access code and the 3 direct-access user files, remove `firebase_core`/`cloud_firestore`/`firebase_auth` (keep `firebase_messaging` only for FCM receive), delete `firestore.rules`/`firestore.indexes.json`/Firestore config. *Gate: full regression pass; no Firestore/Auth references remain (grep clean).*

---

## 7. Risks & important differences

| Risk / difference | Impact | Mitigation |
|---|---|---|
| **Firebase passwords don't export** | Migrated users can't log in with old password | Forced temp-password / reset flow before auth cutover (backend supports `password_change_required`) |
| **No authenticated live stream** | Settings screens aren't instantly live like Firestore | Accepted; `syncRevision` polling + refresh-after-mutation. Display uses WS |
| **Display WS is unauthenticated, slug-keyed** | Anyone with a slug can read display data; app must know the slug | Confirm import populates `public_slug`; treat display data as already-public (it is shown on screens) |
| **Mosque is relational, multi-endpoint** | One old write → several calls; partial-failure possible | Per-field-group data source methods; surface partial-write errors; rely on `syncRevision` to reconcile |
| **Envelope + error-code contract** | Different from Firestore exceptions | Central `ApiException` branching on `error.code` per handoff §Client Error Handling |
| **Offline behavior** | Firestore offline persistence is automatic; REST is not | Existing Hive cache-first layer covers reads; writes while offline either block with clear UX or (optional, later) a survey-app-style replay queue — out of scope unless required |
| **FCM token model change** | Array→per-device rows | Upsert via `/devices/current` on token + refresh; clear on logout only if user revokes device |
| **Field-parity gaps per domain** | A read/write field the app needs may be absent | Per-domain parity check at each gate before flipping; scoped backend addition only as last resort |
| **Backend availability/ops** | App now hard-depends on a server we run | docker-compose for dev; define prod hosting, health checks (`/system/health` exists), and base-URL env config before release |
| **Dual-source complexity during transition** | Temporary wiring, two code paths | Keep the switch domain-scoped and short-lived; delete in Step 5 |

---

## 8. Out of scope

- Building any new backend or redesigning existing backend domains (only scoped additions if a parity gap forces it).
- The admin **dashboard** client (separate `/dashboard/*` audience).
- The **AI recitation** flow (exists in backend, not currently in this Flutter app).
- An offline write-replay queue (only if a later requirement demands it).
- Copying survey-app code verbatim (reference only).

---

## 9. Definition of done

- App runs entirely against `mosques-backend`; no Firestore/Firebase-Auth code paths remain.
- `firebase_messaging` retained solely for receiving push; tokens registered via `/devices/current`.
- Existing Firebase data imported into Postgres; migrated users have a working password path.
- Display screen live via WebSocket; settings live via `syncRevision`.
- Full regression pass across every feature in §2.1's inventory.
