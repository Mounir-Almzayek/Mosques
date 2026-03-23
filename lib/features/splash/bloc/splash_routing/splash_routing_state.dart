part of 'splash_routing_bloc.dart';

abstract class SplashRoutingState {
  const SplashRoutingState();
}

class SplashInitial extends SplashRoutingState {
  const SplashInitial();
}

class SplashLoading extends SplashRoutingState {
  const SplashLoading();
}

class SplashError extends SplashRoutingState {
  final String message;
  const SplashError(this.message);
}

enum SplashDestination { login, mobileSettings, screenDisplay }

class SplashLoaded extends SplashRoutingState {
  final SplashDestination destination;
  const SplashLoaded({required this.destination});
}
