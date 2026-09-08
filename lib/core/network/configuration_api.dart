abstract final class ConfigurationApi {
  static const utiliserAuthentificationApi =
      false; // ce code me permet d'utiliser l'authentification
  static const utiliserDonneesMockees =
      true; // avec son endpoint ou de mocker les données pour le développement

  static const urlBase = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://camping-overwrite-upstate.ngrok-free.dev',
  );

  static const dureeExpiration = Duration(seconds: 30);
}
