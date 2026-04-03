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

class SplashLoaded extends SplashRoutingState {
  final SplashDestination destination;
  const SplashLoaded({required this.destination});
}
