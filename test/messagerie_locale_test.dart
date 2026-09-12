import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stagia/features/messagerie/data/messagerie_locale.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Boîte vide, sauvegarde durable et séparation des comptes', () async {
    final stockage = MessagerieLocale('etudiant-a');
    expect(await stockage.charger(), isEmpty);
    final date = DateTime(2026, 9, 10, 14, 30);
    await stockage.enregistrer([
      DiscussionLocale(id: '1', titre: 'Mes documents', messages: [
        MessageLocal(type: 'texte', texte: 'Mon message', date: date),
        MessageLocal(type: 'vocal', texte: 'Vocal', date: date, chemin: '/local/vocal.m4a'),
      ]),
    ]);
    final recharge = await MessagerieLocale('etudiant-a').charger();
    expect(recharge.single.titre, 'Mes documents');
    expect(recharge.single.messages.first.texte, 'Mon message');
    expect(recharge.single.messages.last.chemin, '/local/vocal.m4a');
    expect(recharge.single.messages.first.date, date);
    expect(await MessagerieLocale('etudiant-b').charger(), isEmpty);
  });
}
