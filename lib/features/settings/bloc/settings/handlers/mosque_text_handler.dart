import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/models/mosque/mosque_model.dart';
import '../../../models/settings_edit_request.dart';
import '../settings_event.dart';
import '../settings_state.dart';

/// Mixin handling mosque text list CRUD (hadiths, verses, duas, adhkar).
mixin MosqueTextHandler on Bloc<SettingsEvent, SettingsState> {
  void Function(Emitter<SettingsState> emit, SettingsEditRequest next)
  get emitDraftUpdated;
  MosqueModel? get currentMosque;

  MosqueModel _mosqueWithTextList(
    MosqueModel m,
    MosqueTextListKind kind,
    List<MosqueTextEntryModel> list,
  ) {
    switch (kind) {
      case MosqueTextListKind.hadith:
        return m.copyWith(hadiths: list);
      case MosqueTextListKind.verse:
        return m.copyWith(verses: list);
      case MosqueTextListKind.dua:
        return m.copyWith(duas: list);
      case MosqueTextListKind.adhkar:
        return m.copyWith(adhkar: list);
    }
  }

  void onMosqueTextAdded(
    SettingsMosqueTextAdded event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final list = List<MosqueTextEntryModel>.from(m.listByKind(event.kind))
      ..add(event.item);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: _mosqueWithTextList(m, event.kind, list)),
    );
  }

  void onMosqueTextUpdated(
    SettingsMosqueTextUpdated event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final list = m
        .listByKind(event.kind)
        .map((h) => h.id == event.item.id ? event.item : h)
        .toList();
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: _mosqueWithTextList(m, event.kind, list)),
    );
  }

  void onMosqueTextRemoved(
    SettingsMosqueTextRemoved event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final list = m
        .listByKind(event.kind)
        .where((h) => h.id != event.itemId)
        .toList();
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: _mosqueWithTextList(m, event.kind, list)),
    );
  }
}

