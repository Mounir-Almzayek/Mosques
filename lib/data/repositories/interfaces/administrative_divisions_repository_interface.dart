import '../../models/administrative_division.dart';

abstract class IAdministrativeDivisionsRepository {
  Future<List<AdministrativeDivision>> search({
    String countryCode = 'SY',
    String? query,
    int limit = 25,
  });

  Future<List<AdministrativeDivision>> path(String divisionId);
}
