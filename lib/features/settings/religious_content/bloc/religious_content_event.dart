import 'package:equatable/equatable.dart';

import '../../../../data/models/mosque/mosque_model.dart';

// ——— Enums ———

enum ReligiousContentTimingField { wait, display }

// ——— Events ———

sealed class ReligiousContentEvent extends Equatable {
  const ReligiousContentEvent();

  @override
  List<Object?> get props => [];
}

class LoadReligiousContent extends ReligiousContentEvent {
  const LoadReligiousContent();
}

class MosqueTextAdded extends ReligiousContentEvent {
  final MosqueTextListKind kind;
  final MosqueTextEntryModel item;

  const MosqueTextAdded(this.kind, this.item);

  @override
  List<Object?> get props => [kind, item];
}

class MosqueTextUpdated extends ReligiousContentEvent {
  final MosqueTextListKind kind;
  final MosqueTextEntryModel item;

  const MosqueTextUpdated(this.kind, this.item);

  @override
  List<Object?> get props => [kind, item];
}

class MosqueTextRemoved extends ReligiousContentEvent {
  final MosqueTextListKind kind;
  final String itemId;

  const MosqueTextRemoved(this.kind, this.itemId);

  @override
  List<Object?> get props => [kind, itemId];
}

class ReligiousContentTimingChanged extends ReligiousContentEvent {
  final ReligiousContentTimingField field;
  final int value;

  const ReligiousContentTimingChanged(this.field, this.value);

  @override
  List<Object?> get props => [field, value];
}

class SaveAllReligiousContentRequested extends ReligiousContentEvent {
  const SaveAllReligiousContentRequested();
}

/// Internal event emitted when the mosque stream pushes a new value.
/// Not part of the public API; use [LoadReligiousContent] instead.
class ReligiousContentMosqueUpdated extends ReligiousContentEvent {
  final MosqueModel? mosque;

  const ReligiousContentMosqueUpdated(this.mosque);

  @override
  List<Object?> get props => [mosque];
}
