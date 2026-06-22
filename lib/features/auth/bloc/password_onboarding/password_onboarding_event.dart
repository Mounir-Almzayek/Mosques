import 'package:equatable/equatable.dart';

abstract class PasswordOnboardingEvent extends Equatable {
  const PasswordOnboardingEvent();

  @override
  List<Object?> get props => [];
}

class SubmitPasswordOnboarding extends PasswordOnboardingEvent {
  final String currentPassword;
  final String newPassword;

  const SubmitPasswordOnboarding({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class LogoutPasswordOnboarding extends PasswordOnboardingEvent {
  const LogoutPasswordOnboarding();
}
