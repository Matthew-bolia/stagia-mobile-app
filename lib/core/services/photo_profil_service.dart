import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhotoProfilService extends ChangeNotifier {
  PhotoProfilService._() { _charger(); }
  static final instance = PhotoProfilService._();
  static const _clePhoto = 'chemin_photo_profil';
  String? _cheminPhoto;
  String? get cheminPhoto => _cheminPhoto;

  Future<void> definirPhoto(String chemin) async {
    _cheminPhoto = chemin;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_clePhoto, chemin);
  }

  Future<void> _charger() async {
    final preferences = await SharedPreferences.getInstance();
    _cheminPhoto = preferences.getString(_clePhoto);
    notifyListeners();
  }
}
