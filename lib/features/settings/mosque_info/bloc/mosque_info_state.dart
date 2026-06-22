import 'package:equatable/equatable.dart';

import '../../../../data/models/administrative_division.dart';
import '../../../../data/models/mosque/mosque_bootstrap.dart';

class MosqueInfoState extends Equatable {
  final MosqueBootstrap? mosque;
  final bool isLoading;
  final bool isSearching;
  final bool isSaving;
  final bool hasUnsavedChanges;
  final String searchQuery;
  final List<AdministrativeDivision> searchResults;
  final String? error;

  const MosqueInfoState({
    this.mosque,
    this.isLoading = false,
    this.isSearching = false,
    this.isSaving = false,
    this.hasUnsavedChanges = false,
    this.searchQuery = '',
    this.searchResults = const [],
    this.error,
  });

  MosqueInfoState copyWith({
    MosqueBootstrap? mosque,
    bool? isLoading,
    bool? isSearching,
    bool? isSaving,
    bool? hasUnsavedChanges,
    String? searchQuery,
    List<AdministrativeDivision>? searchResults,
    String? error,
  }) {
    return MosqueInfoState(
      mosque: mosque ?? this.mosque,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      isSaving: isSaving ?? this.isSaving,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    mosque,
    isLoading,
    isSearching,
    isSaving,
    hasUnsavedChanges,
    searchQuery,
    searchResults,
    error,
  ];
}
