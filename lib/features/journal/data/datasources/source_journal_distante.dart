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
  }) => _client.post(
    EndpointsApi.ajouterActivite(stageId),
    corps: {
      'assignment_id': ?affectationId,
      'activity_date': date,
      'title': titre,
      'description': description,
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
