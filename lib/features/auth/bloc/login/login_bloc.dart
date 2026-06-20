import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/error_mapper.dart';
import '../../../../core/services/push_service.dart';
import '../../../../core/utils/async_runner.dart';
import '../../../../data/repositories/interfaces/auth_repository_interface.dart';
import '../../models/auth_session.dart';
import '../../models/login_request.dart';
import '../../models/login_success_response.dart';
import 'login_event.dart';
import 'login_state.dart';

export 'login_event.dart';
export 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final IAuthRepository _authRepo;
  final AsyncRunner<AuthSession> _loginRunner = AsyncRunner();

  LoginBloc({required IAuthRepository authRepository})
    : _authRepo = authRepository,
      super(LoginInitial(request: LoginRequest())) {
    on<UpdateEmail>(_onUpdateEmail);
    on<UpdatePassword>(_onUpdatePassword);
    on<UpdateDeviceToken>(_onUpdateDeviceToken);
    on<SendLoginRequest>(_onSendLoginRequest);
    on<ResetState>(_onResetState);
  }

  void _onUpdateEmail(UpdateEmail event, Emitter<LoginState> emit) {
    final updatedRequest = state.request.copyWith(email: event.email);
    emit(LoginInitial(request: updatedRequest));
  }

  void _onUpdatePassword(UpdatePassword event, Emitter<LoginState> emit) {
    final updatedRequest = state.request.copyWith(password: event.password);
    emit(LoginInitial(request: updatedRequest));
  }

  void _onUpdateDeviceToken(UpdateDeviceToken event, Emitter<LoginState> emit) {
    final updatedRequest = state.request.copyWith(
      deviceToken: event.deviceToken,
    );
    emit(LoginInitial(request: updatedRequest));
  }

  void _onResetState(ResetState event, Emitter<LoginState> emit) {
    emit(LoginInitial(request: LoginRequest()));
  }

  Future<void> _onSendLoginRequest(
    SendLoginRequest event,
    Emitter<LoginState> emit,
  ) async {
    final updatedRequest = state.request.copyWith(
      deviceToken: PushService.fcmToken ?? '',
    );
    emit(LoginInitial(request: updatedRequest));

    await _loginRunner.run(
      checkConnectivity: false,
      onlineTask: (_) =>
          _authRepo.login(updatedRequest.email, updatedRequest.password),
      onStart: () => emit(LoginLoading(request: state.request)),
      // PushService re-registers the device automatically when the token
      // rotates; the login response already carries the active device.
      onSuccess: (session) => emit(
        LoginSuccess(
          request: state.request,
          response: LoginSuccessResponse(
            uid: session.user.id,
            message: '',
          ),
        ),
      ),
      onError: (error) => emit(
        LoginFailure(
          request: state.request,
          error: errorMessage(error),
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _loginRunner.cancel();
    return super.close();
  }
}
