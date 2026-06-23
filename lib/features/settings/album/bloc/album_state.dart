import 'package:equatable/equatable.dart';

import '../../../../data/models/mosque/mosque_bootstrap.dart';

class AlbumState extends Equatable {
  final MosqueBootstrap? mosque;
  final bool isLoading;
  final bool isSaving;
  final bool isUploading;
  final bool hasUnsavedChanges;
  final String? error;

  const AlbumState({
    this.mosque,
    this.isLoading = false,
    this.isSaving = false,
    this.isUploading = false,
    this.hasUnsavedChanges = false,
    this.error,
  });

  AlbumState copyWith({
    MosqueBootstrap? mosque,
    bool? isLoading,
    bool? isSaving,
    bool? isUploading,
    bool? hasUnsavedChanges,
    String? error,
  }) {
    return AlbumState(
      mosque: mosque ?? this.mosque,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isUploading: isUploading ?? this.isUploading,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    mosque,
    isLoading,
    isSaving,
    isUploading,
    hasUnsavedChanges,
    error,
  ];
}
