part of 'logout_bloc.dart';

/// Logout Events
abstract class LogoutEvent {}

/// Request logout
class LogoutRequested extends LogoutEvent {
  LogoutRequested();
}
