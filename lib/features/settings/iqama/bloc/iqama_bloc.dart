import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import 'iqama_event.dart';
import 'iqama_state.dart';

export 'iqama_event.dart';
export 'iqama_state.dart';

class IqamaBloc extends Bloc<IqamaEvent, IqamaState> {
  final IMosqueRepository _repo;

  IqamaBloc({required IMosqueRepository mosqueRepository})
      : _repo = mosqueRepository,
        super(const IqamaState()) {
    on<LoadIqama>(_onLoad);
    on<IqamaMosqueUpdated>(_onMosqueUpdated);
    on<IqamaOffsetChanged>(_onIqamaOffsetChanged);
    on<SaveIqamaRequested>(_onSave);
  }

  StreamSubscription<dynamic>? _sub;

  Future<void> _onLoad(LoadIqama event, Emitter<IqamaState> emit) async {
    _sub?.cancel();
    emit(state.copyWith(isLoading: true));
    _sub = _repo.streamActiveMosque.listen(
      (mosque) => add(IqamaMosqueUpdated(mosque)),
      onError: (Object error) =>
          emit(state.copyWith(isLoading: false, error: error.toString())),
    );
  }

  void _onMosqueUpdated(IqamaMosqueUpdated event, Emitter<IqamaState> emit) {
    if (!state.hasUnsavedChanges) {
      emit(state.copyWith(
        isLoading: false,
        mosque: event.mosque,
        hasUnsavedChanges: false,
      ));
    } else {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _onIqamaOffsetChanged(
    IqamaOffsetChanged event,
    Emitter<IqamaState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final i = switch (event.prayer) {
      IqamaField.fajr => m.iqamaSettings.copyWith(fajrOffset: event.offset),
      IqamaField.dhuhr => m.iqamaSettings.copyWith(dhuhrOffset: event.offset),
      IqamaField.asr => m.iqamaSettings.copyWith(asrOffset: event.offset),
      IqamaField.maghrib =>
        m.iqamaSettings.copyWith(maghribOffset: event.offset),
      IqamaField.isha => m.iqamaSettings.copyWith(ishaOffset: event.offset),
      IqamaField.jummah =>
        m.iqamaSettings.copyWith(jummahOffset: event.offset),
    };
    emit(state.copyWith(
      mosque: m.copyWith(iqamaSettings: i),
      hasUnsavedChanges: true,
    ));
  }

  Future<void> _onSave(
    SaveIqamaRequested event,
    Emitter<IqamaState> emit,
  ) async {
    final m = state.mosque;
    if (m == null) return;
    emit(state.copyWith(isSaving: true));
    try {
      await _repo.updateIqamaSettings(m);
      emit(state.copyWith(
        isSaving: false,
        hasUnsavedChanges: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
