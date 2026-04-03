import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/repository/auth_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

export 'profile_event.dart';
export 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState()) {
    on<LoadProfileRequested>(_onLoadProfile);
    on<UpdatePasswordRequested>(_onUpdatePassword);
    on<UpdatePhoneRequested>(_onUpdatePhone);
  }

  Future<void> _onLoadProfile(
    LoadProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final phone = await AuthRepository.getPhone();
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
        throw 'Password is too short. Minimum 6 characters.';
      }

      await AuthRepository.updatePassword(event.newPassword);
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
        throw 'Phone number cannot be empty.';
      }
      await AuthRepository.updatePhone(event.newPhone);
      emit(state.copyWith(status: ProfileStatus.success, phone: event.newPhone));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.failure, error: e.toString()));
    }
  }
}
