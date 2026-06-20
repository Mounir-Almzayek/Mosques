import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import 'recitation_ai_models.dart';

class RecitationAiRepository {
  final ApiService _api;

  RecitationAiRepository({required ApiService api}) : _api = api;

  Future<RecitationSessionAuthorization> authorize({
    required String mosqueId,
    required String riwayahCode,
    required int expectedDurationSeconds,
    PositionHint? positionHint,
  }) async {
    final data = await _api.post(
      ApiEndpoints.aiSessionRequests,
      body: {
        'mosqueId': mosqueId,
        'riwayahCode': riwayahCode,
        'expectedDurationSeconds': expectedDurationSeconds,
        if (positionHint != null) 'positionHint': positionHint.toJson(),
      },
    );
    return RecitationSessionAuthorization.fromJson(data);
  }

  Future<void> publishEvent({
    required String requestId,
    required String aiSessionId,
    required Map<String, dynamic> event,
  }) async {
    await _api.post(
      ApiEndpoints.aiSessionEvents(requestId),
      body: {'aiSessionId': aiSessionId, 'event': event},
    );
  }
}
