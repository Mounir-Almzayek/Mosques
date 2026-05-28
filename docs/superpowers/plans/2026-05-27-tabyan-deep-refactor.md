# Tebyan Deep Architecture Refactor Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform Tebyan from a working but tightly-coupled codebase into a professional, extensible Flutter architecture with proper separation of concerns, dependency injection, structured error handling, and testable repository interfaces.

**Architecture:** Replace static repository singletons with abstract interfaces registered via GetIt service locator. Consolidate 50+ boilerplate settings events into parameterized generic events. Optimize the per-second display tick to avoid full-widget rebuilds. Add auth-aware router guards, structured Firestore schema constants, and a Result<T> error pattern.

**Tech Stack:** Flutter 3.x, flutter_bloc, GetIt (new), GoRouter, Firebase (Firestore/Auth/Messaging), Hive, Equatable

---

## File Structure

### New files to create:
- `lib/core/constants/firestore_schema.dart` — All Firestore collection/field/key constants
- `lib/core/di/service_locator.dart` — GetIt setup and registration
- `lib/core/utils/result.dart` — Sealed Result<T> type for error handling
- `lib/data/repositories/interfaces/mosque_repository_interface.dart` — Abstract MosqueRepository
- `lib/data/repositories/interfaces/auth_repository_interface.dart` — Abstract AuthRepository
- `lib/data/repositories/interfaces/app_settings_repository_interface.dart` — Abstract AppSettingsRepository
- `lib/data/repositories/interfaces/platform_announcements_repository_interface.dart` — Abstract repo

### Files to modify heavily:
- `lib/data/repositories/mosque_repository.dart` — Implement interface, use DI, use constants
- `lib/features/auth/repository/auth_repository.dart` — Implement interface, use DI, use constants
- `lib/data/repositories/app_settings_repository.dart` — Implement interface
- `lib/data/repositories/platform_announcements_repository.dart` — Implement interface
- `lib/features/settings/bloc/settings/settings_event.dart` — Replace 50+ events with parameterized generics
- `lib/features/settings/bloc/settings/settings_bloc.dart` — Use DI-injected repos, simplified event registration
- `lib/features/settings/bloc/settings/handlers/*.dart` — All 5 handler files adapt to new events
- `lib/features/display/presentation/display_screen.dart` — Optimize tick rebuilds
- `lib/features/display/bloc/display_bloc.dart` — Use DI-injected repos
- `lib/core/services/firebase_service.dart` — Break circular dependency with AuthRepository
- `lib/core/routes/app_pages.dart` — Add auth guard redirect
- `lib/main.dart` — Initialize GetIt, inject BLoCs with repos
- `pubspec.yaml` — Add get_it dependency

### Files to delete:
- `lib/data/network/api_config.dart` — Dead REST API config (unused)
- `lib/data/network/dio_provider.dart` — Dead DIO provider (unused)

---

### Task 1: Add GetIt dependency and create Firestore schema constants

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/core/constants/firestore_schema.dart`

- [ ] **Step 1: Add get_it to pubspec.yaml**

In `pubspec.yaml`, under `dependencies:`, add after `equatable`:

```yaml
  get_it: ^8.0.3
```

- [ ] **Step 2: Run flutter pub get**

Run: `flutter pub get`
Expected: Dependencies resolve successfully

- [ ] **Step 3: Create Firestore schema constants**

Create `lib/core/constants/firestore_schema.dart`:

```dart
abstract final class FirestoreSchema {
  // Collections
  static const String mosques = 'mosques';
  static const String users = 'users';
  static const String appSettings = 'app_settings';
  static const String platformAnnouncements = 'platform_announcements';

  // Document IDs
  static const String globalDocId = 'global';

  // Mosque document fields
  static const String name = 'name';
  static const String city = 'city';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String calculationMethod = 'calculation_method';
  static const String prayerOffsets = 'prayer_offsets';
  static const String designSettings = 'design_settings';
  static const String iqamaOffsets = 'iqama_offsets';
  static const String hadiths = 'hadiths';
  static const String verses = 'verses';
  static const String duas = 'duas';
  static const String adhkar = 'adhkar';
  static const String mosqueAds = 'mosque_ads';
  static const String activeAlerts = 'active_alerts';
  static const String photoStudioUrls = 'photo_studio_urls';
  static const String languageCode = 'language_code';
  static const String appLanguageCode = 'app_language_code';
  static const String updatedAt = 'updated_at';
  static const String lastSeen = 'last_seen';
  static const String logoUrl = 'logo_url';
  static const String adminEmail = 'admin_email';
  static const String createdAt = 'created_at';

  // User document fields
  static const String email = 'email';
  static const String phone = 'phone';
  static const String activeMosqueId = 'active_mosque_id';
  static const String fcmToken = 'fcm_token';
  static const String fcmTokens = 'fcm_tokens';
  static const String fcmTokenUpdatedAt = 'fcm_token_updated_at';

  // Hive cache keys
  static const String mosqueCacheKey = 'active_mosque_cache_v1';
  static const String appSettingsCacheKey = 'app_settings_cache_v1';
  static const String platformAnnouncementsCacheKey = 'platform_announcements_cache_v1';

  // Platform announcement fields
  static const String isActive = 'is_active';
  static const String startDate = 'start_date';
  static const String endDate = 'end_date';
}
```

- [ ] **Step 4: Verify no analysis errors**

Run: `flutter analyze lib/core/constants/firestore_schema.dart`
Expected: No issues found

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/core/constants/firestore_schema.dart
git commit -m "refactor: add GetIt dependency and Firestore schema constants"
```

---

### Task 2: Create Result<T> sealed type for structured error handling

**Files:**
- Create: `lib/core/utils/result.dart`

- [ ] **Step 1: Create the Result sealed class**

Create `lib/core/utils/result.dart`:

```dart
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get valueOrNull => switch (this) {
    Success(:final value) => value,
    Failure() => null,
  };

  String? get errorOrNull => switch (this) {
    Success() => null,
    Failure(:final message) => message,
  };

  R when<R>({
    required R Function(T value) success,
    required R Function(String message, Object? error) failure,
  }) => switch (this) {
    Success(:final value) => success(value),
    Failure(:final message, :final error) => failure(message, error),
  };
}

final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

final class Failure<T> extends Result<T> {
  final String message;
  final Object? error;
  const Failure(this.message, [this.error]);
}
```

