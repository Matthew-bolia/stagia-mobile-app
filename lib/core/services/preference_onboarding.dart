import 'package:shared_preferences/shared_preferences.dart';

class PreferenceOnboarding {
  const PreferenceOnboarding();

  static const cleTerminee = 'onboarding_termine';
  static const afficherToujoursEnDeveloppement = true;

  Future<bool> estTerminee() async {
    if (afficherToujoursEnDeveloppement) return false;

    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(cleTerminee) ?? false;
  }

  Future<void> terminer() async {
    if (afficherToujoursEnDeveloppement) return;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(cleTerminee, true);
  }
}
