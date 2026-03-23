import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import '../../../auth/repository/auth_repository.dart';
import '../../../auth/repository/user_active_mosque_repository.dart';

part 'splash_routing_event.dart';
part 'splash_routing_state.dart';

class SplashRoutingBloc extends Bloc<SplashRoutingEvent, SplashRoutingState> {
  SplashRoutingBloc() : super(const SplashInitial()) {
    on<SplashCheckStatus>(_checkStatus);
  }

  Future<void> _checkStatus(
    SplashRoutingEvent event,
    Emitter<SplashRoutingState> emit,
  ) async {
    emit(const SplashLoading());

    // Delay to show splash nicely
    await Future.delayed(const Duration(seconds: 2));

    final currentUser = AuthRepository.currentUser;

    if (currentUser == null) {
      emit(const SplashLoaded(destination: SplashDestination.login));
      return;
    }

    // تحديث المسجد النشط من السيرفر عند توفر الشبكة؛ وإلا الإبقاء على الكاش المحلي
    await UserActiveMosqueRepository.syncBestEffort(currentUser.uid);
    
    // Check local override
    bool? isDisplayMode = AuthRepository.getIsDisplayModeOverride();
    
    // If no override, check physical screen size
    if (isDisplayMode == null) {
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
