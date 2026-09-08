import 'package:flutter/material.dart';
import '../routes/routes_stage.dart';

enum OngletStage { postuler, candidatures, mesStages }

class OngletsStage extends StatelessWidget {
  const OngletsStage({required this.ongletActif, super.key});

  final OngletStage ongletActif;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Onglet(
          libelle: 'Postuler',
          actif: ongletActif == OngletStage.postuler,
          onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
            RoutesStage.accueil,
            (route) => false,
          ),
        ),
        _Onglet(
          libelle: 'Candidatures',
          actif: ongletActif == OngletStage.candidatures,
          onTap: () => Navigator.of(context).pushReplacementNamed(RoutesStage.candidatures),
        ),
        _Onglet(
          libelle: 'Stages',
          actif: ongletActif == OngletStage.mesStages,
          onTap: () =>
              Navigator.of(context).pushReplacementNamed(RoutesStage.monStage),
        ),
      ],
    );
  }
}

class _Onglet extends StatelessWidget {
  const _Onglet({
    required this.libelle,
    required this.actif,
    required this.onTap,
  });

  final String libelle;
  final bool actif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: actif ? null : onTap,
        child: Column(
          children: [
            Text(
              libelle,
              style: TextStyle(
                color: actif
                    ? const Color(0xFFE85D00)
                    : const Color(0xFF718096),
                fontWeight: actif ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
            const SizedBox(height: 9),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: actif ? 3 : 2,
              color: actif ? const Color(0xFFFF7417) : const Color(0xFFE1E6ED),
            ),
          ],
        ),
      ),
    );
  }
}
