import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesApplicationService extends ChangeNotifier {
  PreferencesApplicationService._() {
    _charger();
  }

  static final instance = PreferencesApplicationService._();
  static const _cleNotifications = 'notifications_autorisees';
  static const _cleModeSombre = 'mode_sombre';

  bool _notificationsAutorisees = true;
  bool _modeSombre = false;

  bool get notificationsAutorisees => _notificationsAutorisees;

  bool get modeSombre => _modeSombre;

  Future<void> autoriserNotifications(bool valeur) async {
    _notificationsAutorisees = valeur;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_cleNotifications, valeur);
  }

  Future<void> activerModeSombre(bool valeur) async {
    _modeSombre = valeur;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_cleModeSombre, valeur);
  }

  Future<void> _charger() async {
    final preferences = await SharedPreferences.getInstance();
    _notificationsAutorisees = preferences.getBool(_cleNotifications) ?? true;
    _modeSombre = preferences.getBool(_cleModeSombre) ?? false;
    notifyListeners();
  }
}
