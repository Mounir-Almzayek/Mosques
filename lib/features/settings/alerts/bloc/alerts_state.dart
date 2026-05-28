import 'package:equatable/equatable.dart';

import '../../../../data/models/mosque/mosque_model.dart';

class AlertsState extends Equatable {
  final MosqueModel? mosque;
  final bool isLoading;
  final bool isSaving;
  final bool hasUnsavedChanges;
  final String? error;

  const AlertsState({
    this.mosque,
    this.isLoading = false,
    this.isSaving = false,
    this.hasUnsavedChanges = false,
    this.error,
  });

  AlertsState copyWith({
    MosqueModel? mosque,
    bool? isLoading,
    bool? isSaving,
    bool? hasUnsavedChanges,
    String? error,
  }) {
    return AlertsState(
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
