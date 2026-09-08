// Contrat réseau utilisé par toutes les sources distantes.
// L'implémentation HTTP sera ajoutée lorsque l'API déployée sera disponible.
abstract interface class ClientApi {
  Future<Map<String, dynamic>> get(
    String chemin, {
    Map<String, dynamic>? parametres,
  });

  Future<Map<String, dynamic>> post(
    String chemin, {
    Object? corps,
    Map<String, String>? entetes,
  });

  Future<Map<String, dynamic>> patch(String chemin, {Object? corps});
  Future<Map<String, dynamic>> delete(String chemin);

  Future<Map<String, dynamic>> envoyerFichier(
    String chemin, {
    required String cheminFichier,
    required Map<String, String> champs,
  });
}
