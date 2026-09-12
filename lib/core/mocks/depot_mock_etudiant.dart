import 'package:flutter/foundation.dart';

// Stockage temporaire en mémoire pendant l'indisponibilité du backend.
// Les données sont conservées jusqu'à la fermeture complète de l'application.
abstract final class DepotMockEtudiant {
  static final ValueNotifier<int> changements = ValueNotifier<int>(0);
  static bool _campagnesConsultees = false;
  static final List<Map<String, dynamic>> _candidatures = [];
  static final List<Map<String, dynamic>> _journal = [];

  static List<Map<String, dynamic>> get candidatures =>
      _candidatures.map(Map<String, dynamic>.from).toList();

  static List<Map<String, dynamic>> get journal =>
      _journal.map(Map<String, dynamic>.from).toList();

  static bool get campagnesConsultees => _campagnesConsultees;

  static void marquerCampagnesConsultees() {
    if (_campagnesConsultees) return;
    _campagnesConsultees = true;
    changements.value++;
  }

  static List<Map<String, dynamic>> get documents => _candidatures
      .where((candidature) => candidature['document_name'] != null)
      .map(
        (candidature) => <String, dynamic>{
          'uuid': 'document-${candidature['uuid']}',
          'reference': candidature['document_name'],
          'type_document': _extensionDocument(candidature['document_name']),
          'status': 'DISPONIBLE',
          'local_path': candidature['document_path'],
        },
      )
      .toList();

  static bool candidatureEnvoyeePour(String cleOption) =>
      cleOption.isNotEmpty &&
      _candidatures.any(
        (candidature) => candidature['option_key'] == cleOption,
      );

  static Map<String, dynamic> ajouterCandidature({
    required String cleOption,
    required String campagneId,
    required String campagne,
    required String etablissement,
    required String localisation,
    required String motivation,
    String? document,
    String? cheminDocument,
  }) {
    final candidature = <String, dynamic>{
      'uuid': 'candidature-locale-${DateTime.now().millisecondsSinceEpoch}',
      'campaign_id': campagneId,
      'option_key': cleOption,
      'statut': 'SOUMISE',
      'submitted_at': DateTime.now().toIso8601String(),
      'campaign_title': campagne,
      'hospital_name': etablissement,
      'ville': localisation,
      'province': 'Kinshasa',
      'motivation': motivation,
      'document_name': document,
      'document_path': cheminDocument,
    };
    _candidatures.insert(0, candidature);
    changements.value++;
    return Map<String, dynamic>.from(candidature);
  }

  static void ajouterActivite({
    required String titre,
    required String description,
    required String difficulte,
    required String date,
    required String categorie,
    required String duree,
    required String service,
    required String competences,
    required String objectif,
    required String resultats,
  }) {
    _journal.insert(0, <String, dynamic>{
      'uuid': 'journal-local-${DateTime.now().millisecondsSinceEpoch}',
      'date': date,
      'created_at': DateTime.now().toIso8601String(),
      'status': 'BROUILLON',
      'summary': description,
      'learning': titre,
      'difficulties': difficulte,
      'duration': duree,
      'skills': competences,
      'campaign': {'title': 'Stage professionnel 2026-2027'},
      'hospital': {'name': 'Cliniques Universitaires de Kinshasa'},
      'unit': {'name': service},
      'activities': [
        {'category': categorie, 'involvement_level': 'REALISE', 'quantity': 1},
      ],
    });
  }

  static void modifierActivite(
    String uuid, {
    required String titre,
    required String description,
    required String difficulte,
    required String date,
    required String categorie,
    required String duree,
    required String service,
    required String objectifs,
    required String competences,
    required String resultats,
  }) {
    final index = _journal.indexWhere((element) => element['uuid'] == uuid);
    if (index < 0 || _journal[index]['status'] != 'BROUILLON') return;
    _journal[index] = {
      ..._journal[index],
      'date': date,
      'summary': description,
      'learning': titre,
      'difficulties': difficulte,
      'duration': duree,
      'objectives': objectifs,
      'skills': competences,
      'results': resultats,
      'unit': {'name': service},
      'activities': [
        {'category': categorie, 'involvement_level': 'REALISE', 'quantity': 1},
      ],
    };
  }

  static void supprimerActivite(String uuid) {
    _journal.removeWhere(
      (element) => element['uuid'] == uuid && element['status'] == 'BROUILLON',
    );
  }

  static void soumettreActivite(String uuid) {
    final index = _journal.indexWhere((element) => element['uuid'] == uuid);
    if (index >= 0 && _journal[index]['status'] == 'BROUILLON') {
      _journal[index]['status'] = 'SOUMIS';
    }
  }
}

String _extensionDocument(Object? nom) {
  final valeur = nom?.toString() ?? '';
  final morceaux = valeur.split('.');
  return morceaux.length > 1 ? morceaux.last.toUpperCase() : 'DOCUMENT';
}
