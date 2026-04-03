import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../repository/auth_repository.dart';
import 'registration_event.dart';
import '../../presentation/registration_state.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  RegistrationBloc() : super(const RegistrationState()) {
    on<RegistrationTypeChanged>(_onTypeChanged);
    on<RegistrationMosqueIdChanged>(
      _onMosqueIdChanged,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 500))
          .switchMap(mapper),
    );
    on<RegistrationSubmitted>(_onSubmitted);
  }

  void _onTypeChanged(
    RegistrationTypeChanged event,
    Emitter<RegistrationState> emit,
  ) {
    emit(state.copyWith(type: event.type, status: RegistrationStatus.initial));
  }

  Future<void> _onMosqueIdChanged(
    RegistrationMosqueIdChanged event,
    Emitter<RegistrationState> emit,
  ) async {
    final mosqueId = event.mosqueId.trim();
    if (mosqueId.isEmpty) {
      emit(state.copyWith(mosqueId: mosqueId, isIdAvailable: true, suggestedId: null));
      return;
    }

    emit(
      state.copyWith(
        mosqueId: mosqueId,
        isIdAvailable: true,
        suggestedId: null,
        status: RegistrationStatus.initial,
        error: null,
      ),
    );
  }

  Future<void> _onSubmitted(
    RegistrationSubmitted event,
    Emitter<RegistrationState> emit,
  ) async {
    if (state.type.isNew && !state.isIdAvailable) {
      emit(
        state.copyWith(
          status: RegistrationStatus.failure,
          error: 'This Mosque ID is already taken. Please choose another.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: RegistrationStatus.loading));

    try {
      await AuthRepository.register(
        email: event.email,
        password: event.password,
        phone: event.phone,
        mosqueId: state.type.isNew ? state.mosqueId : null,
        type: state.type,
      );
      emit(state.copyWith(status: RegistrationStatus.success));
    } catch (e) {
      final message = e.toString().contains('mosque_id_taken')
          ? 'This Mosque ID is already taken. Please choose another.'
          : e.toString();
      emit(
        state.copyWith(
          status: RegistrationStatus.failure,
          isIdAvailable: !message.contains('already taken'),
          suggestedId: message.contains('already taken')
              ? _generateSuggestedId(state.mosqueId)
              : state.suggestedId,
          error: message,
        ),
      );
    }
  }

  String _generateSuggestedId(String original) {
    final random = Random().nextInt(999);
    return '${original}_$random';
  }
}
