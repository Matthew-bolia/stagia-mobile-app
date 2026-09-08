import '../../../../core/network/client_api.dart';
import '../../../../core/network/endpoints_api.dart';
import '../../../../core/network/configuration_api.dart';
import '../../../../core/network/reponse_api.dart';
import '../../../../core/mocks/donnees_etudiant_mockees.dart';

class SourceStageDistante {
  const SourceStageDistante(this._client);
  final ClientApi _client;

  Future<Map<String, dynamic>> campagnes({
    int page = 1,
    String? recherche,
  }) async {
    if (ConfigurationApi.utiliserDonneesMockees) {
      return DonneesEtudiantMockees.pourEndpoint(
        EndpointsApi.optionsStageEtudiant,
      );
    }

    Map<String, dynamic> reponse;
    try {
      reponse = await _client.get(
        EndpointsApi.campagnes,
        parametres: {'page': page, 'search': ?recherche},
      );
    } on ErreurApi catch (erreur) {
      if (erreur.code != 'HTTP_404') rethrow;
      reponse = await _client.get(EndpointsApi.optionsStageEtudiant);
    }
    if (reponse['success'] != true) {
      throw ErreurApi(
        code: 'REPONSE_API_REFUSEE',
        message: reponse['message']?.toString() ?? 'Requête refusée.',
        details: reponse['data'],
      );
    }

    return _normaliserCampagnes(reponse['data']);
  }

  Future<Map<String, dynamic>> opportunites(
    String campagneId, {
    int page = 1,
  }) => _client.get(
    EndpointsApi.opportunites(campagneId),
    parametres: {'page': page},
  );

  Future<Map<String, dynamic>> candidatures({
    int page = 1,
    String? statut,
  }) async {
    Map<String, dynamic> reponse;
    try {
      reponse = await _client.get(
        EndpointsApi.candidatures,
        parametres: {'page': page, 'filter[status]': ?statut},
      );
    } on ErreurApi catch (erreur) {
      if (erreur.code != 'HTTP_404') rethrow;
      reponse = await _client.get(EndpointsApi.candidaturesEtudiant);
    }
    if (reponse['success'] != true) {
      throw ErreurApi(
        code: 'REPONSE_API_REFUSEE',
        message: reponse['message']?.toString() ?? 'Requête refusée.',
        details: reponse['data'],
      );
    }
    return _normaliserListe(reponse['data']);
  }

  Future<Map<String, dynamic>> creerCandidature({
    required String campagneId,
    String? participationId,
    String? uniteAccueilId,
    required String motivation,
  }) => _client.post(
    EndpointsApi.candidatures,
    corps: {
      'campaign_id': campagneId,
      'participation_id': ?participationId,
      'desired_host_unit_id': ?uniteAccueilId,
      'motivation': motivation,
    },
  );

  Future<Map<String, dynamic>> reserver({
    required String candidatureId,
    required String capaciteId,
    required String cleIdempotence,
  }) => _client.post(
    EndpointsApi.reserverPlace(candidatureId),
    corps: {'capacity_id': capaciteId},
    entetes: {'Idempotency-Key': cleIdempotence},
  );

  Future<Map<String, dynamic>> confirmerReservation(String reservationId) =>
      _client.post(EndpointsApi.confirmerReservation(reservationId));

  Future<Map<String, dynamic>> annulerReservation(String reservationId) =>
      _client.post(EndpointsApi.annulerReservation(reservationId));

  static Map<String, dynamic> _normaliserCampagnes(Object? donnees) {
    if (donnees is List) {
      return {'campaigns': _liste(donnees)};
    }
    if (donnees is Map) {
      final map = Map<String, dynamic>.from(donnees);
      final campagnes = map['campaigns'] ?? map['items'] ?? map['data'];
      if (campagnes is List) {
        return {...map, 'campaigns': _liste(campagnes)};
      }
      if (campagnes is Map) {
        final imbriquees = campagnes['items'] ?? campagnes['data'];
        if (imbriquees is List) {
          return {...map, 'campaigns': _liste(imbriquees)};
        }
      }
    }
    throw const ErreurApi(
      code: 'DONNEES_CAMPAGNES_INVALIDES',
      message: 'Les campagnes reçues du serveur sont invalides.',
    );
  }

  static List<Map<String, dynamic>> _liste(Object? valeur) => valeur is List
      ? valeur.whereType<Map>().map(Map<String, dynamic>.from).toList()
      : <Map<String, dynamic>>[];

  static Map<String, dynamic> _normaliserListe(Object? donnees) {
    if (donnees is Map) {
      final map = Map<String, dynamic>.from(donnees);
      final items = map['items'] ?? map['data'];
      if (items is List) return {...map, 'items': _liste(items)};
      if (items is Map && items['items'] is List) {
        return {...map, 'items': _liste(items['items'])};
      }
    }
    if (donnees is List) return {'items': _liste(donnees)};
    throw const ErreurApi(
      code: 'DONNEES_CANDIDATURES_INVALIDES',
      message: 'Les candidatures reçues du serveur sont invalides.',
    );
  }
}
