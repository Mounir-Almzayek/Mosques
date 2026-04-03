import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/firebase_service.dart';
import '../../../../core/utils/async_runner.dart';
import '../../../../core/utils/error_helper.dart';
import '../../models/login_request.dart';
import '../../models/login_success_response.dart';
import '../../repository/auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

export 'login_event.dart';
export 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AsyncRunner<UserCredential> loginRunner = AsyncRunner();

  LoginBloc() : super(LoginInitial(request: LoginRequest())) {
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
    final updatedRequest = state.request.copyWith(deviceToken: event.deviceToken);
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
      deviceToken: FirebaseService.fcmToken ?? '',
    );
    emit(LoginInitial(request: updatedRequest));

    await loginRunner.run(
      onlineTask: (_) async {
        return AuthRepository.login(
          updatedRequest.email,
          updatedRequest.password,
        );
      },
      onStart: () {
        emit(LoginLoading(request: state.request));
      },
      onSuccess: (credential) async {
        await FirebaseService.syncTokenToCurrentUser();
        emit(
          LoginSuccess(
            request: state.request,
            response: LoginSuccessResponse(
              uid: credential.user?.uid ?? '',
              message: 'Logged in successfully',
            ),
          ),
        );
      },
      onError: (error) {
        emit(
          LoginFailure(
            request: state.request,
            error: ErrorHelper.getErrorMessage(error),
          ),
        );
      },
    );
  }
}
