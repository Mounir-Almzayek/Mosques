import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/error_mapper.dart';
import '../../../../core/utils/async_runner.dart';
import '../../../../data/models/administrative_division.dart';
import '../../../../data/repositories/interfaces/administrative_divisions_repository_interface.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import 'mosque_info_event.dart';
import 'mosque_info_state.dart';

export 'mosque_info_event.dart';
export 'mosque_info_state.dart';

class MosqueInfoBloc extends Bloc<MosqueInfoEvent, MosqueInfoState> {
  final IMosqueRepository _mosqueRepository;
  final IAdministrativeDivisionsRepository _divisionsRepository;
  final AsyncRunner<void> _saveRunner = AsyncRunner();
  Timer? _searchDebounce;
  StreamSubscription<dynamic>? _sub;

  MosqueInfoBloc({
    required IMosqueRepository mosqueRepository,
    required IAdministrativeDivisionsRepository divisionsRepository,
  }) : _mosqueRepository = mosqueRepository,
       _divisionsRepository = divisionsRepository,
       super(const MosqueInfoState()) {
    on<LoadMosqueInfo>(_onLoad);
    on<MosqueInfoMosqueUpdated>(_onMosqueUpdated);
    on<MosqueInfoNameChanged>(_onNameChanged);
    on<MosqueInfoSearchChanged>(_onSearchChanged);
    on<MosqueInfoDivisionSelected>(_onDivisionSelected);
    on<MosqueInfoCoordinatesChanged>(_onCoordinatesChanged);
    on<SaveMosqueInfoRequested>(_onSave);
    on<DiscardMosqueInfoChangesRequested>(_onDiscardChanges);
  }

  Future<void> _onLoad(
    LoadMosqueInfo event,
    Emitter<MosqueInfoState> emit,
  ) async {
    _sub?.cancel();
    emit(state.copyWith(isLoading: true));
    _sub = _mosqueRepository.streamActiveMosque.listen(
      (mosque) => add(MosqueInfoMosqueUpdated(mosque)),
      onError: (Object error) =>
          emit(state.copyWith(isLoading: false, error: errorMessage(error))),
    );
    add(const MosqueInfoSearchChanged(''));
  }

  void _onMosqueUpdated(
    MosqueInfoMosqueUpdated event,
    Emitter<MosqueInfoState> emit,
  ) {
    if (state.hasUnsavedChanges) {
      emit(state.copyWith(isLoading: false));
      return;
    }
    emit(
      state.copyWith(
        mosque: event.mosque,
        isLoading: false,
        hasUnsavedChanges: false,
      ),
    );
  }

  void _onNameChanged(
    MosqueInfoNameChanged event,
    Emitter<MosqueInfoState> emit,
  ) {
    final mosque = state.mosque;
    if (mosque == null) return;
    emit(
      state.copyWith(
        mosque: mosque.copyWith(
          mosque: mosque.mosque.copyWith(name: event.name),
        ),
        hasUnsavedChanges: true,
      ),
    );
  }

  Future<void> _onSearchChanged(
    MosqueInfoSearchChanged event,
    Emitter<MosqueInfoState> emit,
  ) async {
    _searchDebounce?.cancel();
    emit(state.copyWith(searchQuery: event.query, isSearching: true));
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (state.searchQuery != event.query) return;
    try {
      final results = await _divisionsRepository.search(query: event.query);
      emit(state.copyWith(isSearching: false, searchResults: results));
    } catch (error) {
      emit(state.copyWith(isSearching: false, error: errorMessage(error)));
    }
  }

  Future<void> _onDivisionSelected(
    MosqueInfoDivisionSelected event,
    Emitter<MosqueInfoState> emit,
  ) async {
    final mosque = state.mosque;
    if (mosque == null) return;
    try {
      final path = await _divisionsRepository.path(event.division.id);
      final selected = path.isNotEmpty ? path.last : event.division;
      final coordinatesSource = path.reversed
          .cast<AdministrativeDivision?>()
          .firstWhere(
            (division) =>
                division?.latitudeValue != null &&
                division?.longitudeValue != null,
            orElse: () => event.division,
          );
      emit(
        state.copyWith(
          mosque: mosque.copyWith(
            mosque: mosque.mosque.copyWith(
              city: selected.displayName,
              countryCode: selected.countryCode,
              administrativeDivisionId: selected.id,
              administrativeDivisionName: selected.displayName,
              administrativeDivisionPath: path.isNotEmpty
                  ? path
                  : [event.division],
              latitude: coordinatesSource?.latitudeValue?.toStringAsFixed(6),
              longitude: coordinatesSource?.longitudeValue?.toStringAsFixed(6),
            ),
          ),
          searchQuery: selected.displayName,
          hasUnsavedChanges: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(error: errorMessage(error)));
    }
  }

  void _onCoordinatesChanged(
    MosqueInfoCoordinatesChanged event,
    Emitter<MosqueInfoState> emit,
  ) {
    final mosque = state.mosque;
    if (mosque == null) return;
    emit(
      state.copyWith(
        mosque: mosque.copyWith(
          mosque: mosque.mosque.copyWith(
            latitude: event.latitude.toString(),
            longitude: event.longitude.toString(),
          ),
        ),
        hasUnsavedChanges: true,
      ),
    );
  }

  Future<void> _onSave(
    SaveMosqueInfoRequested event,
    Emitter<MosqueInfoState> emit,
  ) async {
    final mosque = state.mosque;
    if (mosque == null) return;
    await _saveRunner.run(
      checkConnectivity: false,
      onlineTask: (_) => _mosqueRepository.updateMosque(mosque),
      onStart: () => emit(state.copyWith(isSaving: true)),
      onSuccess: (_) => emit(
        state.copyWith(isSaving: false, hasUnsavedChanges: false, error: null),
      ),
      onError: (error) =>
          emit(state.copyWith(isSaving: false, error: errorMessage(error))),
    );
  }

  void _onDiscardChanges(
    DiscardMosqueInfoChangesRequested event,
    Emitter<MosqueInfoState> emit,
  ) {
    emit(state.copyWith(hasUnsavedChanges: false, error: null));
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    _sub?.cancel();
    _saveRunner.cancel();
    return super.close();
  }
}
