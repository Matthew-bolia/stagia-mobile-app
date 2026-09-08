import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentEtudiantLocal {
  const DocumentEtudiantLocal({
    required this.id,
    required this.nom,
    required this.categorie,
    required this.chemin,
    required this.taille,
    required this.ajouteLe,
    this.mediaId,
  });

  factory DocumentEtudiantLocal.fromJson(Map<String, dynamic> json) =>
      DocumentEtudiantLocal(
        id: json['id']?.toString() ?? '',
        nom: json['nom']?.toString() ?? 'Document',
        categorie: json['categorie']?.toString() ?? 'Autre',
        chemin: json['chemin']?.toString() ?? '',
        taille: json['taille'] as int? ?? 0,
        ajouteLe:
            DateTime.tryParse(json['ajoute_le']?.toString() ?? '') ??
            DateTime.now(),
        mediaId: json['media_id']?.toString(),
      );

  final String id;
  final String nom;
  final String categorie;
  final String chemin;
  final int taille;
  final DateTime ajouteLe;
  final String? mediaId;

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'categorie': categorie,
    'chemin': chemin,
    'taille': taille,
    'ajoute_le': ajouteLe.toIso8601String(),
    'media_id': mediaId,
  };
}

class DocumentsEtudiantService {
  DocumentsEtudiantService._();

  static const _cle = 'documents_etudiant_locaux_v1';

  static Future<List<DocumentEtudiantLocal>> charger() async {
    final preferences = await SharedPreferences.getInstance();
    final contenu = preferences.getString(_cle);
    if (contenu == null || contenu.isEmpty) return [];
    final liste = jsonDecode(contenu);
    if (liste is! List) return [];
    final documents = liste
        .whereType<Map>()
        .map(
          (item) =>
              DocumentEtudiantLocal.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
    final existants = <DocumentEtudiantLocal>[];
    for (final document in documents) {
      if (await File(document.chemin).exists()) existants.add(document);
    }
    if (existants.length != documents.length) await enregistrer(existants);
    return existants;
  }

  static Future<DocumentEtudiantLocal> importer({
    required String cheminSource,
    required String nom,
    required String categorie,
    String? mediaId,
  }) async {
    final source = File(cheminSource);
    if (!await source.exists()) {
      throw const FileSystemException(
        'Le fichier sélectionné est inaccessible.',
      );
    }
    final dossierApplication = await getApplicationDocumentsDirectory();
    final dossier = Directory('${dossierApplication.path}/documents_etudiant');
    if (!await dossier.exists()) await dossier.create(recursive: true);
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final extension = nom.contains('.') ? '.${nom.split('.').last}' : '';
    final destination = File('${dossier.path}/$id$extension');
    await source.copy(destination.path);
    return DocumentEtudiantLocal(
      id: id,
      nom: nom,
      categorie: categorie,
      chemin: destination.path,
      taille: await destination.length(),
      ajouteLe: DateTime.now(),
      mediaId: mediaId,
    );
  }

  static Future<void> enregistrer(List<DocumentEtudiantLocal> documents) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _cle,
      jsonEncode(documents.map((document) => document.toJson()).toList()),
    );
  }

  static Future<void> supprimer(DocumentEtudiantLocal document) async {
    final fichier = File(document.chemin);
    if (await fichier.exists()) await fichier.delete();
  }
}
