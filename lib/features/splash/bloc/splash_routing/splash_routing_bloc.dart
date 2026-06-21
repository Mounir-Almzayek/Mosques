import 'dart:ui' as ui;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/splash/splash_destination.dart';
import '../../../../data/repositories/interfaces/auth_repository_interface.dart';
import '../../../../data/repositories/user_active_mosque_repository.dart';

part 'splash_routing_event.dart';
part 'splash_routing_state.dart';

class SplashRoutingBloc extends Bloc<SplashRoutingEvent, SplashRoutingState> {
  final IAuthRepository _authRepo;

  SplashRoutingBloc({required IAuthRepository authRepository})
      : _authRepo = authRepository,
        super(const SplashInitial()) {
    on<SplashCheckStatus>(_checkStatus);
  }

  Future<void> _checkStatus(
    SplashRoutingEvent event,
    Emitter<SplashRoutingState> emit,
  ) async {
    emit(const SplashLoading());

    // Delay to show splash nicely
    await Future.delayed(const Duration(seconds: 2));

    final currentUser = _authRepo.currentUser;

    if (currentUser == null) {
      emit(const SplashLoaded(destination: SplashDestination.login));
      return;
    }

    // Refresh active mosque from the backend when online; otherwise keep
    // the local cache. With the new backend this is a no-op — the active
    // mosque already arrives via login / GET /mobile/me.
    await UserActiveMosqueRepository.syncBestEffort(currentUser.uid);

    // Check local override using the new AppMode enum
    final savedMode = _authRepo.getAppModeOverride();
    bool isDisplayMode;

    if (savedMode != null) {
      isDisplayMode = savedMode.isDisplay;
    } else {
      // If no override, check physical screen size
      final view = ui.PlatformDispatcher.instance.views.first;
      final width = view.physicalSize.width / view.devicePixelRatio;

      // Screen >= 600 is considered Display Screen
      isDisplayMode = width >= 600;
    }

    if (isDisplayMode) {
      emit(const SplashLoaded(destination: SplashDestination.screenDisplay));
    } else {
      emit(const SplashLoaded(destination: SplashDestination.mobileSettings));
    }
  }
}
