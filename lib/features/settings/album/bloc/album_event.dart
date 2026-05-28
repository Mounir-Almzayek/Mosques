import 'package:equatable/equatable.dart';

import '../../../../data/models/mosque/mosque_model.dart';

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
  final MosqueModel? mosque;

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

class AlbumImageRemoved extends AlbumEvent {
  final String url;

  const AlbumImageRemoved(this.url);

  @override
  List<Object?> get props => [url];
}

class AlbumImagePublished extends AlbumEvent {
  final String url;
  final int durationSeconds;

  const AlbumImagePublished(this.url, this.durationSeconds);

  @override
  List<Object?> get props => [url, durationSeconds];
}

class AlbumImageUnpublished extends AlbumEvent {
  const AlbumImageUnpublished();
}

class SaveAlbumRequested extends AlbumEvent {
  const SaveAlbumRequested();
}