- [ ] **Step 2: Verify no analysis errors**

Run: `flutter analyze lib/core/utils/result.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/core/utils/result.dart
git commit -m "refactor: add sealed Result<T> type for structured error handling"
```

---

### Task 3: Create repository interfaces

**Files:**
- Create: `lib/data/repositories/interfaces/mosque_repository_interface.dart`
- Create: `lib/data/repositories/interfaces/auth_repository_interface.dart`
- Create: `lib/data/repositories/interfaces/app_settings_repository_interface.dart`
- Create: `lib/data/repositories/interfaces/platform_announcements_repository_interface.dart`

- [ ] **Step 1: Create MosqueRepository interface**

Create `lib/data/repositories/interfaces/mosque_repository_interface.dart`:

```dart
import '../../models/mosque/mosque_model.dart';
import '../../../core/enums/app_language.dart';
import '../../../core/enums/settings/mosque_text_list_kind.dart';

abstract class IMosqueRepository {
  Future<MosqueModel?> getActiveMosque();
  Future<MosqueModel?> fetchActiveMosqueFromServer();
  Future<void> updateMosque(MosqueModel mosque);
  Future<void> updateDesignSettings(MosqueModel mosque);
  Future<void> updateLanguageCode(AppLanguage language);
  Future<void> updateIqamaSettings(MosqueModel mosque);
  Future<void> updateMosqueTextList(MosqueModel mosque, MosqueTextListKind kind);
  Future<void> updateAnnouncements(MosqueModel mosque);
  Future<void> updateActiveAlerts(MosqueModel mosque);
  Future<void> updateLastSeen();
  Stream<MosqueModel?> get streamActiveMosque;
}
```

- [ ] **Step 2: Create AuthRepository interface**

Create `lib/data/repositories/interfaces/auth_repository_interface.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/enums/app_mode.dart';
import '../../../core/enums/registration_type.dart';

abstract class IAuthRepository {
  User? get currentUser;
  String? getActiveMosqueId();

  Future<void> register({
    required String email,
    required String password,
    required String phone,
    String? mosqueId,
    required RegistrationType type,
  });

  Future<bool> isMosqueIdAvailable(String mosqueId);
  Future<UserCredential> login(String email, String password);
  Future<void> saveFcmToken(String token);
  Future<void> logout();
  Future<void> updatePassword(String newPassword);
  Future<void> updatePhone(String newPhone);
  Future<String?> getPhone();
  AppMode? getAppModeOverride();
  Future<void> setAppModeOverride(AppMode mode);
}
```

- [ ] **Step 3: Create AppSettingsRepository interface**

Create `lib/data/repositories/interfaces/app_settings_repository_interface.dart`:

```dart
import '../../models/app/app_settings_model.dart';

abstract class IAppSettingsRepository {
  Future<AppSettingsModel?> getAppSettings();
  Stream<AppSettingsModel?> get streamAppSettings;
}
```

- [ ] **Step 4: Create PlatformAnnouncementsRepository interface**

Create `lib/data/repositories/interfaces/platform_announcements_repository_interface.dart`:

```dart
import '../../models/mosque/announcement_model.dart';

abstract class IPlatformAnnouncementsRepository {
  Stream<List<AnnouncementModel>> watchActiveForDisplay();
  Future<List<AnnouncementModel>> fetchActiveForDisplayFromServer();
}
```

- [ ] **Step 5: Verify no analysis errors**

Run: `flutter analyze lib/data/repositories/interfaces/`
Expected: No issues found

- [ ] **Step 6: Commit**

```bash
git add lib/data/repositories/interfaces/
git commit -m "refactor: add abstract repository interfaces for DI"
```

---

### Task 4: Implement repository interfaces on existing repos and replace hardcoded Firestore strings

This is the core refactor task. Every repository switches from static methods to instance methods implementing the interface, and all hardcoded Firestore strings are replaced with `FirestoreSchema` constants.

**Files:**
- Modify: `lib/data/repositories/mosque_repository.dart`
- Modify: `lib/features/auth/repository/auth_repository.dart`
- Modify: `lib/data/repositories/app_settings_repository.dart`
- Modify: `lib/data/repositories/platform_announcements_repository.dart`
- Modify: `lib/data/repositories/mosque_local_repository.dart`
- Modify: `lib/data/repositories/app_settings_local_repository.dart`
- Modify: `lib/features/auth/repository/user_active_mosque_repository.dart`

- [ ] **Step 1: Rewrite MosqueRepository as instance class implementing IMosqueRepository**

Replace the entire content of `lib/data/repositories/mosque_repository.dart` with:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../../core/constants/firestore_schema.dart';
import '../../core/enums/app_language.dart';
import '../../core/enums/settings/mosque_text_list_kind.dart';
import '../models/mosque/mosque_model.dart';
import 'interfaces/mosque_repository_interface.dart';
import 'mosque_local_repository.dart';

class MosqueRepository implements IMosqueRepository {
  final FirebaseFirestore _firestore;
  final String? Function() _getActiveMosqueId;
  final Future<void> Function(String uid) _syncActiveMosque;

  MosqueRepository({
    required FirebaseFirestore firestore,
    required String? Function() getActiveMosqueId,
    required Future<void> Function(String uid) syncActiveMosque,
  })  : _firestore = firestore,
        _getActiveMosqueId = getActiveMosqueId,
        _syncActiveMosque = syncActiveMosque;

  DocumentReference? get _mosqueRef {
    final id = _getActiveMosqueId();
    if (id == null || id.isEmpty) return null;
    return _firestore.collection(FirestoreSchema.mosques).doc(id);
  }

  @override
  Future<MosqueModel?> getActiveMosque() async {
    final ref = _mosqueRef;
    if (ref == null) return null;

    try {
      final doc = await ref.get();
      if (!doc.exists || doc.data() == null) {
        return MosqueLocalRepository.getCachedForActiveMosque();
      }
      final mosque = MosqueModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      await MosqueLocalRepository.saveMosque(mosque);
      return mosque;
    } catch (_) {
      return MosqueLocalRepository.getCachedForActiveMosque();
    }
  }

