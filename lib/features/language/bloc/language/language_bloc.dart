import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/enums/app_language.dart';
import '../../../../data/models/mosque_model.dart';
import '../../../../data/repositories/mosque_repository.dart';
import '../../../splash/repositories/settings_local_repository.dart';
import '../../../auth/repository/user_active_mosque_repository.dart';
import 'dart:async';

part 'language_event.dart';
part 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  late final AppLanguage _deviceLanguage;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<MosqueModel?>? _mosqueSubscription;

  LanguageBloc()
    : super(
        LanguageInitial(
          language: AppLanguage.fromCode(
              SettingsLocalRepository.loadDeviceLanguage().languageCode,
          ),
        ),
        ) {
    _deviceLanguage = state.language;
    on<LoadLanguage>(_onLoadLanguage);
    on<ChangeLanguage>(_onChangeLanguage);
    on<RemoteLanguageChanged>(_onRemoteLanguageChanged);
  }

  Future<void> _onLoadLanguage(
    LoadLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    // Always prefer device language at startup.
    final deviceLang = AppLanguage.fromCode(
      SettingsLocalRepository.loadDeviceLanguage().languageCode,
    );
    if (deviceLang.code != state.language.code) {
      emit(LanguageInitial(language: deviceLang));
    }

    // Start remote sync once.
    _authSubscription ??= FirebaseAuth.instance
        .authStateChanges()
        .listen((user) async {
      if (isClosed) return;

      // Stop listening to mosque when logged out.
      if (user == null) {
        await _mosqueSubscription?.cancel();
        _mosqueSubscription = null;
        if (state.language.code != _deviceLanguage.code) {
          add(RemoteLanguageChanged(_deviceLanguage));
        }
        return;
      }

      // Ensure `active_mosque_id` is available in local storage first.
      await UserActiveMosqueRepository.syncBestEffort(user.uid);

      // Apply remote language once immediately (helps initial navigation).
      try {
        final firstMosque = await MosqueRepository.getActiveMosque();
        final remoteCode = firstMosque?.appLanguageCode;
        if (remoteCode != null && remoteCode.isNotEmpty) {
          final newLang = AppLanguage.fromCode(remoteCode);
          if (newLang.code != state.language.code) {
            add(RemoteLanguageChanged(newLang));
          }
        }
      } catch (_) {}

      // Restart mosque subscription (depends on `active_mosque_id`).
      await _mosqueSubscription?.cancel();
      _mosqueSubscription = MosqueRepository.streamActiveMosque.listen(
        (mosque) {
          if (mosque == null) return;
          final remoteCode = mosque.appLanguageCode;
          if (remoteCode == null || remoteCode.isEmpty) return;

          final newLang = AppLanguage.fromCode(remoteCode);
          if (newLang.code == state.language.code) return;
          add(RemoteLanguageChanged(newLang));
        },
        onError: (_) {},
      );
    });
  }

  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    if (event.language.code == state.language.code) return;

    // Update local memory/storage immediately.
    SettingsLocalRepository.storeLanguage(event.language.locale);
    emit(LanguageInitial(language: event.language));

    // Persist to Firebase (active mosque document).
    try {
      await MosqueRepository.updateLanguageCode(event.language);
    } catch (_) {
      // If there is no active mosque ref (e.g. edge timing), keep local change.
    }
  }

  void _onRemoteLanguageChanged(
    RemoteLanguageChanged event,
    Emitter<LanguageState> emit,
  ) {
    if (event.language.code == state.language.code) return;
    SettingsLocalRepository.storeLanguage(event.language.locale);
    emit(LanguageInitial(language: event.language));
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    await _mosqueSubscription?.cancel();
    return super.close();
  }
}

