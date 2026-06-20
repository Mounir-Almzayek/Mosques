import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileRequested extends ProfileEvent {}

class UpdatePasswordRequested extends ProfileEvent {
  /// New password to set.
  final String newPassword;

  /// Current password — required by the backend's change-password route.
  /// Empty when the caller does not collect it (legacy flow).
  final String currentPassword;

  const UpdatePasswordRequested({
    required this.newPassword,
    this.currentPassword = '',
  });

  @override
  List<Object?> get props => [newPassword, currentPassword];
}

class UpdatePhoneRequested extends ProfileEvent {
  final String newPhone;

  const UpdatePhoneRequested(this.newPhone);

  @override
  List<Object?> get props => [newPhone];
}
