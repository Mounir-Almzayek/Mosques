import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/app_language.dart';
import '../../../../data/models/mosque/mosque_bootstrap.dart';
import '../../../../data/repositories/interfaces/auth_repository_interface.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../../../auth/models/auth_user.dart';
import '../../../splash/repositories/settings_local_repository.dart';
import 'dart:async';

part 'language_event.dart';
part 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final IMosqueRepository _mosqueRepo;
  final IAuthRepository _authRepo;
  StreamSubscription<AuthUser?>? _authSubscription;
  StreamSubscription<MosqueBootstrap?>? _mosqueSubscription;

  LanguageBloc({
    required IMosqueRepository mosqueRepository,
    required IAuthRepository authRepository,
  })  : _mosqueRepo = mosqueRepository,
        _authRepo = authRepository,
        super(
          LanguageInitial(
            language: AppLanguage.fromCode(
              SettingsLocalRepository.loadLanguage().languageCode,
            ),
          ),
        ) {
    on<LoadLanguage>(_onLoadLanguage);
    on<ChangeLanguage>(_onChangeLanguage);
    on<RemoteLanguageChanged>(_onRemoteLanguageChanged);
  }

  Future<void> _onLoadLanguage(
    LoadLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    // Prefer the saved local language. On first run, persist the fallback
    // language so startup is stable before the backend returns a mosque.
    final storedLang = AppLanguage.fromCode(
      SettingsLocalRepository.loadLanguage().languageCode,
    );
    SettingsLocalRepository.storeLanguage(storedLang.locale);
    if (storedLang.code != state.language.code) {
      emit(LanguageInitial(language: storedLang));
    }

    // Start remote sync once.
    _authSubscription ??= _authRepo.authStateChanges().listen((
      user,
    ) async {
      if (isClosed) return;

      // Stop listening to mosque when logged out.
      if (user == null) {
        await _mosqueSubscription?.cancel();
        _mosqueSubscription = null;
        return;
      }

      // Apply remote language once immediately (helps initial navigation).
      try {
        final firstMosque = await _mosqueRepo.getActiveMosque();
        final remoteCode = firstMosque?.mosque.languageCode;
        if (remoteCode != null && remoteCode.isNotEmpty) {
          final newLang = AppLanguage.fromCode(remoteCode);
          if (newLang.code != state.language.code) {
            add(RemoteLanguageChanged(newLang));
          }
        }
      } catch (_) {}

      // Restart mosque subscription (depends on `active_mosque_id`).
      await _mosqueSubscription?.cancel();
      _mosqueSubscription = _mosqueRepo.streamActiveMosque.listen((mosque) {
        if (mosque == null) return;
        final remoteCode = mosque.mosque.languageCode;
        if (remoteCode.isEmpty) return;

        final newLang = AppLanguage.fromCode(remoteCode);
        if (newLang.code == state.language.code) return;
        add(RemoteLanguageChanged(newLang));
      }, onError: (_) {});
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

    // Persist to backend (active mosque profile).
    try {
      await _mosqueRepo.updateLanguageCode(event.language);
    } catch (_) {
      // If there is no active mosque ref (e.g. edge timing), keep local change.
    }
  }

  void _onRemoteLanguageChanged(
    RemoteLanguageChanged event,
    Emitter<LanguageState> emit,
  ) {
    SettingsLocalRepository.storeLanguage(event.language.locale);
    if (event.language.code == state.language.code) return;
    emit(LanguageInitial(language: event.language));
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    await _mosqueSubscription?.cancel();
    return super.close();
  }
}
