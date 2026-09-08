import '../../../../core/network/client_api.dart';
import '../../../../core/network/endpoints_api.dart';
import '../../../../core/network/source_media_distante.dart';

class SourceProfilDistante {
  const SourceProfilDistante(this._client, this._media);
  final ClientApi _client;
  final SourceMediaDistante _media;

  Future<Map<String, dynamic>> ajouterEmail(String email) =>
      _client.post(EndpointsApi.ajouterEmail, corps: {'email': email});

  Future<Map<String, dynamic>> ajouterTelephone(String telephone) =>
      _client.post(EndpointsApi.ajouterTelephone, corps: {'phone': telephone});

  Future<Map<String, dynamic>> regenererIdentifiant(
    String preuveRecuperation,
  ) => _client.post(
    EndpointsApi.regenererIdentifiantStagia,
    corps: {'recovery_proof_token': preuveRecuperation},
  );

  Future<Map<String, dynamic>> uploaderPhoto({
    required String cheminFichier,
    required String etudiantId,
  }) async {
    final reponse = await _media.uploader(
      cheminFichier: cheminFichier,
      type: 'PROFILE_PHOTO',
      classification: 'INTERNAL',
      politiqueConservation: 'STANDARD',
    );
    final media = Map<String, dynamic>.from(reponse['data'] as Map);
    return _media.lier(
      mediaId: media['id'] as String,
      typeEntite: 'STUDENT',
      entiteId: etudiantId,
      typeRelation: 'PROFILE_PHOTO',
    );
  }
}
