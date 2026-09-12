import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageLocal {
  MessageLocal({
    required this.type,
    required this.texte,
    required this.date,
    this.chemin,
  });
  final String type, texte;
  final DateTime date;
  final String? chemin;
  Map<String, dynamic> toJson() => {
    'type': type,
    'texte': texte,
    'date': date.toIso8601String(),
    'chemin': chemin,
  };
  factory MessageLocal.fromJson(Map<String, dynamic> j) => MessageLocal(
    type: j['type'] as String,
    texte: j['texte'] as String,
    date: DateTime.parse(j['date'] as String),
    chemin: j['chemin'] as String?,
  );
}

class DiscussionLocale {
  DiscussionLocale({
    required this.id,
    required this.titre,
    this.objet = '',
    this.destinataireNom = '',
    this.destinataireRole = '',
    List<MessageLocal>? messages,
  }) : messages = messages ?? [];
  final String id, titre, objet, destinataireNom, destinataireRole;
  final List<MessageLocal> messages;
  Map<String, dynamic> toJson() => {
    'id': id,
    'titre': titre,
    'objet': objet,
    'destinataire_nom': destinataireNom,
    'destinataire_role': destinataireRole,
    'messages': messages.map((m) => m.toJson()).toList(),
  };
  factory DiscussionLocale.fromJson(Map<String, dynamic> j) => DiscussionLocale(
    id: j['id'] as String,
    titre: j['titre'] as String,
    objet: j['objet']?.toString() ?? '',
    destinataireNom: j['destinataire_nom']?.toString() ?? '',
    destinataireRole: j['destinataire_role']?.toString() ?? '',
    messages: (j['messages'] as List)
        .map((m) => MessageLocal.fromJson(Map<String, dynamic>.from(m as Map)))
        .toList(),
  );
}

class PreferencesMessagerieLocale {
  const PreferencesMessagerieLocale({
    this.parEmail = true,
    this.parSms = false,
    this.parPush = false,
  });

  final bool parEmail;
  final bool parSms;
  final bool parPush;

  PreferencesMessagerieLocale copyWith({
    bool? parEmail,
    bool? parSms,
    bool? parPush,
  }) => PreferencesMessagerieLocale(
    parEmail: parEmail ?? this.parEmail,
    parSms: parSms ?? this.parSms,
    parPush: parPush ?? this.parPush,
  );

  Map<String, dynamic> toJson() => {'par_email': parEmail, 'par_sms': parSms};

  factory PreferencesMessagerieLocale.fromJson(Map<String, dynamic> json) =>
      PreferencesMessagerieLocale(
        parEmail: json['par_email'] == true,
        parSms: json['par_sms'] == true,
        parPush: json['par_push'] == true,
      );
}

// Stockage propre à l'étudiant. Aucun échange réseau n'est effectué.
class MessagerieLocale {
  MessagerieLocale(this.compte);
  final String compte;
  String get _cle =>
      'messagerie_locale_v1_${base64Url.encode(utf8.encode(compte))}';
  String get _clePreferences =>
      'preferences_messagerie_locale_v1_${base64Url.encode(utf8.encode(compte))}';
  Future<List<DiscussionLocale>> charger() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cle);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map(
          (d) => DiscussionLocale.fromJson(Map<String, dynamic>.from(d as Map)),
        )
        .toList();
  }

  Future<void> enregistrer(List<DiscussionLocale> discussions) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(
      _cle,
      jsonEncode(discussions.map((d) => d.toJson()).toList()),
    )) {
      throw const FileSystemException('Enregistrement impossible');
    }
  }

  Future<PreferencesMessagerieLocale> chargerPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_clePreferences);
    if (raw == null) return const PreferencesMessagerieLocale();
    return PreferencesMessagerieLocale.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  Future<void> enregistrerPreferences(
    PreferencesMessagerieLocale preferences,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(
      _clePreferences,
      jsonEncode(preferences.toJson()),
    )) {
      throw const FileSystemException(
        'Enregistrement des préférences impossible',
      );
    }
  }

  Future<String> copier(String source) async {
    final dossier = await getApplicationDocumentsDirectory();
    final destination = Directory('${dossier.path}/messagerie/$_cle');
    await destination.create(recursive: true);
    final extension = source
        .split('.')
        .last
        .replaceAll(RegExp('[^a-zA-Z0-9]'), '');
    final fichier = await File(source).copy(
      '${destination.path}/${DateTime.now().microsecondsSinceEpoch}.$extension',
    );
    return fichier.path;
  }
}
