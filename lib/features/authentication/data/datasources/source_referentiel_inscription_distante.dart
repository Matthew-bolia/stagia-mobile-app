import '../../../../core/network/client_api.dart';
import '../../../../core/network/endpoints_api.dart';

class SourceReferentielInscriptionDistante {
  const SourceReferentielInscriptionDistante(this._client);
  final ClientApi _client;

  Future<Map<String, dynamic>> universites({int page = 1, String? recherche}) =>
      _client.get(
        EndpointsApi.universites,
        parametres: {'page': page, 'search': ?recherche},
      );

  Future<Map<String, dynamic>> anneesAcademiques(
    String universiteId, {
    int page = 1,
  }) => _client.get(
    EndpointsApi.anneesAcademiques(universiteId),
    parametres: {'page': page},
  );

  Future<Map<String, dynamic>> facultes(String universiteId, {int page = 1}) =>
      _client.get(
        EndpointsApi.facultes(universiteId),
        parametres: {'page': page},
      );

  Future<Map<String, dynamic>> promotions(
    String universiteId, {
    required String anneeAcademiqueId,
    int page = 1,
  }) => _client.get(
    EndpointsApi.promotions(universiteId),
    parametres: {
      'academic_year_id': anneeAcademiqueId,
      'page': page,
      'per_page': 50,
    },
  );
}
