import 'package:equatable/equatable.dart';
import '../../../core/enums/auth/registration_status.dart';
import '../../../core/enums/registration_type.dart';

export '../../../core/enums/auth/registration_status.dart';

class RegistrationState extends Equatable {
  final RegistrationStatus status;
  final RegistrationType type;
  final String mosqueId;
  final bool isIdAvailable;
  final String? suggestedId;
  final String? error;

  const RegistrationState({
    this.status = RegistrationStatus.initial,
    this.type = RegistrationType.newMosque,
    this.mosqueId = '',
    this.isIdAvailable = true,
    this.suggestedId,
    this.error,
  });

  RegistrationState copyWith({
    RegistrationStatus? status,
    RegistrationType? type,
    String? mosqueId,
    bool? isIdAvailable,
    String? suggestedId,
    String? error,
  }) {
    return RegistrationState(
      status: status ?? this.status,
      type: type ?? this.type,
      mosqueId: mosqueId ?? this.mosqueId,
      isIdAvailable: isIdAvailable ?? this.isIdAvailable,
      suggestedId: suggestedId ?? this.suggestedId,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    type,
    mosqueId,
    isIdAvailable,
    suggestedId,
    error,
  ];
}
