import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repositories/interfaces/auth_repository_interface.dart';
import 'profile_event.dart';
import 'profile_state.dart';

export 'profile_event.dart';
export 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  static const passwordTooShortError = 'profile_error_password_short';
  static const phoneEmptyError = 'profile_error_phone_empty';

  final IAuthRepository _authRepo;

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
    try {
      final phone = await _authRepo.getPhone();
      if (phone != null) {
        emit(state.copyWith(phone: phone));
      }
    } catch (_) {}
  }

  Future<void> _onUpdatePassword(
    UpdatePasswordRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading, error: null));
    try {
      if (event.newPassword.length < 6) {
        emit(
          state.copyWith(
            status: ProfileStatus.failure,
            error: passwordTooShortError,
          ),
        );
        return;
      }

      await _authRepo.updatePassword(event.newPassword);
      emit(state.copyWith(status: ProfileStatus.success));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onUpdatePhone(
    UpdatePhoneRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading, error: null));
    try {
      if (event.newPhone.isEmpty) {
        emit(
          state.copyWith(status: ProfileStatus.failure, error: phoneEmptyError),
        );
        return;
      }
      await _authRepo.updatePhone(event.newPhone);
      emit(
        state.copyWith(status: ProfileStatus.success, phone: event.newPhone),
      );
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.failure, error: e.toString()));
    }
  }
}
