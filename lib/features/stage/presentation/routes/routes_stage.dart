import 'package:flutter/material.dart';
import '../pages/candidatures_stage_page.dart';
import '../pages/mon_stage_page.dart';
import '../pages/postuler_stage_page.dart';
import '../pages/parcours_candidature_page.dart';

abstract final class RoutesStage {
  static const accueil = '/';
  static const postuler = '/postuler';
  static const candidatures = '/candidatures';
  static const monStage = '/mon-stage';
  static const parcoursCandidature = '/parcours-candidature';

  static Route<dynamic> generer(RouteSettings parametres) {
    final Widget page = switch (parametres.name) {
      postuler => const PostulerStagePage(),
      candidatures => const CandidaturesStagePage(),
      monStage => const MonStagePage(),
      parcoursCandidature => ParcoursCandidaturePage(
          option: Map<String, dynamic>.from(parametres.arguments! as Map),
        ),
      _ => const PostulerStagePage(),
    };

    return MaterialPageRoute<dynamic>(builder: (_) => page);
  }
}
