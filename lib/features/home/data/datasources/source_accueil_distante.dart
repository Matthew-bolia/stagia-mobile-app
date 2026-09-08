import '../../../../core/network/client_api.dart';
import '../../../../core/network/endpoints_api.dart';

class SourceAccueilDistante {
  const SourceAccueilDistante(this._client);
  final ClientApi _client;

  Future<Map<String, dynamic>> chargerTableauDeBord() =>
      _client.get(EndpointsApi.tableauDeBord);
}
