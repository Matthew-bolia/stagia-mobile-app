import 'package:flutter/material.dart';

import '../../../../core/widgets/contenu_adaptatif.dart';
import '../../data/models/etudiant_profil.dart';

class ParcoursAcademiquePage extends StatelessWidget {
  const ParcoursAcademiquePage({required this.profil, super.key});

  final EtudiantProfil profil;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Parcours académique')),
    body: ContenuAdaptatif(
      largeurMaximale: 640,
      enfant: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Inscription actuelle',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          _FicheAcademique(
            donnees: [
              ('Université', profil.etablissement),
              ('Faculté', profil.faculte),
              ('Département ou filière', profil.filiere),
              ('Option', profil.option),
              ('Promotion ou niveau', profil.niveau),
              ('Année académique', profil.anneeAcademique),
              ('Matricule', profil.matricule),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Historique académique',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          const _EtatVide(
            'Aucun autre parcours académique n’est disponible.',
          ),
        ],
      ),
    ),
  );
}

class _FicheAcademique extends StatelessWidget {
  const _FicheAcademique({required this.donnees});
  final List<(String, String)> donnees;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Column(
      children: List.generate(donnees.length, (index) {
        final donnee = donnees[index];
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 145,
                    child: Text(
                      donnee.$1,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      donnee.$2.isEmpty ? 'Non renseigné' : donnee.$2,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            if (index < donnees.length - 1)
              Divider(
                height: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
          ],
        );
      }),
    ),
  );
}

class _EtatVide extends StatelessWidget {
  const _EtatVide(this.texte);
  final String texte;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Text(texte, textAlign: TextAlign.center),
  );
}
