import 'package:equatable/equatable.dart';

enum PasswordOnboardingStatus { initial, loading, success, failure, loggedOut }

class PasswordOnboardingState extends Equatable {
  final PasswordOnboardingStatus status;
  final String? error;

  const PasswordOnboardingState({
    this.status = PasswordOnboardingStatus.initial,
    this.error,
  });

  PasswordOnboardingState copyWith({
    PasswordOnboardingStatus? status,
    String? error,
  }) {
    return PasswordOnboardingState(status: status ?? this.status, error: error);
  }

  @override
  List<Object?> get props => [status, error];
}
