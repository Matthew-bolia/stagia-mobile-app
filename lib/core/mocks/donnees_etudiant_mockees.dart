import '../network/endpoints_api.dart';
import 'depot_mock_etudiant.dart';

abstract final class DonneesEtudiantMockees {
  static Map<String, dynamic> pourEndpoint(String endpoint) {
    if (endpoint == EndpointsApi.tableauDeBordEtudiant) {
      return {
        ...tableauDeBord,
        'stats': {
          ...Map<String, dynamic>.from(tableauDeBord['stats'] as Map),
          'applications': DepotMockEtudiant.candidatures.length,
        },
      };
    }
    if (endpoint == EndpointsApi.candidaturesEtudiant) {
      final items = DepotMockEtudiant.candidatures;
      return {'items': items, 'total': items.length};
    }
    if (endpoint == EndpointsApi.journalEtudiant) {
      final items = DepotMockEtudiant.journal;
      return {
        'items': items,
        'stats': {'total': items.length},
      };
    }
    if (endpoint == EndpointsApi.documentsEtudiant) {
      final items = DepotMockEtudiant.documents;
      return {
        'items': items,
        'stats': {'total': items.length, 'available': items.length},
      };
    }
    return Map<String, dynamic>.from(switch (endpoint) {
      EndpointsApi.profilEtudiant => profil,
      EndpointsApi.optionsStageEtudiant => optionsStage,
      EndpointsApi.stagesEtudiant => stages,
      EndpointsApi.reservationsEtudiant => reservations,
      EndpointsApi.admissionEtudiant => admission,
      EndpointsApi.presencesEtudiant => presences,
      EndpointsApi.evaluationsEtudiant => evaluations,
      _ => <String, dynamic>{},
    });
  }

  static const profil = <String, dynamic>{
    'user': {
      'identifiant': 'STG-ETU-00000001',
      'nom': 'Bolia',
      'prenom': 'Matthew',
      'email': 'matthew@gmail.test',
      'actif': true,
      'role': {'code': 'STAGIAIRE', 'nom': 'Stagiaire'},
    },
    'student': {
      'stagia_code': 'STG-ETU-00000001',
      'nom': 'Bolia',
      'postnom': 'Bolia',
      'prenom': 'Matthew',
      'sexe': 'Masculin',
      'telephone': '+243 812 345 678',
      'province': 'Kinshasa',
      'university_name': 'Université de Kinshasa',
      'faculty_name': 'Faculté des sciences',
      'department_name': 'Informatique',
      'option_name': 'Génie logiciel',
      'promotion_name': 'Licence 3',
      'academic_year': '2026-2027',
      'statut': 'ACTIF',
    },
  };

  static const tableauDeBord = <String, dynamic>{
    'student': {
      'stagia_code': 'STG-ETU-00000001',
      'nom': 'Bolia',
      'postnom': 'Bolia',
      'prenom': 'Matthew',
      'email': 'matthew@gmail.test',
    },
    'stats': {
      'applications': 0,
      'active_reservations': 0,
      'stages': 0,
      'planned_stages': 0,
      'active_stages': 0,
      'completed_stages': 0,
      'validated_stages': 0,
      'documents': 0,
    },
    'current_stage': <String, dynamic>{},
  };

  static const optionsStage = <String, dynamic>{
    'campaigns': [
      {
        'code': 'CAM-STAGIA-001',
        'title': 'Campagne de stages professionnels 2026',
        'available_places': 9,
        'hospitals': [
          {
            'code': 'ENT-001',
            'name': 'Cliniques Universitaires de Kinshasa',
            'city': 'Lemba',
            'province': 'Kinshasa',
            'latitude': -4.3034,
            'longitude': 15.3124,
          },
          {
            'code': 'ENT-002',
            'name': 'Université de Kinshasa',
            'city': 'Lemba',
            'province': 'Kinshasa',
            'latitude': -4.3147,
            'longitude': 15.2902,
          },
          {
            'code': 'ENT-003',
            'name': 'Hôpital Général de Référence de Kinshasa',
            'city': 'Gombe',
            'province': 'Kinshasa',
            'latitude': -4.3502,
            'longitude': 15.3371,
          },
        ],
      },
      {
        'code': 'CAM-STAGIA-002',
        'title': 'Campagne académique 2026',
        'available_places': 4,
        'hospitals': [
          {
            'code': 'ENT-004',
            'name': 'Centre Hospitalier Monkole',
            'city': 'Mont-Ngafula',
            'province': 'Kinshasa',
            'latitude': -4.4137,
            'longitude': 15.2652,
          },
        ],
      },
    ],
    'stats': {
      'campaigns': 1,
      'hospitals': 3,
      'available_hospitals': 3,
      'available_places': 9,
    },
  };

  static const stages = <String, dynamic>{
    'items': <Map<String, dynamic>>[],
    'stats': {'total': 0, 'active': 0, 'completed': 0, 'validated': 0},
  };

  static const reservations = <String, dynamic>{
    'items': <Map<String, dynamic>>[],
  };

  static const admission = <String, dynamic>{
    'items': <Map<String, dynamic>>[],
  };

  static const documents = <String, dynamic>{
    'items': <Map<String, dynamic>>[],
    'stats': {'total': 0, 'available': 0},
  };

  static const presences = <String, dynamic>{
    'items': <Map<String, dynamic>>[],
    'stats': {'total': 0, 'present': 0, 'attendance_rate': 0},
  };

  static const journal = <String, dynamic>{
    'items': <Map<String, dynamic>>[],
    'stats': {'total': 0, 'validated': 0, 'activities': 0},
  };

  static const evaluations = <String, dynamic>{
    'items': <Map<String, dynamic>>[],
    'stats': {'total': 0, 'average': 0},
  };

}
