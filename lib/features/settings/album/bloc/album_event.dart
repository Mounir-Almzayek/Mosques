import 'package:equatable/equatable.dart';

import '../../../../data/models/mosque/mosque_bootstrap.dart';

sealed class AlbumEvent extends Equatable {
  const AlbumEvent();

  @override
  List<Object?> get props => [];
}

class LoadAlbum extends AlbumEvent {
  const LoadAlbum();
}

/// Internal event emitted when the mosque stream pushes a new value.
class AlbumMosqueUpdated extends AlbumEvent {
  final MosqueBootstrap? mosque;

  const AlbumMosqueUpdated(this.mosque);

  @override
  List<Object?> get props => [mosque];
}

class AlbumImageAdded extends AlbumEvent {
  final String url;

  const AlbumImageAdded(this.url);

  @override
  List<Object?> get props => [url];
}

class AlbumImageUploadRequested extends AlbumEvent {
  final String filePath;

  const AlbumImageUploadRequested(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class AlbumImageRemoved extends AlbumEvent {
  final String url;

  const AlbumImageRemoved(this.url);

  @override
  List<Object?> get props => [url];
}

class AlbumImagePublished extends AlbumEvent {
  final String url;
  final int durationSeconds;
  final String fit;

  const AlbumImagePublished(this.url, this.durationSeconds, this.fit);

  @override
  List<Object?> get props => [url, durationSeconds, fit];
}

class AlbumImageUnpublished extends AlbumEvent {
  const AlbumImageUnpublished();
}

class SaveAlbumRequested extends AlbumEvent {
  const SaveAlbumRequested();
}

class DiscardAlbumChangesRequested extends AlbumEvent {
  const DiscardAlbumChangesRequested();
}
