class PositionHint {
  final int surah;
  final int ayah;
  final int wordIndex;

  const PositionHint({
    required this.surah,
    required this.ayah,
    this.wordIndex = 0,
  });

  Map<String, dynamic> toJson() => {
    'surah': surah,
    'ayah': ayah,
    'wordIndex': wordIndex,
  };

  Map<String, dynamic> toWireJson() => {
    'type': 'position_hint',
    'surah': surah,
    'ayah': ayah,
    'word_index': wordIndex,
  };
}

class RecitationSessionAuthorization {
  final String requestId;
  final String aiSessionId;
  final String sessionToken;
  final String websocketUrl;
  final DateTime? expiresAt;

  const RecitationSessionAuthorization({
    required this.requestId,
    required this.aiSessionId,
    required this.sessionToken,
    required this.websocketUrl,
    this.expiresAt,
  });

  factory RecitationSessionAuthorization.fromJson(Map<String, dynamic> json) {
    final ai = (json['ai'] as Map?)?.cast<String, dynamic>() ?? const {};
    return RecitationSessionAuthorization(
      requestId: json['requestId']?.toString() ?? '',
      aiSessionId: ai['sessionId']?.toString() ?? '',
      sessionToken: ai['sessionToken']?.toString() ?? '',
      websocketUrl: ai['websocketUrl']?.toString() ?? '',
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
    );
  }
}
