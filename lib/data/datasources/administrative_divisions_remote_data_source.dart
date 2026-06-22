import '../../core/constants/api_endpoints.dart';
import '../../core/services/api_service.dart';
import '../models/administrative_division.dart';

class AdministrativeDivisionsRemoteDataSource {
  final ApiService _api;

  AdministrativeDivisionsRemoteDataSource({required ApiService api})
    : _api = api;

  Future<List<AdministrativeDivision>> search({
    String countryCode = 'SY',
    String? query,
    int limit = 25,
  }) async {
    final data = await _api.get(
      ApiEndpoints.administrativeDivisions,
      query: {
        'countryCode': countryCode,
        'limit': limit,
        if (query != null && query.trim().isNotEmpty) 'query': query.trim(),
      },
    );
    return _items(data);
  }

  Future<List<AdministrativeDivision>> path(String divisionId) async {
    final data = await _api.get(
      ApiEndpoints.administrativeDivisionPath(divisionId),
    );
    return _items(data);
  }

  List<AdministrativeDivision> _items(Map<String, dynamic> data) {
    final raw = data['items'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map(
          (item) =>
              AdministrativeDivision.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }
}
