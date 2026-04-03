import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileRequested extends ProfileEvent {}

class UpdatePasswordRequested extends ProfileEvent {
  final String newPassword;
  const UpdatePasswordRequested({required this.newPassword});

  @override
  List<Object?> get props => [newPassword];
}

class UpdatePhoneRequested extends ProfileEvent {
  final String newPhone;

  const UpdatePhoneRequested(this.newPhone);

  @override
  List<Object?> get props => [newPhone];
}
