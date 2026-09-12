import 'package:flutter/material.dart';
import '../../../../core/widgets/contenu_adaptatif.dart';

/// Modèles de présentation : le futur adaptateur API fournira ces données.
/// Aucune publication ou validation n'est simulée par ces interfaces.
class PeriodeFormation {
  const PeriodeFormation({required this.periode, required this.programme});
  final String periode;
  final String programme;
}

class SeanceRotation {
  const SeanceRotation({
    required this.debut,
    required this.fin,
    required this.service,
    required this.taches,
    this.responsable,
  });
  final DateTime debut;
  final DateTime fin;
  final String service;
  final String taches;
  final String? responsable;
}

class TacheFormation {
  const TacheFormation({
    required this.titre,
    required this.consignes,
    required this.avancement,
    required this.verification,
    this.superviseur,
    this.service,
    this.echeance,
  });
  final String titre;
  final String consignes;
  final String avancement;
  final String verification;
  final String? superviseur;
  final String? service;
  final DateTime? echeance;
}

class RetourSuperviseur {
  const RetourSuperviseur({
    required this.auteur,
    required this.date,
    required this.objet,
    required this.commentaire,
    this.recommandations,
  });
  final String auteur;
  final DateTime date;
  final String objet;
  final String commentaire;
  final String? recommandations;
}

class PlanFormationPage extends StatelessWidget {
  const PlanFormationPage({
    required this.stage,
    this.periodes = const [],
    super.key,
  });
  final String stage;
  final List<PeriodeFormation> periodes;

  @override
  Widget build(BuildContext context) => _PageSuivi(
    titre: 'Plan de formation',
    stage: stage,
    description:
        'Le programme prévu pendant votre période de stage, publié par votre responsable.',
    vide: 'Aucun plan de formation publié',
    precisionVide:
        'Les étapes de votre formation apparaîtront ici, par semaine ou par mois.',
    enfants: [
      for (final periode in periodes)
        _Bloc(
          titre: periode.periode,
          enfants: [
            Text(periode.programme, style: const TextStyle(height: 1.6)),
          ],
        ),
    ],
  );
}

class PlanningRotationPage extends StatelessWidget {
  const PlanningRotationPage({
    required this.stage,
    this.seances = const [],
    super.key,
  });
  final String stage;
  final List<SeanceRotation> seances;

  @override
  Widget build(BuildContext context) {
    final ordre = [...seances]..sort((a, b) => a.debut.compareTo(b.debut));
    return _PageSuivi(
      titre: 'Planning de rotation',
      stage: stage,
      description:
          'Vos horaires et les tâches prévues, dans l’ordre chronologique.',
      vide: 'Aucun planning publié',
      precisionVide:
          'Votre responsable fixe les dates, les horaires et les activités de chaque service.',
      enfants: [
        for (final seance in ordre)
          _Bloc(
            titre: _date(seance.debut),
            enfants: [
              _Valeur(
                'Horaire',
                '${_heure(seance.debut)} – ${_heure(seance.fin)}',
              ),
              _Valeur('Service', seance.service),
              if (seance.responsable != null)
                _Valeur('Responsable', seance.responsable!),
              _Valeur('Tâches prévues', seance.taches),
            ],
          ),
      ],
    );
  }
}

class TachesFormationPage extends StatelessWidget {
  const TachesFormationPage({
    required this.stage,
    this.taches = const [],
    super.key,
  });
  final String stage;
  final List<TacheFormation> taches;

  @override
  Widget build(BuildContext context) => _PageSuivi(
    titre: 'Tâches assignées',
    stage: stage,
    description:
        'Les travaux confiés par votre superviseur et leur état de vérification.',
    vide: 'Aucune tâche assignée',
    precisionVide:
        'Vous retrouverez ici les consignes et les échéances des travaux qui vous sont attribués.',
    enfants: [
      for (final tache in taches)
        _Bloc(
          titre: tache.titre,
          enfants: [
            _Valeur('Avancement', tache.avancement),
            _Valeur('Vérification', tache.verification),
            if (tache.echeance != null)
              _Valeur('Échéance', _date(tache.echeance!)),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _PageSuivi(
                      titre: 'Détail de la tâche',
                      stage: stage,
                      description: tache.titre,
                      vide: '',
                      precisionVide: '',
                      enfants: [
                        _Bloc(
                          titre: 'Consignes',
                          enfants: [Text(tache.consignes)],
                        ),
                        _Bloc(
                          titre: 'Suivi du travail',
                          enfants: [
                            if (tache.superviseur != null)
                              _Valeur('Superviseur', tache.superviseur!),
                            if (tache.service != null)
                              _Valeur('Service', tache.service!),
                            if (tache.echeance != null)
                              _Valeur('Échéance', _date(tache.echeance!)),
                            _Valeur('Avancement', tache.avancement),
                            _Valeur('Vérification', tache.verification),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                child: const Text('Voir les consignes'),
              ),
            ),
          ],
        ),
    ],
  );
}

class RetoursSuperviseurPage extends StatelessWidget {
  const RetoursSuperviseurPage({
    required this.stage,
    this.retours = const [],
    super.key,
  });
  final String stage;
  final List<RetourSuperviseur> retours;

  @override
  Widget build(BuildContext context) {
    final ordre = [...retours]..sort((a, b) => b.date.compareTo(a.date));
    return _PageSuivi(
      titre: 'Feedback de superviseur',
      stage: stage,
      description:
          'Les observations et les recommandations pour votre progression.',
      vide: 'Aucun retour publié',
      precisionVide:
          'Les commentaires de votre superviseur sur vos travaux apparaîtront ici.',
      enfants: [
        for (final retour in ordre)
          _Bloc(
            titre: retour.objet,
            enfants: [
              _Valeur('Superviseur', retour.auteur),
              _Valeur('Date', '${_date(retour.date)} à ${_heure(retour.date)}'),
              _Valeur('Observation', retour.commentaire),
              if (retour.recommandations != null)
                _Valeur('Recommandations', retour.recommandations!),
            ],
          ),
      ],
    );
  }
}

class _PageSuivi extends StatelessWidget {
  const _PageSuivi({
    required this.titre,
    required this.stage,
    required this.description,
    required this.vide,
    required this.precisionVide,
    required this.enfants,
  });
  final String titre, stage, description, vide, precisionVide;
  final List<Widget> enfants;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 85,
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Retour'),
        ),
        title: Text(titre, style: const TextStyle(fontSize: 17)),
      ),
      body: ContenuAdaptatif(
        largeurMaximale: 680,
        enfant: ListView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
          children: [
            Text(
              description,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            if (enfants.isEmpty)
              _Bloc(
                titre: vide,
                enfants: [
                  Text(precisionVide, style: const TextStyle(height: 1.5)),
                ],
              )
            else
              ...enfants,
          ],
        ),
      ),
    );
  }
}

class _Bloc extends StatelessWidget {
  const _Bloc({required this.titre, required this.enfants});
  final String titre;
  final List<Widget> enfants;
  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: couleurs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: couleurs.onSurface.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titre,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...enfants,
        ],
      ),
    );
  }
}

class _Valeur extends StatelessWidget {
  const _Valeur(this.libelle, this.valeur);
  final String libelle, valeur;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          libelle,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          valeur,
          style: const TextStyle(height: 1.5, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}

String _date(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
String _heure(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