  @override
  Future<MosqueModel?> fetchActiveMosqueFromServer() async {
    final ref = _mosqueRef;
    if (ref == null) return null;

    try {
      final doc = await ref.get(const GetOptions(source: Source.server));
      if (!doc.exists || doc.data() == null) return null;
      final mosque = MosqueModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
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
          final mosque = MosqueModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
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
```

- [ ] **Step 2: Rewrite AuthRepository as instance class implementing IAuthRepository**

Replace the entire content of `lib/features/auth/repository/auth_repository.dart` with:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/firestore_schema.dart';
import '../../../core/enums/app_mode.dart';
import '../../../core/enums/registration_type.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/design/design_settings_model.dart';
import '../../../data/models/mosque/mosque_model.dart';
import '../../../data/repositories/interfaces/auth_repository_interface.dart';
import '../../../data/repositories/mosque_local_repository.dart';
import 'user_active_mosque_repository.dart';

class AuthRepository implements IAuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const String _appModeKey = 'app_mode_override';

  AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<void> register({
    required String email,
    required String password,
    required String phone,
    String? mosqueId,
    required RegistrationType type,
  }) async {
    UserCredential? credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      final userMap = {
        FirestoreSchema.email: email,
        FirestoreSchema.phone: phone,
        FirestoreSchema.createdAt: FieldValue.serverTimestamp(),
        FirestoreSchema.activeMosqueId: type.isNew ? mosqueId : null,
      };
      await _firestore.collection(FirestoreSchema.users).doc(uid).set(userMap);

      if (type.isNew && mosqueId != null) {
        await _createMosque(mosqueId, email);
        await UserActiveMosqueRepository.syncBestEffort(uid);
      }
    } catch (e) {
      final uid = credential?.user?.uid;
      if (uid != null) {
        await _firestore.collection(FirestoreSchema.users).doc(uid).delete().catchError((_) {});
      }
      await credential?.user?.delete().catchError((_) {});
      rethrow;
    }
  }

  @override
  Future<bool> isMosqueIdAvailable(String mosqueId) async {
    try {
      final doc = await _firestore.collection(FirestoreSchema.mosques).doc(mosqueId).get();
      return !doc.exists;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') return true;
      rethrow;
    }
  }

  Future<void> _createMosque(String mosqueId, String adminEmail) async {
    final defaultMosque = MosqueModel(
      id: mosqueId,
      name: mosqueId.replaceAll('_', ' ').toUpperCase(),
      city: '',
      latitude: 0,
      longitude: 0,
      prayerCalculationMethod: 'MuslimWorldLeague',
      appLanguageCode: 'ar',
      designSettings: const DesignSettingsModel(),
      iqamaSettings: IqamaSettingsModel.defaultSettings(),
      prayerOffsets: const PrayerOffsetsModel(),
    );
    final ref = _firestore.collection(FirestoreSchema.mosques).doc(mosqueId);
    await _firestore.runTransaction((tx) async {
      final existing = await tx.get(ref);
      if (existing.exists) {
        throw Exception('mosque_id_taken');
      }
      tx.set(ref, {
        ...defaultMosque.toMap(),
        FirestoreSchema.adminEmail: adminEmail,
        FirestoreSchema.createdAt: FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<UserCredential> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await UserActiveMosqueRepository.syncBestEffort(credential.user?.uid);
    return credential;
  }

  @override
  Future<void> saveFcmToken(String token) async {
    final user = _auth.currentUser;
    if (user == null || token.trim().isEmpty) return;

    await _firestore.collection(FirestoreSchema.users).doc(user.uid).set({
      FirestoreSchema.fcmToken: token,
      FirestoreSchema.fcmTokens: FieldValue.arrayUnion([token]),
      FirestoreSchema.fcmTokenUpdatedAt: FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    await UserActiveMosqueRepository.clearLocalCache();
    await MosqueLocalRepository.clearCache();
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }

  @override
  Future<void> updatePhone(String newPhone) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection(FirestoreSchema.users).doc(user.uid).set(
        {FirestoreSchema.phone: newPhone},
        SetOptions(merge: true),
      );
    }
  }

  @override
  Future<String?> getPhone() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection(FirestoreSchema.users).doc(user.uid).get();
      return doc.data()?[FirestoreSchema.phone] as String?;
    }
    return null;
  }

  @override
  String? getActiveMosqueId() {
    return UserActiveMosqueRepository.getCachedActiveMosqueId();
  }

  @override
  AppMode? getAppModeOverride() {
    final value = StorageService.getString(_appModeKey);
    if (value == null || value.isEmpty) return null;
    return AppMode.fromString(value);
  }

  @override
  Future<void> setAppModeOverride(AppMode mode) async {
    await StorageService.setString(_appModeKey, mode.name);
  }
}
```

- [ ] **Step 3: Rewrite AppSettingsRepository**

Read the current file first, then replace `lib/data/repositories/app_settings_repository.dart` so it implements the interface, uses instance methods, and uses `FirestoreSchema` constants. Keep the same Firestore query logic but replace `'app_settings'` with `FirestoreSchema.appSettings` and `'global'` with `FirestoreSchema.globalDocId`. Add constructor taking `FirebaseFirestore firestore`.

- [ ] **Step 4: Rewrite PlatformAnnouncementsRepository**

Same pattern: implement the interface, constructor injection of Firestore, replace hardcoded strings with `FirestoreSchema` constants.

- [ ] **Step 5: Update MosqueLocalRepository to use FirestoreSchema cache key**

In `lib/data/repositories/mosque_local_repository.dart`, replace the hardcoded `'active_mosque_cache_v1'` string with `FirestoreSchema.mosqueCacheKey`. Import the schema constants.

- [ ] **Step 6: Update AppSettingsLocalRepository to use FirestoreSchema cache key**

In `lib/data/repositories/app_settings_local_repository.dart`, replace `'app_settings_cache_v1'` with `FirestoreSchema.appSettingsCacheKey`.

- [ ] **Step 7: Update PlatformAnnouncementsLocalRepository**

Replace `'platform_announcements_cache_v1'` with `FirestoreSchema.platformAnnouncementsCacheKey`.

- [ ] **Step 8: Verify analysis**

Run: `flutter analyze`
Expected: No new errors (some existing info-level warnings are OK)

- [ ] **Step 9: Commit**

```bash
git add lib/data/repositories/ lib/features/auth/repository/auth_repository.dart
git commit -m "refactor: implement repository interfaces, replace hardcoded Firestore strings with schema constants"
```

---

### Task 5: Create service locator and wire up DI

**Files:**
- Create: `lib/core/di/service_locator.dart`
- Modify: `lib/main.dart`
- Modify: `lib/core/services/firebase_service.dart`

- [ ] **Step 1: Create service locator**

Create `lib/core/di/service_locator.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../data/repositories/app_settings_repository.dart';
import '../../data/repositories/interfaces/app_settings_repository_interface.dart';
import '../../data/repositories/interfaces/auth_repository_interface.dart';
import '../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../../data/repositories/interfaces/platform_announcements_repository_interface.dart';
import '../../data/repositories/mosque_repository.dart';
import '../../data/repositories/platform_announcements_repository.dart';
import '../../features/auth/repository/auth_repository.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  // External
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Repositories — register interface, provide implementation
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepository(
      auth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  sl.registerLazySingleton<IMosqueRepository>(
    () => MosqueRepository(
      firestore: sl<FirebaseFirestore>(),
      getActiveMosqueId: () => sl<IAuthRepository>().getActiveMosqueId(),
      syncActiveMosque: (uid) async {
        // UserActiveMosqueRepository is still static — thin bridge
        await UserActiveMosqueRepository.syncBestEffort(uid);
      },
    ),
  );

  sl.registerLazySingleton<IAppSettingsRepository>(
    () => AppSettingsRepository(firestore: sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<IPlatformAnnouncementsRepository>(
    () => PlatformAnnouncementsRepository(firestore: sl<FirebaseFirestore>()),
  );
}
```

- [ ] **Step 2: Break circular dependency in FirebaseService**

In `lib/core/services/firebase_service.dart`, the `_syncTokenToCurrentUser()` method calls `AuthRepository.saveFcmToken()` directly (static call). Replace it with a callback pattern:

Replace the static `_syncTokenToCurrentUser` call site with a late-bound callback. After `setupServiceLocator()` runs in main, the callback uses `sl<IAuthRepository>().saveFcmToken(token)`.

Modify `FirebaseService.init()` to accept an optional `Future<void> Function(String token)? onTokenRefresh` callback. Inside `_setupNotificationHandlers`, use this callback instead of calling `AuthRepository.saveFcmToken` directly.

- [ ] **Step 3: Update main.dart to initialize DI**

In `lib/main.dart`, add import for `core/di/service_locator.dart`. In `main()`, call `setupServiceLocator()` after `FirebaseService.init()` (since Firebase must be initialized first). Pass the token callback:

```dart
await FirebaseService.init(
  onTokenRefresh: (token) => sl<IAuthRepository>().saveFcmToken(token),
);
setupServiceLocator();
```

- [ ] **Step 4: Verify analysis**

Run: `flutter analyze`
Expected: No new errors

- [ ] **Step 5: Commit**

```bash
git add lib/core/di/ lib/core/services/firebase_service.dart lib/main.dart
git commit -m "refactor: create GetIt service locator and break FirebaseService circular dependency"
```

---

### Task 6: Migrate BLoCs to use DI-injected repositories

**Files:**
- Modify: `lib/features/display/bloc/display_bloc.dart`
- Modify: `lib/features/settings/bloc/settings/settings_bloc.dart`
- Modify: `lib/features/auth/bloc/login_bloc.dart`
- Modify: `lib/features/auth/bloc/registration_bloc.dart`
- Modify: `lib/features/display/presentation/display_screen.dart`
- Modify: `lib/features/settings/presentation/settings_page.dart`
- Modify: `lib/main.dart` (BlocProvider creation)

- [ ] **Step 1: Update DisplayBloc to accept repos via constructor**

In `lib/features/display/bloc/display_bloc.dart`:

```dart
class DisplayBloc extends Bloc<DisplayEvent, DisplayState> {
  final IMosqueRepository _mosqueRepo;
  final IPlatformAnnouncementsRepository _platformRepo;
  final IAppSettingsRepository _appSettingsRepo;

  DisplayBloc({
    required IMosqueRepository mosqueRepository,
    required IPlatformAnnouncementsRepository platformAnnouncementsRepository,
    required IAppSettingsRepository appSettingsRepository,
  })  : _mosqueRepo = mosqueRepository,
        _platformRepo = platformAnnouncementsRepository,
        _appSettingsRepo = appSettingsRepository,
        super(DisplayInitial()) {
    // ... same event registrations
  }
```

Replace all `MosqueRepository.staticMethod()` calls with `_mosqueRepo.method()` calls. Replace `PlatformAnnouncementsRepository.staticMethod()` with `_platformRepo.method()`. Replace `AppSettingsRepository.staticMethod()` with `_appSettingsRepo.method()`. Replace `MosqueLocalRepository.getCachedForActiveMosque()` call in `_onStartSubscription` with `_mosqueRepo.getActiveMosque()` (which already falls back to cache).

- [ ] **Step 2: Update SettingsBloc to accept IMosqueRepository**

In `lib/features/settings/bloc/settings/settings_bloc.dart`:

```dart
class SettingsBloc extends Bloc<SettingsEvent, SettingsState>
    with GeneralSettingsHandler, DesignSettingsHandler, IqamaSettingsHandler, MosqueTextHandler, AnnouncementHandler {

  final IMosqueRepository _mosqueRepo;

  SettingsBloc({required IMosqueRepository mosqueRepository})
      : _mosqueRepo = mosqueRepository,
        super(const SettingsState()) {
    // ... same event registrations
  }
```

Replace all `MosqueRepository.staticMethod(m)` calls in `_onSave*` methods with `_mosqueRepo.method(m)`. In `_onLoad`, replace `MosqueRepository.streamActiveMosque` with `_mosqueRepo.streamActiveMosque`.

Update the handler mixin contract to expose the repo:
```dart
@override
IMosqueRepository get mosqueRepo => _mosqueRepo;
```

- [ ] **Step 3: Update LoginBloc and RegistrationBloc**

Read `lib/features/auth/bloc/login_bloc.dart` and `lib/features/auth/bloc/registration_bloc.dart`. Add `IAuthRepository` constructor parameter. Replace static `AuthRepository.login(...)` calls with `_authRepo.login(...)`, and similarly for other auth calls.

- [ ] **Step 4: Update BlocProvider creation sites**

In pages/screens that create BLoCs (check `display_page.dart`, `settings_page.dart`, `login_screen.dart`/`login_page.dart`, `registration_page.dart`), update `BlocProvider` creation to inject repos from `sl`:

```dart
BlocProvider(
  create: (_) => DisplayBloc(
    mosqueRepository: sl<IMosqueRepository>(),
    platformAnnouncementsRepository: sl<IPlatformAnnouncementsRepository>(),
    appSettingsRepository: sl<IAppSettingsRepository>(),
  )..add(const StartDisplaySubscription()),
),
```

- [ ] **Step 5: Update DisplayScreen direct AuthRepository usage**

In `lib/features/display/presentation/display_screen.dart`, the `_backToSettings` method calls `AuthRepository.setAppModeOverride(AppMode.mobileSettings)` directly. Replace with `sl<IAuthRepository>().setAppModeOverride(...)`.

- [ ] **Step 6: Verify analysis**

Run: `flutter analyze`
Expected: No new errors

- [ ] **Step 7: Commit**

```bash
git add lib/features/ lib/main.dart
git commit -m "refactor: migrate all BLoCs to use DI-injected repository interfaces"
```

---

### Task 7: Consolidate settings events into parameterized generic events

The current `settings_event.dart` has 469 lines with 50+ nearly-identical event classes. Most follow the pattern "one field changed" with a single value. Replace these with parameterized generic events.

**Files:**
- Rewrite: `lib/features/settings/bloc/settings/settings_event.dart`
- Modify: `lib/features/settings/bloc/settings/settings_bloc.dart`
- Modify: `lib/features/settings/bloc/settings/handlers/general_settings_handler.dart`
- Modify: `lib/features/settings/bloc/settings/handlers/design_settings_handler.dart`
- Modify: `lib/features/settings/bloc/settings/handlers/iqama_settings_handler.dart`
- Modify: All settings section UI files that dispatch events

- [ ] **Step 1: Rewrite settings_event.dart with consolidated events**

Replace the entire content of `lib/features/settings/bloc/settings/settings_event.dart`:

```dart
import 'package:equatable/equatable.dart';

import '../../../../data/models/mosque/mosque_model.dart';
import '../../../../core/enums/app_language.dart';
import '../../../../core/enums/app_numeral_format.dart';
import '../../../../core/enums/display_background_type.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

// ——— Loading ———

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

// ——— General ———

enum GeneralField { name, city, calculationMethod, latitude, longitude }

class GeneralSettingChanged extends SettingsEvent {
  final GeneralField field;
  final Object value;

  const GeneralSettingChanged(this.field, this.value);

  @override
  List<Object?> get props => [field, value];
}

class LanguageChanged extends SettingsEvent {
  final AppLanguage language;
  const LanguageChanged(this.language);

  @override
  List<Object?> get props => [language];
}

class CoordinatesChanged extends SettingsEvent {
  final double latitude;
  final double longitude;

  const CoordinatesChanged({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

// ——— Prayer Offsets (single parameterized event) ———

enum PrayerOffsetField { fajr, sunrise, dhuhr, asr, maghrib, isha }

class PrayerOffsetChanged extends SettingsEvent {
  final PrayerOffsetField prayer;
  final int offset;

  const PrayerOffsetChanged(this.prayer, this.offset);

  @override
  List<Object?> get props => [prayer, offset];
}

class SaveGeneralSettingsRequested extends SettingsEvent {
  const SaveGeneralSettingsRequested();
}

// ——— Design: Colors ———

enum DesignColorField {
  primary,
  secondary,
  prayerOverlay,
  activeCard,
  activeCardText,
  inactiveCardText,
}

class DesignColorChanged extends SettingsEvent {
  final DesignColorField field;
  final String color;

  const DesignColorChanged(this.field, this.color);

  @override
  List<Object?> get props => [field, color];
}

// ——— Design: Font Sizes ———

enum DesignFontSizeField { clock, mosqueInfo, prayers, announcements, content }

class DesignFontSizeChanged extends SettingsEvent {
  final DesignFontSizeField field;
  final double fontSize;

  const DesignFontSizeChanged(this.field, this.fontSize);

  @override
  List<Object?> get props => [field, fontSize];
}

// ——— Design: Background ———

class DesignBackgroundValueChanged extends SettingsEvent {
  final String backgroundValue;
  const DesignBackgroundValueChanged(this.backgroundValue);

  @override
  List<Object?> get props => [backgroundValue];
}

class DesignBackgroundTypeChanged extends SettingsEvent {
  final DisplayBackgroundType type;
  const DesignBackgroundTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}

class DesignBackgroundCustomUrlChanged extends SettingsEvent {
  final String url;
  const DesignBackgroundCustomUrlChanged(this.url);

  @override
  List<Object?> get props => [url];
}

// ——— Design: Misc ———

class DesignTickerSpeedChanged extends SettingsEvent {
  final double speed;
  const DesignTickerSpeedChanged(this.speed);

  @override
  List<Object?> get props => [speed];
}

class DesignStripSpeedChanged extends SettingsEvent {
  final double speed;
  const DesignStripSpeedChanged(this.speed);

  @override
  List<Object?> get props => [speed];
}

class DesignNumeralFormatChanged extends SettingsEvent {
  final AppNumeralFormat format;
  const DesignNumeralFormatChanged(this.format);

  @override
  List<Object?> get props => [format];
}

class DesignFontFamilyChanged extends SettingsEvent {
  final String fontFamily;
  const DesignFontFamilyChanged(this.fontFamily);

  @override
  List<Object?> get props => [fontFamily];
}

class SaveDesignSettingsRequested extends SettingsEvent {
  const SaveDesignSettingsRequested();
}

// ——— Display Timing ———

enum DisplayTimingField {
  preAdhanMinutes,
  adhanMomentDuration,
  religiousContentWait,
  religiousContentDisplay,
}

class DisplayTimingChanged extends SettingsEvent {
  final DisplayTimingField field;
  final int value;

  const DisplayTimingChanged(this.field, this.value);

  @override
  List<Object?> get props => [field, value];
}

// ——— Photo Studio ———

class PhotoStudioUrlAdded extends SettingsEvent {
  final String url;
  const PhotoStudioUrlAdded(this.url);

  @override
  List<Object?> get props => [url];
}

class PhotoStudioUrlRemoved extends SettingsEvent {
  final String url;
  const PhotoStudioUrlRemoved(this.url);

  @override
  List<Object?> get props => [url];
}

class SavePhotoStudioRequested extends SettingsEvent {
  const SavePhotoStudioRequested();
}

// ——— Iqama ———

enum IqamaField { fajr, dhuhr, asr, maghrib, isha, jummah }

class IqamaOffsetChanged extends SettingsEvent {
  final IqamaField prayer;
  final int offset;

  const IqamaOffsetChanged(this.prayer, this.offset);

  @override
  List<Object?> get props => [prayer, offset];
}

class SaveIqamaSettingsRequested extends SettingsEvent {
  const SaveIqamaSettingsRequested();
}

// ——— Mosque Text Lists ———

class MosqueTextAdded extends SettingsEvent {
  final MosqueTextListKind kind;
  final MosqueTextEntryModel item;

  const MosqueTextAdded(this.kind, this.item);

  @override
  List<Object?> get props => [kind, item];
}

class MosqueTextUpdated extends SettingsEvent {
  final MosqueTextListKind kind;
  final MosqueTextEntryModel item;

  const MosqueTextUpdated(this.kind, this.item);

  @override
  List<Object?> get props => [kind, item];
}

class MosqueTextRemoved extends SettingsEvent {
  final MosqueTextListKind kind;
  final String itemId;

  const MosqueTextRemoved(this.kind, this.itemId);

  @override
  List<Object?> get props => [kind, itemId];
}

class SaveMosqueTextListRequested extends SettingsEvent {
  final MosqueTextListKind kind;
  const SaveMosqueTextListRequested(this.kind);
}

// ——— Announcements ———

class AnnouncementAdded extends SettingsEvent {
  final AnnouncementModel announcement;
  const AnnouncementAdded(this.announcement);

  @override
  List<Object?> get props => [announcement];
}

class AnnouncementUpdated extends SettingsEvent {
  final AnnouncementModel announcement;
  const AnnouncementUpdated(this.announcement);

  @override
  List<Object?> get props => [announcement];
}

class AnnouncementRemoved extends SettingsEvent {
  final String announcementId;
  const AnnouncementRemoved(this.announcementId);

  @override
  List<Object?> get props => [announcementId];
}

class SaveAnnouncementsRequested extends SettingsEvent {
  const SaveAnnouncementsRequested();
}

// ——— Alerts ———

class AlertAdded extends SettingsEvent {
  final AnnouncementModel alert;
  const AlertAdded(this.alert);

  @override
  List<Object?> get props => [alert];
}

class AlertRemoved extends SettingsEvent {
  final String alertId;
  const AlertRemoved(this.alertId);

  @override
  List<Object?> get props => [alertId];
}

class AlertsCleared extends SettingsEvent {
  const AlertsCleared();
}

class SaveAlertsRequested extends SettingsEvent {
  const SaveAlertsRequested();
}
```

This reduces 469 lines (50+ classes) to ~250 lines (30 classes) by parameterizing repetitive per-field events with enums.

- [ ] **Step 2: Rewrite GeneralSettingsHandler for new events**

Replace `lib/features/settings/bloc/settings/handlers/general_settings_handler.dart` to handle `GeneralSettingChanged`, `LanguageChanged`, `CoordinatesChanged`, and `PrayerOffsetChanged` instead of the 12 separate events:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/models/mosque/mosque_model.dart';
import '../../../models/settings_edit_request.dart';
import '../settings_event.dart';
import '../settings_state.dart';

mixin GeneralSettingsHandler on Bloc<SettingsEvent, SettingsState> {
  void Function(Emitter<SettingsState> emit, SettingsEditRequest next) get emitDraftUpdated;
  MosqueModel? get currentMosque;

  void onGeneralSettingChanged(GeneralSettingChanged event, Emitter<SettingsState> emit) {
    final m = currentMosque;
    if (m == null) return;
    final updated = switch (event.field) {
      GeneralField.name => m.copyWith(name: event.value as String),
      GeneralField.city => m.copyWith(city: event.value as String),
      GeneralField.calculationMethod => m.copyWith(prayerCalculationMethod: event.value as String),
      GeneralField.latitude => m.copyWith(latitude: event.value as double),
      GeneralField.longitude => m.copyWith(longitude: event.value as double),
    };
    emitDraftUpdated(emit, state.request.copyWith(mosque: updated));
  }

  void onLanguageChanged(LanguageChanged event, Emitter<SettingsState> emit) {
    final m = currentMosque;
    if (m == null) return;
    emitDraftUpdated(emit, state.request.copyWith(
      mosque: m.copyWith(appLanguageCode: event.language.code),
    ));
  }

  void onCoordinatesChanged(CoordinatesChanged event, Emitter<SettingsState> emit) {
    final m = currentMosque;
    if (m == null) return;
    emitDraftUpdated(emit, state.request.copyWith(
      mosque: m.copyWith(latitude: event.latitude, longitude: event.longitude),
    ));
  }

  void onPrayerOffsetChanged(PrayerOffsetChanged event, Emitter<SettingsState> emit) {
    final m = currentMosque;
    if (m == null) return;
    final o = switch (event.prayer) {
      PrayerOffsetField.fajr => m.prayerOffsets.copyWith(fajr: event.offset),
      PrayerOffsetField.sunrise => m.prayerOffsets.copyWith(sunrise: event.offset),
      PrayerOffsetField.dhuhr => m.prayerOffsets.copyWith(dhuhr: event.offset),
      PrayerOffsetField.asr => m.prayerOffsets.copyWith(asr: event.offset),
      PrayerOffsetField.maghrib => m.prayerOffsets.copyWith(maghrib: event.offset),
      PrayerOffsetField.isha => m.prayerOffsets.copyWith(isha: event.offset),
    };
    emitDraftUpdated(emit, state.request.copyWith(mosque: m.copyWith(prayerOffsets: o)));
  }
}
```

- [ ] **Step 3: Rewrite DesignSettingsHandler for consolidated events**

Replace `lib/features/settings/bloc/settings/handlers/design_settings_handler.dart` with handlers for `DesignColorChanged`, `DesignFontSizeChanged`, `DisplayTimingChanged`, and the remaining individual design events. Each uses a switch on the enum field:

```dart
void onDesignColorChanged(DesignColorChanged event, Emitter<SettingsState> emit) {
  final m = currentMosque;
  if (m == null) return;
  final c = switch (event.field) {
    DesignColorField.primary => m.designSettings.colors.copyWith(primary: event.color),
    DesignColorField.secondary => m.designSettings.colors.copyWith(secondary: event.color),
    DesignColorField.prayerOverlay => m.designSettings.colors.copyWith(prayerOverlay: event.color),
    DesignColorField.activeCard => m.designSettings.colors.copyWith(activeCard: event.color),
    DesignColorField.activeCardText => m.designSettings.colors.copyWith(activeCardText: event.color),
    DesignColorField.inactiveCardText => m.designSettings.colors.copyWith(inactiveCardText: event.color),
  };
  final d = m.designSettings.copyWith(colors: c);
  emitDraftUpdated(emit, state.request.copyWith(mosque: m.copyWith(designSettings: d)));
}
```

Similar switch-based handlers for `DesignFontSizeChanged` and `DisplayTimingChanged`.

- [ ] **Step 4: Rewrite IqamaSettingsHandler**

Replace with a single `onIqamaOffsetChanged` handler using `IqamaField` enum.

- [ ] **Step 5: Update SettingsBloc event registration**

Replace the 50+ `on<SpecificEvent>` registrations with the consolidated ones:

```dart
// General
on<GeneralSettingChanged>(onGeneralSettingChanged);
on<LanguageChanged>(onLanguageChanged);
on<CoordinatesChanged>(onCoordinatesChanged);
on<PrayerOffsetChanged>(onPrayerOffsetChanged);
on<SaveGeneralSettingsRequested>(_onSaveGeneral);

// Design
on<DesignColorChanged>(onDesignColorChanged);
on<DesignFontSizeChanged>(onDesignFontSizeChanged);
on<DesignBackgroundValueChanged>(onDesignBackgroundValueChanged);
on<DesignBackgroundTypeChanged>(onDesignBackgroundTypeChanged);
on<DesignBackgroundCustomUrlChanged>(onDesignBackgroundCustomUrlChanged);
on<DesignTickerSpeedChanged>(onDesignTickerSpeedChanged);
on<DesignStripSpeedChanged>(onDesignStripSpeedChanged);
on<DesignNumeralFormatChanged>(onDesignNumeralFormatChanged);
on<DesignFontFamilyChanged>(onDesignFontFamilyChanged);
on<DisplayTimingChanged>(onDisplayTimingChanged);
on<PhotoStudioUrlAdded>(onPhotoStudioUrlAdded);
on<PhotoStudioUrlRemoved>(onPhotoStudioUrlRemoved);
on<SaveDesignSettingsRequested>(_onSaveDesign);
on<SavePhotoStudioRequested>(_onSavePhotoStudio);

// Iqama
on<IqamaOffsetChanged>(onIqamaOffsetChanged);
on<SaveIqamaSettingsRequested>(_onSaveIqama);

// Text, Announcements, Alerts (keep as-is, already clean)
on<MosqueTextAdded>(onMosqueTextAdded);
on<MosqueTextUpdated>(onMosqueTextUpdated);
on<MosqueTextRemoved>(onMosqueTextRemoved);
on<SaveMosqueTextListRequested>(_onSaveTextList);
on<AnnouncementAdded>(onAnnouncementAdded);
on<AnnouncementUpdated>(onAnnouncementUpdated);
on<AnnouncementRemoved>(onAnnouncementRemoved);
on<SaveAnnouncementsRequested>(_onSaveAnnouncements);
on<AlertAdded>(onAlertAdded);
on<AlertRemoved>(onAlertRemoved);
on<AlertsCleared>(onAlertsCleared);
on<SaveAlertsRequested>(_onSaveAlerts);
```

- [ ] **Step 6: Update all settings UI sections that dispatch events**

Search all settings presentation files (sections/ and widgets/) for old event names like `SettingsMosqueNameChanged`, `SettingsDesignPrimaryColorChanged`, `SettingsPrayerOffsetFajrChanged`, etc. Replace with the new consolidated versions:

- `SettingsMosqueNameChanged('foo')` → `GeneralSettingChanged(GeneralField.name, 'foo')`
- `SettingsDesignPrimaryColorChanged('#fff')` → `DesignColorChanged(DesignColorField.primary, '#fff')`
- `SettingsPrayerOffsetFajrChanged(5)` → `PrayerOffsetChanged(PrayerOffsetField.fajr, 5)`
- `SettingsIqamaFajrOffsetChanged(15)` → `IqamaOffsetChanged(IqamaField.fajr, 15)`
- `SettingsPreAdhanMinutesChanged(5)` → `DisplayTimingChanged(DisplayTimingField.preAdhanMinutes, 5)`
- And so on for all event dispatches.

Drop the `Settings` prefix from announcement/alert/text events: `SettingsAnnouncementAdded` → `AnnouncementAdded`, etc.

- [ ] **Step 7: Verify analysis and test**

Run: `flutter analyze`
Run: `flutter test`
Expected: No errors, test passes

- [ ] **Step 8: Commit**

```bash
git add lib/features/settings/
git commit -m "refactor: consolidate 50+ settings events into parameterized generic events"
```

---

### Task 8: Optimize DisplayScreen per-tick performance

The current DisplayScreen calls `setState(() {})` every second via a Timer, which rebuilds the entire widget tree. Replace with selective rebuilds.

**Files:**
- Modify: `lib/features/display/presentation/display_screen.dart`
- Modify: `lib/features/display/controller/display_layer_controller.dart`

- [ ] **Step 1: Add ValueNotifier for current time in DisplayScreen**

Replace the `_now` field and the `setState(() {})` in the tick timer with a `ValueNotifier<DateTime>`:

```dart
class _DisplayScreenState extends State<DisplayScreen> {
  Timer? _tickTimer;
  final DisplayLayerController _layerController = DisplayLayerController();
  late PrayerTimesHelper _helper;
  final ValueNotifier<DateTime> _now = ValueNotifier(DateTime.now());

  @override
  void initState() {
    super.initState();
    _layerController.addListener(_onLayerChange);
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _now.value = DateTime.now();
      _updateLayerInputs();
    });
  }
```

Remove the `_onLayerChange` method's `setState` call — instead use `ListenableBuilder` in the build method for the parts that depend on `_layerController` or `_now`.

- [ ] **Step 2: Use ListenableBuilder for time-dependent widgets**

Wrap only the overlay layer section and the clock/prayer areas with `ListenableBuilder` widgets that listen to `_now` or `_layerController`, so the background, header layout, and ticker don't rebuild every second:

```dart
// In build(), replace the monolithic Stack with selective builders:
ListenableBuilder(
  listenable: Listenable.merge([_layerController, _now]),
  builder: (context, _) {
    final activeLayer = _layerController.state.activeLayer;
    if (activeLayer == DisplayLayerKind.prayerTimes) {
      return const SizedBox.shrink();
    }
    return LayerTransitionWrapper(
      activeLayer: activeLayer,
      child: _buildOverlayLayer(activeLayer, mosque, design, colors),
    );
  },
),
```

- [ ] **Step 3: Remove setState from _onLayerChange**

```dart
void _onLayerChange() {
  // ListenableBuilder handles rebuilds now — no setState needed
}
```

Actually, `_onLayerChange` can be removed entirely since `ListenableBuilder` already listens to `_layerController`.

- [ ] **Step 4: Verify analysis**

Run: `flutter analyze`
Expected: No new errors

- [ ] **Step 5: Commit**

```bash
git add lib/features/display/
git commit -m "perf: optimize DisplayScreen to use ValueNotifier/ListenableBuilder instead of per-tick setState"
```

---

### Task 9: Add auth-aware router guard

The current GoRouter has no redirect logic — unauthenticated users can navigate to any route. Add a proper auth guard.

**Files:**
- Modify: `lib/core/routes/app_pages.dart`

- [ ] **Step 1: Add redirect logic to GoRouter**

Replace `lib/core/routes/app_pages.dart`:

```dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/registration_page.dart';
import '../../features/display/presentation/display_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/splash/presentation/splash_page.dart';
import '../di/service_locator.dart';
import '../../data/repositories/interfaces/auth_repository_interface.dart';
import 'app_routes.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

final appPages = GoRouter(
  navigatorKey: _navigatorKey,
  initialLocation: Routes.splashPath,
  redirect: _authGuard,
  routes: [
    GoRoute(path: Routes.splashPath, builder: (context, state) => const SplashPage()),
    GoRoute(path: Routes.loginPath, builder: (context, state) => const LoginPage()),
    GoRoute(path: Routes.registrationPath, builder: (context, state) => const RegistrationPage()),
    GoRoute(path: Routes.settingsPath, builder: (context, state) => const SettingsPage()),
    GoRoute(path: Routes.displayPath, builder: (context, state) => const DisplayPage()),
  ],
);

String? _authGuard(BuildContext context, GoRouterState state) {
  final authRepo = sl<IAuthRepository>();
  final loggedIn = authRepo.currentUser != null;
  final isAuthRoute = state.matchedLocation == Routes.loginPath ||
      state.matchedLocation == Routes.registrationPath ||
      state.matchedLocation == Routes.splashPath;

  if (!loggedIn && !isAuthRoute) return Routes.loginPath;
  return null;
}
```

- [ ] **Step 2: Remove the old `Pages.navigatorKey` static reference**

If a `Pages` class exists with a static `navigatorKey`, replace all references with `_navigatorKey` (now local to app_pages.dart).

- [ ] **Step 3: Verify analysis**

Run: `flutter analyze`
Expected: No new errors

- [ ] **Step 4: Commit**

```bash
git add lib/core/routes/
git commit -m "refactor: add auth-aware GoRouter redirect guard"
```

---

### Task 10: Remove dead network/REST API code

The `lib/data/network/` directory contains `api_config.dart` and `dio_provider.dart` that are completely unused (the app uses Firestore exclusively). The `dio` dependency in pubspec.yaml is also unused by production code.

**Files:**
- Delete: `lib/data/network/api_config.dart`
- Delete: `lib/data/network/dio_provider.dart`
- Modify: `pubspec.yaml` (remove `dio` dependency)

- [ ] **Step 1: Verify no code imports from data/network/**

Run: `grep -r "data/network" lib/ --include="*.dart"`
Expected: Only the two files themselves (no imports from other files). If any file imports from them, update that file first.

- [ ] **Step 2: Delete dead files**

```bash
rm lib/data/network/api_config.dart lib/data/network/dio_provider.dart
rmdir lib/data/network
```

- [ ] **Step 3: Remove dio dependency from pubspec.yaml**

Remove the line `dio: ^5.9.2` from pubspec.yaml dependencies.

- [ ] **Step 4: Run flutter pub get**

Run: `flutter pub get`
Expected: Success

- [ ] **Step 5: Verify analysis**

Run: `flutter analyze`
Expected: No new errors

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "refactor: remove dead REST API/DIO network code"
```

---

### Task 11: Add consistent barrel files for features

Features lack barrel file exports while `core/` uses them consistently. Add barrel files for each feature module.

**Files:**
- Create: `lib/features/auth/auth.dart`
- Create: `lib/features/display/display.dart`
- Create: `lib/features/settings/settings.dart`
- Create: `lib/features/language/language.dart`
- Create: `lib/features/splash/splash.dart`

- [ ] **Step 1: Create feature barrel files**

Create `lib/features/auth/auth.dart`:
```dart
export 'bloc/login_bloc.dart';
export 'bloc/registration_bloc.dart';
export 'repository/auth_repository.dart';
```

Create `lib/features/display/display.dart`:
```dart
export 'bloc/display_bloc.dart';
export 'controller/display_layer_controller.dart';
```

Create `lib/features/settings/settings.dart`:
```dart
export 'bloc/settings/settings_bloc.dart';
```

Create `lib/features/language/language.dart`:
```dart
export 'bloc/language/language_bloc.dart';
```

Create `lib/features/splash/splash.dart`:
```dart
export 'bloc/splash_routing_bloc.dart';
```

- [ ] **Step 2: Verify analysis**

Run: `flutter analyze`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/features/
git commit -m "refactor: add consistent barrel files for all feature modules"
```

---

### Task 12: Final integration verification

**Files:**
- Test: `test/widget_test.dart`

- [ ] **Step 1: Run full analysis**

Run: `flutter analyze`
Expected: 0 errors. Existing info-level warnings are acceptable.

- [ ] **Step 2: Run tests**

Run: `flutter test`
Expected: All tests pass

- [ ] **Step 3: Verify the app builds**

Run: `flutter build apk --debug`
Expected: BUILD SUCCESSFUL (or use `flutter build appbundle` if preferred)

- [ ] **Step 4: Commit any final fixes if needed**

```bash
git add -A
git commit -m "refactor: final verification and fixes for deep architecture refactor"
```
