import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/async_runner.dart';
import '../../../../core/utils/error_helper.dart';
import '../../repository/auth_local_repository.dart';
import '../../models/logout_response.dart';
import '../../repository/logout_repository.dart';

part 'logout_event.dart';
part 'logout_state.dart';

/// Logout BLoC
/// Manages logout state and events
class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final AsyncRunner<LogoutResponse> logoutRunner =
      AsyncRunner<LogoutResponse>();

  LogoutBloc() : super(const LogoutInitial()) {
    on<LogoutRequested>(_onLogoutRequested);
  }

  @override
  Future<void> close() {
    logoutRunner.cancel();
    return super.close();
  }

  /// Handle LogoutRequested event
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<LogoutState> emit,
  ) async {
    await logoutRunner.run(
      onlineTask: (_) async {
        return await LogoutRepository.logout();
      },
      onStart: () {
        emit(const LogoutLoading());
      },
      onSuccess: (response) async {
        // Clear token from local storage
        AuthLocalRepository.clearAuthData();
        emit(LogoutSuccess(message: response.message ?? ''));
      },
      onError: (error) {
        emit(LogoutError(ErrorHelper.getErrorMessage(error)));
      },
    );
  }
}
