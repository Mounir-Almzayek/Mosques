part of 'update_bloc.dart';

class UpdateState extends Equatable {
  final UpdateStatus status;
  final double progress;
  final String? localPath;
  final String? error;

  const UpdateState({
    this.status = UpdateStatus.initial,
    this.progress = 0,
    this.localPath,
    this.error,
  });

  UpdateState copyWith({
    UpdateStatus? status,
    double? progress,
    String? localPath,
    String? error,
  }) {
    return UpdateState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      localPath: localPath ?? this.localPath,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, progress, localPath, error];
}
