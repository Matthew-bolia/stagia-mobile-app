import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/session_authentification_service.dart';
import 'client_api.dart';
import 'configuration_api.dart';
import 'endpoints_api.dart';
import 'reponse_api.dart';

class ClientApiHttp implements ClientApi {
  ClientApiHttp({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<Map<String, dynamic>> get(
    String chemin, {
    Map<String, dynamic>? parametres,
  }) => _envoyer('GET', chemin, parametres: parametres);

  @override
  Future<Map<String, dynamic>> post(
    String chemin, {
    Object? corps,
    Map<String, String>? entetes,
  }) => _envoyer('POST', chemin, corps: corps, entetes: entetes);

  @override
  Future<Map<String, dynamic>> patch(String chemin, {Object? corps}) =>
      _envoyer('PATCH', chemin, corps: corps);

  @override
  Future<Map<String, dynamic>> delete(String chemin) =>
      _envoyer('DELETE', chemin);

  @override
  Future<Map<String, dynamic>> envoyerFichier(
    String chemin, {
    required String cheminFichier,
    required Map<String, String> champs,
  }) {
    throw const ErreurApi(
      code: 'UPLOAD_NON_IMPLEMENTE',
      message: 'L’envoi de fichiers sera configuré avec son endpoint.',
    );
  }

  Future<Map<String, dynamic>> _envoyer(
    String methode,
    String chemin, {
    Map<String, dynamic>? parametres,
    Object? corps,
    Map<String, String>? entetes,
  }) async {
    if (ConfigurationApi.urlBase.trim().isEmpty) {
      throw const ErreurApi(
        code: 'URL_API_ABSENTE',
        message: 'L’adresse du serveur API n’est pas configurée.',
      );
    }

    final base = Uri.parse(ConfigurationApi.urlBase);
    var uri = base.replace(path: '${base.path}$chemin');
    if (parametres != null && parametres.isNotEmpty) {
      uri = uri.replace(
        queryParameters: parametres.map(
          (cle, valeur) => MapEntry(cle, valeur.toString()),
        ),
      );
    }

    final headers = <String, String>{
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      ...?entetes,
    };
    if (chemin != EndpointsApi.connexion) {
      final jeton = await SessionAuthentificationService.jeton();
      if (jeton != null && jeton.isNotEmpty) {
        headers['Authorization'] = 'Bearer $jeton';
      }
    }

    try {
      final formulaire =
          headers['Content-Type'] == 'application/x-www-form-urlencoded';
      Object? contenu;
      if (corps != null) {
        if (formulaire && corps is Map) {
          contenu = corps.map(
            (cle, valeur) => MapEntry(cle.toString(), valeur.toString()),
          );
        } else {
          headers['Content-Type'] = 'application/json';
          contenu = jsonEncode(corps);
        }
      }

      final requete = http.Request(methode, uri)..headers.addAll(headers);
      if (contenu is Map<String, String>) {
        requete.bodyFields = contenu;
      } else if (contenu is String) {
        requete.body = contenu;
      }

      final flux = await _client
          .send(requete)
          .timeout(ConfigurationApi.dureeExpiration);
      final reponse = await http.Response.fromStream(
        flux,
      ).timeout(ConfigurationApi.dureeExpiration);
      final texte = utf8.decode(reponse.bodyBytes);
      Map<String, dynamic> json = <String, dynamic>{};
      if (texte.isNotEmpty) {
        try {
          final contenuJson = jsonDecode(texte);
          if (contenuJson is Map) {
            json = Map<String, dynamic>.from(contenuJson);
          }
        } on FormatException {
          if (reponse.statusCode >= 200 && reponse.statusCode < 300) rethrow;
        }
      }

      if (reponse.statusCode < 200 || reponse.statusCode >= 300) {
        final ngrokHorsLigne =
            texte.contains('ERR_NGROK_3200') ||
            texte.toLowerCase().contains('endpoint is offline');
        throw ErreurApi(
          code: ngrokHorsLigne
              ? 'SERVEUR_NGROK_HORS_LIGNE'
              : 'HTTP_${reponse.statusCode}',
          message: ngrokHorsLigne
              ? 'Le serveur est hors ligne.'
              : json['message']?.toString() ??
                    'Erreur du serveur (${reponse.statusCode}).',
          details: json['data'],
        );
      }
      return json;
    } on ErreurApi {
      rethrow;
    } on TimeoutException {
      throw const ErreurApi(
        code: 'DELAI_DEPASSE',
        message: 'Le serveur met trop de temps à répondre.',
      );
    } on http.ClientException {
      throw const ErreurApi(
        code: 'SERVEUR_INJOIGNABLE',
        message: 'Serveur inaccessible ou requête bloquée par le navigateur.',
      );
    } on FormatException {
      throw const ErreurApi(
        code: 'REPONSE_INVALIDE',
        message: 'La réponse reçue du serveur est invalide.',
      );
    }
  }
}
