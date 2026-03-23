part of 'logout_bloc.dart';

/// Logout States
abstract class LogoutState {
  const LogoutState();
}

/// Initial state
class LogoutInitial extends LogoutState {
  const LogoutInitial();
}

/// Loading state
class LogoutLoading extends LogoutState {
  const LogoutLoading();
}

/// Success state
class LogoutSuccess extends LogoutState {
  final String message;

  const LogoutSuccess({required this.message});
}

/// Error state
class LogoutError extends LogoutState {
  final String error;

  const LogoutError(this.error);
}
