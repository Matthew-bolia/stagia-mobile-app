import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stagia/app/app.dart';

void main() {
  testWidgets('affiche le démarrage puis les quatre destinations', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'onboarding_termine': true});
    await tester.pumpWidget(const StagiaApp());

    expect(find.bySemanticsLabel('Logo STAGIA'), findsOneWidget);

    await tester.pump(const Duration(seconds: 8));
    await tester.pumpAndSettle();

    expect(find.text('Accueil'), findsAtLeastNWidgets(1));
    expect(find.text('Stages'), findsOneWidget);
    expect(find.text('Journal'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });
}
