import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/error_mapper.dart';
import '../../../../core/utils/async_runner.dart';
import '../../../../data/repositories/interfaces/auth_repository_interface.dart';
import 'profile_event.dart';
import 'profile_state.dart';

export 'profile_event.dart';
export 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  static const passwordTooShortError = 'profile_error_password_short';
  static const phoneEmptyError = 'profile_error_phone_empty';

  final IAuthRepository _authRepo;
  final AsyncRunner<void> _writeRunner = AsyncRunner();
  final AsyncRunner<String?> _loadRunner = AsyncRunner();

  ProfileBloc({required IAuthRepository authRepository})
    : _authRepo = authRepository,
      super(const ProfileState()) {
    on<LoadProfileRequested>(_onLoadProfile);
    on<UpdatePasswordRequested>(_onUpdatePassword);
    on<UpdatePhoneRequested>(_onUpdatePhone);
  }

  Future<void> _onLoadProfile(
    LoadProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    await _loadRunner.run(
      checkConnectivity: false,
      onlineTask: (_) => _authRepo.getPhone(),
      onSuccess: (phone) {
        if (phone != null) emit(state.copyWith(phone: phone));
      },
      // Best-effort load: a failure leaves the cached/empty phone untouched.
      onError: (_) {},
    );
  }

  Future<void> _onUpdatePassword(
    UpdatePasswordRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (event.newPassword.length < 6) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          error: passwordTooShortError,
        ),
      );
      return;
    }
    await _writeRunner.run(
      checkConnectivity: false,
      onlineTask: (_) async {
        if (event.currentPassword.isNotEmpty) {
          await _authRepo.changePassword(
            currentPassword: event.currentPassword,
            newPassword: event.newPassword,
          );
        } else {
          await _authRepo.updatePassword(event.newPassword);
        }
      },
      onStart: () =>
          emit(state.copyWith(status: ProfileStatus.loading, error: null)),
      onSuccess: (_) => emit(state.copyWith(status: ProfileStatus.success)),
      onError: (error) => emit(
        state.copyWith(status: ProfileStatus.failure, error: errorMessage(error)),
      ),
    );
  }

  Future<void> _onUpdatePhone(
    UpdatePhoneRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (event.newPhone.isEmpty) {
      emit(
        state.copyWith(status: ProfileStatus.failure, error: phoneEmptyError),
      );
      return;
    }
    await _writeRunner.run(
      checkConnectivity: false,
      onlineTask: (_) => _authRepo.updatePhone(event.newPhone),
      onStart: () =>
          emit(state.copyWith(status: ProfileStatus.loading, error: null)),
      onSuccess: (_) => emit(
        state.copyWith(status: ProfileStatus.success, phone: event.newPhone),
      ),
      onError: (error) => emit(
        state.copyWith(status: ProfileStatus.failure, error: errorMessage(error)),
      ),
    );
  }

  @override
  Future<void> close() {
    _writeRunner.cancel();
    _loadRunner.cancel();
    return super.close();
  }
}
