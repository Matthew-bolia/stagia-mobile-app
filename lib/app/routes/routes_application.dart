import 'package:flutter/material.dart';
import '../../features/authentication/presentation/pages/connexion_page.dart';
import '../../features/demarrage/presentation/pages/ecran_demarrage.dart';
import '../navigation/main_shell.dart';

abstract final class RoutesApplication {
  static const demarrage = '/';
  static const connexion = '/connexion';
  static const tableauDeBord = '/tableau-de-bord';

  static Route<dynamic> generer(RouteSettings parametres) {
    final Widget page = switch (parametres.name) {
      connexion => const ConnexionPage(),
      tableauDeBord => const MainShell(),
      _ => const EcranDemarrage(),
    };

    return MaterialPageRoute<dynamic>(
      builder: (_) => page,
      settings: parametres,
    );
  }
}
