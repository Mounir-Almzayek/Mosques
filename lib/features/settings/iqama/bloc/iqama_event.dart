import 'package:equatable/equatable.dart';

import '../../../../data/models/mosque/mosque_model.dart';

// ——— Enums ———

enum IqamaField { fajr, dhuhr, asr, maghrib, isha, jummah }

// ——— Events ———

sealed class IqamaEvent extends Equatable {
  const IqamaEvent();

  @override
  List<Object?> get props => [];
}

class LoadIqama extends IqamaEvent {
  const LoadIqama();
}

class IqamaOffsetChanged extends IqamaEvent {
  final IqamaField prayer;
  final int offset;

  const IqamaOffsetChanged(this.prayer, this.offset);

  @override
  List<Object?> get props => [prayer, offset];
}

class SaveIqamaRequested extends IqamaEvent {
  const SaveIqamaRequested();
}

/// Internal event emitted when the mosque stream pushes a new value.
/// Not part of the public API; use [LoadIqama] instead.
class IqamaMosqueUpdated extends IqamaEvent {
  final MosqueModel? mosque;

  const IqamaMosqueUpdated(this.mosque);

  @override
  List<Object?> get props => [mosque];
}
