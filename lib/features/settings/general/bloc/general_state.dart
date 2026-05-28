import 'package:equatable/equatable.dart';

import '../../../../data/models/mosque/mosque_model.dart';

class GeneralState extends Equatable {
  final MosqueModel? mosque;
  final bool isLoading;
  final bool isSaving;
  final bool hasUnsavedChanges;
  final String? error;

  const GeneralState({
    this.mosque,
    this.isLoading = false,
    this.isSaving = false,
    this.hasUnsavedChanges = false,
    this.error,
  });

  GeneralState copyWith({
    MosqueModel? mosque,
    bool? isLoading,
    bool? isSaving,
    bool? hasUnsavedChanges,
    String? error,
  }) {
    return GeneralState(
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
