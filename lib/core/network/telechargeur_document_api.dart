import 'dart:io';

import '../services/session_authentification_service.dart';
import 'configuration_api.dart';
import 'reponse_api.dart';

class TelechargeurDocumentApi {
  const TelechargeurDocumentApi();

  Future<String> telechargerPdf({required String endpoint, required String nom}) async {
    final base = Uri.parse(ConfigurationApi.urlBase);
    final chemin = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final uri = base.replace(path: chemin.split('?').first, query: Uri.parse(endpoint).query);
    final jeton = await SessionAuthentificationService.jeton();
    if (jeton == null || jeton.isEmpty) {
      throw const ErreurApi(code: 'SESSION_ABSENTE', message: 'Votre session a expiré.');
    }

    final client = HttpClient();
    try {
      final requete = await client.getUrl(uri).timeout(ConfigurationApi.dureeExpiration);
      requete.headers.set(HttpHeaders.authorizationHeader, 'Bearer $jeton');
      requete.headers.set(HttpHeaders.acceptHeader, 'application/pdf');
      requete.headers.set('ngrok-skip-browser-warning', 'true');
      final reponse = await requete.close().timeout(ConfigurationApi.dureeExpiration);
      if (reponse.statusCode != HttpStatus.ok) {
        throw ErreurApi(code: 'HTTP_${reponse.statusCode}', message: 'Le document est indisponible sur le serveur.');
      }
      final nomSain = nom.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final fichier = File('${Directory.systemTemp.path}${Platform.pathSeparator}$nomSain.pdf');
      await reponse.pipe(fichier.openWrite());
      return fichier.path;
    } finally {
      client.close(force: true);
    }
  }
}
