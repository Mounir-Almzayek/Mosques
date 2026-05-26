sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get valueOrNull => switch (this) {
    Success(:final value) => value,
    Failure() => null,
  };

  String? get errorOrNull => switch (this) {
    Success() => null,
    Failure(:final message) => message,
  };

  R when<R>({
    required R Function(T value) success,
    required R Function(String message, Object? error) failure,
  }) => switch (this) {
    Success(:final value) => success(value),
    Failure(:final message, :final error) => failure(message, error),
  };
}

final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

final class Failure<T> extends Result<T> {
  final String message;
  final Object? error;
  const Failure(this.message, [this.error]);
}
