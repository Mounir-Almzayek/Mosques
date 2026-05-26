import 'package:equatable/equatable.dart';
import '../../../core/enums/display/display_layer_kind.dart';

class DisplayLayerState extends Equatable {
  final DisplayLayerKind activeLayer;
  final DisplayLayerKind? previousLayer;

  const DisplayLayerState({
    this.activeLayer = DisplayLayerKind.prayerTimes,
    this.previousLayer,
  });

  DisplayLayerState copyWith({
    DisplayLayerKind? activeLayer,
    DisplayLayerKind? previousLayer,
  }) {
    return DisplayLayerState(
      activeLayer: activeLayer ?? this.activeLayer,
      previousLayer: previousLayer ?? this.previousLayer,
    );
  }

  @override
  List<Object?> get props => [activeLayer, previousLayer];
}
