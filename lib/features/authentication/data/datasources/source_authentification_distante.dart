import '../../../../core/network/client_api.dart';
import '../../../../core/network/endpoints_api.dart';
import '../../../../core/network/reponse_api.dart';

class SourceAuthentificationDistante {
  const SourceAuthentificationDistante(this._client);
  final ClientApi _client;

  Future<Map<String, dynamic>> connecter({
    required String identifiant,
    required String motDePasse,
    String nomAppareil = 'Stagia Mobile',
  }) async {
    final reponse = await _client.post(
      EndpointsApi.connexion,
      corps: {
        'identifiant': identifiant,
        'password': motDePasse,
        'device_name': nomAppareil,
      },
      entetes: const {'Content-Type': 'application/x-www-form-urlencoded'},
    );

    if (reponse['success'] != true) {
      throw ErreurApi(
        code: 'CONNEXION_REFUSEE',
        message: reponse['message']?.toString() ?? 'Connexion refusée.',
        details: reponse['data'],
      );
    }
    final data = reponse['data'];
    if (data is! Map<String, dynamic> || data['token'] == null) {
      throw const ErreurApi(
        code: 'JETON_ABSENT',
        message: 'Le serveur n’a pas retourné de jeton de connexion.',
      );
    }
    return data;
  }

  Future<void> demanderReinitialisation(String identifiant) async {
    final reponse = await _client.post(
      EndpointsApi.motDePasseOublie,
      corps: {'identifiant': identifiant},
      entetes: const {'Content-Type': 'application/json'},
    );
    if (reponse['success'] != true) {
      throw ErreurApi(
        code: 'RECUPERATION_REFUSEE',
        message:
            reponse['message']?.toString() ??
            'La demande de réinitialisation a été refusée.',
        details: reponse['data'],
      );
    }
  }

  Future<Map<String, dynamic>> rechercherInscription({
    required String universiteId,
    required String anneeAcademiqueId,
    required String matricule,
  }) => _client.post(
    EndpointsApi.rechercherInscription,
    corps: {
      'university_id': universiteId,
      'academic_year_id': anneeAcademiqueId,
      'matricule': matricule,
    },
  );

  Future<Map<String, dynamic>> verifierInscription(
    Map<String, dynamic> preuve,
  ) => _client.post(EndpointsApi.verifierInscription, corps: preuve);

  Future<Map<String, dynamic>> creerCompte({
    required String jetonVerification,
    required String motDePasse,
    required String confirmation,
  }) => _client.post(
    EndpointsApi.creerCompteEtudiant,
    corps: {
      'verified_claim_token': jetonVerification,
      'password': motDePasse,
      'password_confirmation': confirmation,
    },
  );

  Future<Map<String, dynamic>> ajouterEmail(String email) =>
      _client.post(EndpointsApi.ajouterEmail, corps: {'email': email});

  Future<Map<String, dynamic>> ajouterTelephone(String telephone) =>
      _client.post(EndpointsApi.ajouterTelephone, corps: {'phone': telephone});

  Future<Map<String, dynamic>> verifierIdentifiant({
    required String identifiantId,
    required String code,
  }) => _client.post(
    EndpointsApi.verifierIdentifiant(identifiantId),
    corps: {'code': code},
  );

  Future<Map<String, dynamic>> deconnecter(String jetonActualisation) =>
      _client.post(
        EndpointsApi.deconnexion,
        corps: {'refresh_token': jetonActualisation},
      );
}
