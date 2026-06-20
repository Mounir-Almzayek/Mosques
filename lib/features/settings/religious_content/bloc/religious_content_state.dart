import 'package:equatable/equatable.dart';

import '../../../../data/models/mosque/mosque_bootstrap.dart';

class ReligiousContentState extends Equatable {
  final MosqueBootstrap? mosque;
  final bool isLoading;
  final bool isSaving;
  final bool hasUnsavedChanges;
  final String? error;

  const ReligiousContentState({
    this.mosque,
    this.isLoading = false,
    this.isSaving = false,
    this.hasUnsavedChanges = false,
    this.error,
  });

  ReligiousContentState copyWith({
    MosqueBootstrap? mosque,
    bool? isLoading,
    bool? isSaving,
    bool? hasUnsavedChanges,
    String? error,
  }) {
    return ReligiousContentState(
      mosque: mosque ?? this.mosque,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    mosque,
    isLoading,
    isSaving,
    hasUnsavedChanges,
    error,
  ];
}
