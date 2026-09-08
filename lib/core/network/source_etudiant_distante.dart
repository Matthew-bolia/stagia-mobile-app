import 'client_api.dart';
import 'endpoints_api.dart';
import 'reponse_api.dart';
import 'configuration_api.dart';
import '../mocks/donnees_etudiant_mockees.dart';

class SourceEtudiantDistante {
  const SourceEtudiantDistante(this._client);

  final ClientApi _client;

  Future<Map<String, dynamic>> profil() =>
      _donnees(EndpointsApi.profilEtudiant);

  Future<Map<String, dynamic>> tableauDeBord() =>
      _donnees(EndpointsApi.tableauDeBordEtudiant);

  Future<Map<String, dynamic>> documents() =>
      _donnees(EndpointsApi.documentsEtudiant);

  Future<Map<String, dynamic>> stages() =>
      _donnees(EndpointsApi.stagesEtudiant);

  Future<Map<String, dynamic>> reservations() =>
      _donnees(EndpointsApi.reservationsEtudiant);

  Future<Map<String, dynamic>> admission() =>
      _donnees(EndpointsApi.admissionEtudiant);

  Future<Map<String, dynamic>> optionsStage() =>
      _donnees(EndpointsApi.optionsStageEtudiant);

  Future<Map<String, dynamic>> candidatures() =>
      _donnees(EndpointsApi.candidaturesEtudiant);

  Future<Map<String, dynamic>> presences() =>
      _donnees(EndpointsApi.presencesEtudiant);

  Future<Map<String, dynamic>> journal() =>
      _donnees(EndpointsApi.journalEtudiant);

  Future<Map<String, dynamic>> evaluations() =>
      _donnees(EndpointsApi.evaluationsEtudiant);

  Future<Map<String, dynamic>> paiements() =>
      _donnees(EndpointsApi.paiementsEtudiant);

  Future<Map<String, dynamic>> _donnees(String endpoint) async {
    if (ConfigurationApi.utiliserDonneesMockees) {
      return DonneesEtudiantMockees.pourEndpoint(endpoint);
    }
    final reponse = await _client.get(endpoint);
    if (reponse['success'] != true) {
      throw ErreurApi(
        code: 'REPONSE_API_REFUSEE',
        message: reponse['message']?.toString() ?? 'Requête refusée.',
        details: reponse['data'],
      );
    }

    final donnees = reponse['data'];
    if (donnees is! Map) {
      throw const ErreurApi(
        code: 'DONNEES_API_INVALIDES',
        message: 'Les données reçues du serveur sont invalides.',
      );
    }
    return Map<String, dynamic>.from(donnees);
  }
}
