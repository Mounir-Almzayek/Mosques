import 'package:Tebyan/core/enums/display/display_layer_kind.dart';
import 'package:Tebyan/data/models/mosque/imam_tracking_session_model.dart';
import 'package:Tebyan/features/display/controller/display_layer_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('active imam tracking session has the highest display priority', () {
    final controller = DisplayLayerController();
    addTearDown(controller.dispose);

    controller.updateImamTrackingSession(
      const ImamTrackingSessionModel(
        isActive: true,
        isRecording: true,
        currentPage: 50,
      ),
    );

    expect(controller.state.activeLayer, DisplayLayerKind.imamTracking);

    controller.updateImamTrackingSession(
      const ImamTrackingSessionModel(
        isActive: false,
        isRecording: false,
        currentPage: 50,
      ),
    );

    expect(controller.state.activeLayer, DisplayLayerKind.prayerTimes);
  });
}
