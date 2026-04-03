import 'package:equatable/equatable.dart';
import '../../../../core/enums/registration_type.dart';

abstract class RegistrationEvent extends Equatable {
  const RegistrationEvent();

  @override
  List<Object?> get props => [];
}

class RegistrationTypeChanged extends RegistrationEvent {
  final RegistrationType type;
  const RegistrationTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}

class RegistrationMosqueIdChanged extends RegistrationEvent {
  final String mosqueId;
  const RegistrationMosqueIdChanged(this.mosqueId);

  @override
  List<Object?> get props => [mosqueId];
}

class RegistrationSubmitted extends RegistrationEvent {
  final String email;
  final String password;
  final String phone;

  const RegistrationSubmitted({
    required this.email,
    required this.password,
    required this.phone,
  });

  @override
  List<Object> get props => [email, password, phone];
}
