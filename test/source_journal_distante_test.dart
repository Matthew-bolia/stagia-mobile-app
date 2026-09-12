import 'package:flutter_test/flutter_test.dart';
import 'package:stagia/core/network/client_api.dart';
import 'package:stagia/core/network/endpoints_api.dart';
import 'package:stagia/features/journal/data/datasources/source_journal_distante.dart';

class FakeClientApi implements ClientApi {
  String? chemin;
  Object? corps;
  Map<String, String>? entetes;

  @override
  Future<Map<String, dynamic>> get(
    String chemin, {
    Map<String, dynamic>? parametres,
  }) async => <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> post(
    String chemin, {
    Object? corps,
    Map<String, String>? entetes,
  }) async {
    this.chemin = chemin;
    this.corps = corps;
    this.entetes = entetes;
    return <String, dynamic>{'success': true, 'data': <String, dynamic>{}};
  }

  @override
  Future<Map<String, dynamic>> patch(String chemin, {Object? corps}) async =>
      <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> delete(String chemin) async =>
      <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> envoyerFichier(
    String chemin, {
    required String cheminFichier,
    required Map<String, String> champs,
  }) async => <String, dynamic>{};
}

void main() {
  test('ajouterActivite envoie les champs du formulaire du journal', () async {
    final fakeClient = FakeClientApi();
    final source = SourceJournalDistante(fakeClient);

    await source.ajouterActivite(
      stageId: 'stage-1',
      affectationId: 'aff-1',
      date: '14-09-2026',
      titre: 'Observation',
      description: 'Travail réalisé',
      categorie: 'Urgence',
      duree: '4',
      service: 'Service d’urgence',
      objectifs: 'Comprendre le service',
      competences: 'Relationnel',
      resultats: 'Observation complète',
      difficultes: 'Aucune difficulté',
    );

    expect(fakeClient.chemin, EndpointsApi.ajouterActivite('stage-1'));
    expect(fakeClient.corps, isA<Map<String, dynamic>>());

    final corps = fakeClient.corps as Map<String, dynamic>;
    expect(corps['assignment_id'], 'aff-1');
    expect(corps['activity_date'], '14-09-2026');
    expect(corps['title'], 'Observation');
    expect(corps['description'], 'Travail réalisé');
    expect(corps['category'], 'Urgence');
    expect(corps['duration'], '4');
    expect(corps['service_unit'], 'Service d’urgence');
    expect(corps['objectives'], 'Comprendre le service');
    expect(corps['skills'], 'Relationnel');
    expect(corps['results'], 'Observation complète');
    expect(corps['difficulties'], 'Aucune difficulté');
  });
}
