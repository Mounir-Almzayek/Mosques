part of 'update_bloc.dart';

// --- Events ---
abstract class UpdateEvent extends Equatable {
  const UpdateEvent();
  @override
  List<Object?> get props => [];
}

class DownloadUpdateRequested extends UpdateEvent {
  final String url;
  const DownloadUpdateRequested(this.url);
}

class InstallUpdateRequested extends UpdateEvent {}
