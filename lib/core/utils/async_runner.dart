import 'dart:async';
import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum MultipleCallsBehavior { abortNew, abortOld }

class AsyncRunner<T> {
  CancelableOperation<T>? _currentOperation;
  CancelToken? dioCancelToken;
  T? _currentValue;

  final MultipleCallsBehavior multipleCallsBehavior;
  final int maxRetryAttempts;
  final Duration retryDelay;
  final bool useExponentialBackoff;
  final Duration? timeout;

  AsyncRunner({
    this.multipleCallsBehavior = MultipleCallsBehavior.abortNew,
    this.maxRetryAttempts = 0,
    this.retryDelay = const Duration(milliseconds: 500),
    this.useExponentialBackoff = true,
    this.timeout,
  });

  CancelableOperation<T>? get currentOperation => _currentOperation;
  T? get currentValue => _currentValue;

  Future<CancelableOperation<T>?> run({
    Future<T> Function(T? previousResult)? onlineTask,
    Future<T> Function(T? previousResult)? offlineTask,
    void Function()? onStart,
    FutureOr<void> Function(T result)? onSuccess,
    void Function(Object error)? onError,
    FutureOr<void> Function(T result)? onOffline,
    void Function()? onCancel,
    void Function()? onMultipleCalls,
    bool checkConnectivity = true,
  }) async {
    if (_currentOperation != null && !_currentOperation!.isCompleted) {
      onMultipleCalls?.call();
      if (multipleCallsBehavior == MultipleCallsBehavior.abortNew) {
        return null;
      } else {
        cancel();
      }
    }

    dioCancelToken = CancelToken();
    onStart?.call();

    int attempt = 0;
    Duration currentRetryDelay = retryDelay;
    CancelableOperation<T>? newOperation;

    final actualOnlineTask = onlineTask;
    final actualOfflineTask = offlineTask;

    bool isOnline = true;
    if (checkConnectivity && (actualOnlineTask != null || actualOfflineTask != null)) {
      isOnline = await _checkNetworkConnectivity();
    }

    while (true) {
      try {
        Future<T> taskFuture;
        if (checkConnectivity && !isOnline && actualOfflineTask != null) {
          taskFuture = actualOfflineTask(_currentValue);
        } else if (actualOnlineTask != null) {
          taskFuture = actualOnlineTask(_currentValue);
        } else if (actualOfflineTask != null) {
          taskFuture = actualOfflineTask(_currentValue);
        } else {
          throw Exception('No task provided');
        }

        if (timeout != null) {
          taskFuture = taskFuture.timeout(timeout!);
        }
        newOperation = CancelableOperation<T>.fromFuture(
          taskFuture,
          onCancel: () {
            onCancel?.call();
          },
        );

        T result = await newOperation.value;
        _currentValue = result;

        if (checkConnectivity && !isOnline && onOffline != null) {
          await onOffline.call(result);
        } else {
          await onSuccess?.call(result);
        }

        _currentOperation = newOperation;
        return newOperation;
      } catch (e) {
        attempt++;
        if (attempt > maxRetryAttempts) {
          onError?.call(e);
          _currentOperation = newOperation;
          return newOperation;
        } else {
          await Future.delayed(currentRetryDelay);
          if (useExponentialBackoff) {
            currentRetryDelay *= 2;
          }
        }
      }
    }
  }

  void cancel({void Function()? onCancel}) {
    onCancel?.call();
    _currentOperation?.cancel();
    dioCancelToken?.cancel("Cancelled by AsyncRunner");
    _currentOperation = null;
  }

  void reset() {
    _currentValue = null;
    _currentOperation = null;
    dioCancelToken = null;
  }

  static Future<bool> _checkNetworkConnectivity() async {
    try {
      final connectivity = Connectivity();
      final result = await connectivity.checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (e) {
      return true;
    }
  }
}

