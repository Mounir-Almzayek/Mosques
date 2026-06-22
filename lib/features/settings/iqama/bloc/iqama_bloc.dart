import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/error_mapper.dart';
import '../../../../core/utils/async_runner.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import 'iqama_event.dart';
import 'iqama_state.dart';

export 'iqama_event.dart';
export 'iqama_state.dart';

class IqamaBloc extends Bloc<IqamaEvent, IqamaState> {
  final IMosqueRepository _repo;
  final AsyncRunner<void> _saveRunner = AsyncRunner();

  IqamaBloc({required IMosqueRepository mosqueRepository})
    : _repo = mosqueRepository,
      super(const IqamaState()) {
    on<LoadIqama>(_onLoad);
    on<IqamaMosqueUpdated>(_onMosqueUpdated);
    on<IqamaOffsetChanged>(_onIqamaOffsetChanged);
    on<SaveIqamaRequested>(_onSave);
    on<DiscardIqamaChangesRequested>(_onDiscardChanges);
  }

  StreamSubscription<dynamic>? _sub;

  Future<void> _onLoad(LoadIqama event, Emitter<IqamaState> emit) async {
    _sub?.cancel();
    emit(state.copyWith(isLoading: true));
    _sub = _repo.streamActiveMosque.listen(
      (mosque) => add(IqamaMosqueUpdated(mosque)),
      onError: (Object error) =>
          emit(state.copyWith(isLoading: false, error: errorMessage(error))),
    );
  }

  void _onMosqueUpdated(IqamaMosqueUpdated event, Emitter<IqamaState> emit) {
    if (!state.hasUnsavedChanges) {
      emit(
        state.copyWith(
          isLoading: false,
          mosque: event.mosque,
          hasUnsavedChanges: false,
        ),
      );
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
    final offsets = m.prayerSettings.iqamaOffsets;
    final i = switch (event.prayer) {
      IqamaField.fajr => offsets.copyWith(fajr: event.offset),
      IqamaField.dhuhr => offsets.copyWith(dhuhr: event.offset),
      IqamaField.asr => offsets.copyWith(asr: event.offset),
      IqamaField.maghrib => offsets.copyWith(maghrib: event.offset),
      IqamaField.isha => offsets.copyWith(isha: event.offset),
      IqamaField.jummah => offsets.copyWith(jummah: event.offset),
    };
    final prayer = m.prayerSettings.copyWith(iqamaOffsets: i);
    emit(
      state.copyWith(
        mosque: m.copyWith(prayerSettings: prayer),
        hasUnsavedChanges: true,
      ),
    );
  }

  Future<void> _onSave(
    SaveIqamaRequested event,
    Emitter<IqamaState> emit,
  ) async {
    final m = state.mosque;
    if (m == null) return;
    await _saveRunner.run(
      checkConnectivity: false,
      onlineTask: (_) => _repo.updateIqamaSettings(m),
      onStart: () => emit(state.copyWith(isSaving: true)),
      onSuccess: (_) => emit(
        state.copyWith(isSaving: false, hasUnsavedChanges: false, error: null),
      ),
      onError: (error) =>
          emit(state.copyWith(isSaving: false, error: errorMessage(error))),
    );
  }

  void _onDiscardChanges(
    DiscardIqamaChangesRequested event,
    Emitter<IqamaState> emit,
  ) {
    emit(state.copyWith(hasUnsavedChanges: false, error: null));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _saveRunner.cancel();
    return super.close();
  }
}
