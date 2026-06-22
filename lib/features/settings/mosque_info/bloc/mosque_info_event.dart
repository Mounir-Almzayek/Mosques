import 'package:equatable/equatable.dart';

import '../../../../data/models/administrative_division.dart';
import '../../../../data/models/mosque/mosque_bootstrap.dart';

sealed class MosqueInfoEvent extends Equatable {
  const MosqueInfoEvent();

  @override
  List<Object?> get props => [];
}

class LoadMosqueInfo extends MosqueInfoEvent {
  const LoadMosqueInfo();
}

class MosqueInfoMosqueUpdated extends MosqueInfoEvent {
  final MosqueBootstrap? mosque;

  const MosqueInfoMosqueUpdated(this.mosque);

  @override
  List<Object?> get props => [mosque];
}

class MosqueInfoNameChanged extends MosqueInfoEvent {
  final String name;

  const MosqueInfoNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class MosqueInfoSearchChanged extends MosqueInfoEvent {
  final String query;

  const MosqueInfoSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class MosqueInfoDivisionSelected extends MosqueInfoEvent {
  final AdministrativeDivision division;

  const MosqueInfoDivisionSelected(this.division);

  @override
  List<Object?> get props => [division];
}

class MosqueInfoCoordinatesChanged extends MosqueInfoEvent {
  final double latitude;
  final double longitude;

  const MosqueInfoCoordinatesChanged({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

class SaveMosqueInfoRequested extends MosqueInfoEvent {
  const SaveMosqueInfoRequested();
}

class DiscardMosqueInfoChangesRequested extends MosqueInfoEvent {
  const DiscardMosqueInfoChangesRequested();
}
