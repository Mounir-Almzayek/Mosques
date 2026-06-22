import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/error_mapper.dart';
import '../../../../core/services/push_service.dart';
import '../../../../core/utils/async_runner.dart';
import '../../../../data/repositories/interfaces/auth_repository_interface.dart';
import 'password_onboarding_event.dart';
import 'password_onboarding_state.dart';

export 'password_onboarding_event.dart';
export 'password_onboarding_state.dart';

class PasswordOnboardingBloc
    extends Bloc<PasswordOnboardingEvent, PasswordOnboardingState> {
  final IAuthRepository _authRepository;
  final AsyncRunner<void> _submitRunner = AsyncRunner();
  final AsyncRunner<void> _logoutRunner = AsyncRunner();

  PasswordOnboardingBloc({required IAuthRepository authRepository})
    : _authRepository = authRepository,
      super(const PasswordOnboardingState()) {
    on<SubmitPasswordOnboarding>(_onSubmit);
    on<LogoutPasswordOnboarding>(_onLogout);
  }

  Future<void> _onSubmit(
    SubmitPasswordOnboarding event,
    Emitter<PasswordOnboardingState> emit,
  ) async {
    await _submitRunner.run(
      checkConnectivity: false,
      onlineTask: (_) async {
        await _authRepository.changePassword(
          currentPassword: event.currentPassword,
          newPassword: event.newPassword,
        );
        await PushService.refreshToken();
      },
      onStart: () => emit(
        state.copyWith(status: PasswordOnboardingStatus.loading, error: null),
      ),
      onSuccess: (_) =>
          emit(state.copyWith(status: PasswordOnboardingStatus.success)),
      onError: (error) => emit(
        state.copyWith(
          status: PasswordOnboardingStatus.failure,
          error: errorMessage(error),
        ),
      ),
    );
  }

  Future<void> _onLogout(
    LogoutPasswordOnboarding event,
    Emitter<PasswordOnboardingState> emit,
  ) async {
    await _logoutRunner.run(
      checkConnectivity: false,
      onlineTask: (_) => _authRepository.logout(),
      onStart: () => emit(
        state.copyWith(status: PasswordOnboardingStatus.loading, error: null),
      ),
      onSuccess: (_) =>
          emit(state.copyWith(status: PasswordOnboardingStatus.loggedOut)),
      onError: (error) => emit(
        state.copyWith(
          status: PasswordOnboardingStatus.failure,
          error: errorMessage(error),
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _submitRunner.cancel();
    _logoutRunner.cancel();
    return super.close();
  }
}
