import 'package:equatable/equatable.dart';

import '../../models/login_request.dart';
import '../../models/login_success_response.dart';

abstract class LoginState extends Equatable {
  final LoginRequest request;

  const LoginState({required this.request});

  @override
  List<Object?> get props => [request];
}

class LoginInitial extends LoginState {
  const LoginInitial({required super.request});

  LoginInitial copyWith({LoginRequest? request}) {
    return LoginInitial(request: request ?? this.request);
  }
}

class LoginLoading extends LoginState {
  const LoginLoading({required super.request});

  LoginLoading copyWith({LoginRequest? request}) {
    return LoginLoading(request: request ?? this.request);
  }
}

class LoginSuccess extends LoginState {
  final LoginSuccessResponse response;

  const LoginSuccess({
    required super.request,
    required this.response,
  });

  @override
  List<Object?> get props => [request, response];

  LoginSuccess copyWith({
    LoginRequest? request,
    LoginSuccessResponse? response,
  }) {
    return LoginSuccess(
      request: request ?? this.request,
      response: response ?? this.response,
    );
  }
}

class LoginFailure extends LoginState {
  final String error;

  const LoginFailure({required super.request, required this.error});

  @override
  List<Object?> get props => [request, error];

  LoginFailure copyWith({LoginRequest? request, String? error}) {
    return LoginFailure(
      request: request ?? this.request,
      error: error ?? this.error,
    );
  }
}
