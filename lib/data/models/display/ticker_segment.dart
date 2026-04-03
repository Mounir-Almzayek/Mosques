import '../../../core/enums/display/ticker_kind.dart';

export '../../../core/enums/display/ticker_kind.dart';

/// A single segment to display in the ticker bar.
class TickerSegment {
  final TickerKind kind;
  final String text;
  final String? qrData;

  const TickerSegment({required this.kind, required this.text, this.qrData});
}
