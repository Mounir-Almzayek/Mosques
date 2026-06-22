import '../datasources/administrative_divisions_remote_data_source.dart';
import '../models/administrative_division.dart';
import 'interfaces/administrative_divisions_repository_interface.dart';

class AdministrativeDivisionsRepository
    implements IAdministrativeDivisionsRepository {
  final AdministrativeDivisionsRemoteDataSource _dataSource;

  AdministrativeDivisionsRepository({
    required AdministrativeDivisionsRemoteDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<List<AdministrativeDivision>> search({
    String countryCode = 'SY',
    String? query,
    int limit = 25,
  }) {
    return _dataSource.search(
      countryCode: countryCode,
      query: query,
      limit: limit,
    );
  }

  @override
  Future<List<AdministrativeDivision>> path(String divisionId) {
    return _dataSource.path(divisionId);
  }
}
