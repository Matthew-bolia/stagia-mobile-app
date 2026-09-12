import '../../../../core/network/client_api.dart';
import '../../../../core/network/endpoints_api.dart';

class SourceJournalDistante {
  const SourceJournalDistante(this._client);
  final ClientApi _client;

  Future<Map<String, dynamic>> ajouterActivite({
    required String stageId,
    String? affectationId,
    required String date,
    required String titre,
    required String description,
    String? categorie,
    String? duree,
    String? service,
    String? objectifs,
    String? competences,
    String? resultats,
    String? difficultes,
  }) => _client.post(
    EndpointsApi.ajouterActivite(stageId),
    corps: {
      if (affectationId != null && affectationId.isNotEmpty)
        'assignment_id': affectationId,
      'activity_date': date,
      'title': titre,
      'description': description,
      if (categorie != null && categorie.isNotEmpty) 'category': categorie,
      if (duree != null && duree.isNotEmpty) 'duration': duree,
      if (service != null && service.isNotEmpty) 'service_unit': service,
      if (objectifs != null && objectifs.isNotEmpty) 'objectives': objectifs,
      if (competences != null && competences.isNotEmpty)
        'skills': competences,
      if (resultats != null && resultats.isNotEmpty) 'results': resultats,
      if (difficultes != null && difficultes.isNotEmpty)
        'difficulties': difficultes,
    },
  );

  Future<Map<String, dynamic>> feuillePresence(
    String affectationId, {
    int page = 1,
  }) => _client.get(
    EndpointsApi.feuillePresence(affectationId),
    parametres: {'page': page},
  );

  Future<Map<String, dynamic>> justifierAbsence({
    required String presenceId,
    required String motif,
    required List<String> mediaIds,
  }) => _client.post(
    EndpointsApi.justifierAbsence(presenceId),
    corps: {'reason': motif, 'media_ids': mediaIds},
  );

  Future<Map<String, dynamic>> referentielEvaluation({
    required String stageTypeId,
  }) => _client.get(
    EndpointsApi.referentielEvaluation,
    parametres: {'filter[stage_type_id]': stageTypeId},
  );
}
