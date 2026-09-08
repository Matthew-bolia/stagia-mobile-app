import 'client_api.dart';
import 'endpoints_api.dart';

class SourceMediaDistante {
  const SourceMediaDistante(this._client);
  final ClientApi _client;

  Future<Map<String, dynamic>> uploader({
    required String cheminFichier,
    required String type,
    required String classification,
    required String politiqueConservation,
  }) => _client.envoyerFichier(
    EndpointsApi.medias,
    cheminFichier: cheminFichier,
    champs: {
      'media_type': type,
      'classification': classification,
      'retention_policy': politiqueConservation,
    },
  );

  Future<Map<String, dynamic>> lier({
    required String mediaId,
    required String typeEntite,
    required String entiteId,
    required String typeRelation,
  }) => _client.post(
    EndpointsApi.lierMedia(mediaId),
    corps: {
      'entity_type': typeEntite,
      'entity_id': entiteId,
      'relation_type': typeRelation,
    },
  );

  Future<Map<String, dynamic>> nouvelleVersion({
    required String mediaId,
    required String cheminFichier,
    required String motif,
  }) => _client.envoyerFichier(
    EndpointsApi.versionsMedia(mediaId),
    cheminFichier: cheminFichier,
    champs: {'reason': motif},
  );

  Future<Map<String, dynamic>> obtenirUrlTelechargement(
    String mediaId, {
    int? version,
  }) => _client.post(
    EndpointsApi.urlTelechargement(mediaId),
    corps: {'version': ?version},
  );
}
