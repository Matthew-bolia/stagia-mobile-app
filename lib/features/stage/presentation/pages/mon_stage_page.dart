import 'package:alert_info/alert_info.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import '../../../../core/network/client_api_http.dart';
import '../../../../core/network/reponse_api.dart';
import '../../../../core/network/source_etudiant_distante.dart';
import '../../../../core/network/telechargeur_document_api.dart';
import '../../../../core/widgets/contenu_adaptatif.dart';
import '../../../../core/widgets/erreur_chargement_api.dart';
import '../widgets/onglets_stage.dart';
import 'suivi_formation_pages.dart';

class MonStagePage extends StatefulWidget {
  const MonStagePage({super.key});
  @override
  State<MonStagePage> createState() => _MonStagePageState();
}

class _MonStagePageState extends State<MonStagePage> {
  final _source = SourceEtudiantDistante(ClientApiHttp());
  final _telechargeur = const TelechargeurDocumentApi();
  late Future<List<Map<String, dynamic>>> _chargement;
  String? _documentEnCours;

  @override
  void initState() {
    super.initState();
    _chargement = _charger();
  }

  Future<List<Map<String, dynamic>>> _charger() =>
      Future.wait([_source.stages(), _source.documents()]);

  Future<void> _actualiser() async {
    final futur = _charger();
    setState(() => _chargement = futur);
    await futur;
  }

  Future<void> _ouvrirDocument(Map<String, dynamic> document) async {
    final endpoint = document['pdf_endpoint']?.toString();
    final cheminLocal = document['local_path']?.toString();
    if ((endpoint == null || endpoint.isEmpty) &&
        (cheminLocal == null || cheminLocal.isEmpty)) {
      AlertInfo.show(
        context: context,
        text: 'Ce document ne possède aucun fichier accessible.',
        typeInfo: TypeInfo.warning,
      );
      return;
    }
    setState(() => _documentEnCours = document['uuid']?.toString());
    try {
      final chemin = cheminLocal != null && cheminLocal.isNotEmpty
          ? cheminLocal
          : await _telechargeur.telechargerPdf(
              endpoint: endpoint!,
              nom: document['reference']?.toString() ?? 'document-stagia',
            );
      final resultat = await OpenFilex.open(chemin);
      if (!mounted || resultat.type == ResultType.done) return;
      throw ErreurApi(code: 'OUVERTURE_IMPOSSIBLE', message: resultat.message);
    } on ErreurApi catch (erreur) {
      if (!mounted) return;
      AlertInfo.show(
        context: context,
        text: erreur.message,
        typeInfo: TypeInfo.error,
      );
    } finally {
      if (mounted) setState(() => _documentEnCours = null);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(44),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: OngletsStage(ongletActif: OngletStage.mesStages),
        ),
      ),
    ),
    body: ContenuAdaptatif(
      enfant: FutureBuilder<List<Map<String, dynamic>>>(
        future: _chargement,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF7417)),
            );
          }
          if (snapshot.hasError) {
            return ErreurChargementApi(
              erreur: snapshot.error,
              onReessayer: _actualiser,
            );
          }
          final reponses = snapshot.data!;
          final stages = _items(reponses[0]['items']);
          final documents = _items(reponses[1]['items']);
          return _ContenuStage(
            stage: stages.isEmpty ? null : stages.first,
            documents: documents,
            documentEnCours: _documentEnCours,
            onDocument: _ouvrirDocument,
            onRefresh: _actualiser,
          );
        },
      ),
    ),
  );
}

class _ContenuStage extends StatelessWidget {
  const _ContenuStage({
    required this.stage,
    required this.documents,
    required this.documentEnCours,
    required this.onDocument,
    required this.onRefresh,
  });
  final Map<String, dynamic>? stage;
  final List<Map<String, dynamic>> documents;
  final String? documentEnCours;
  final ValueChanged<Map<String, dynamic>> onDocument;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final marge = MediaQuery.sizeOf(context).width < 360 ? 14.0 : 18.0;
    final rotations = _rotationsDuStage(stage);
    return RefreshIndicator(
      color: const Color(0xFFFF7417),
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(marge, 12, marge, 28),
        children: [
          _CarteRubriqueStage(
            titre: 'Mon stage',
            enfants: [
              if (stage == null)
                const _Vide('Aucun stage affecté.')
              else ...[
                const _TitreSection(
                  titre: 'Stage actuel',
                  description: 'Affectation et informations administratives',
                ),
                const SizedBox(height: 12),
                _BlocFiche(
                  lignes: [
                    _DonneeFiche(
                      'Statut',
                      '${stage!['workflow_status'] ?? stage!['statut'] ?? '-'}',
                    ),
                    _DonneeFiche(
                      'Établissement',
                      '${stage!['hospital_name'] ?? '-'}',
                    ),
                    _DonneeFiche(
                      'Campagne',
                      '${stage!['campaign_title'] ?? '-'}',
                    ),
                    _DonneeFiche(
                      'Groupe',
                      '${stage!['group_name'] ?? stage!['groupe'] ?? '-'}',
                    ),
                    _DonneeFiche(
                      'Période',
                      '${stage!['date_debut'] ?? '-'} au ${stage!['date_fin'] ?? '-'}',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const _TitreSection(
                  titre: 'Services et rotations',
                  description: 'Parcours publié pour ce stage',
                ),
                const SizedBox(height: 12),
                if (rotations.isEmpty)
                  const _Vide('Aucun parcours de rotation publié.')
                else
                  for (var index = 0; index < rotations.length; index++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CarteServiceRotation(
                        rotation: rotations[index],
                        numero: index + 1,
                      ),
                    ),
              ],
            ],
          ),
          const SizedBox(height: 22),
          _CarteRubriqueStage(
            titre: 'Formation et accompagnement',
            enfants: [_AccesFormation(stage: stage)],
          ),
          const SizedBox(height: 22),
          _CarteRubriqueStage(
            titre: 'Documents du stage',
            enfants: [
              if (documents.isEmpty)
                const _Vide('Aucun document disponible.')
              else
                for (final document in documents)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _CarteDocument(
                      document: document,
                      chargement:
                          documentEnCours == document['uuid']?.toString(),
                      onOuvrir: () => onDocument(document),
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CarteRubriqueStage extends StatelessWidget {
  const _CarteRubriqueStage({required this.titre, required this.enfants});
  final String titre;
  final List<Widget> enfants;

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: couleurs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: couleurs.onSurface.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            titre,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          ...enfants,
        ],
      ),
    );
  }
}

class _AccesFormation extends StatelessWidget {
  const _AccesFormation({required this.stage});
  final Map<String, dynamic>? stage;

  @override
  Widget build(BuildContext context) {
    final nom = stage?['campaign_title']?.toString() ?? 'Mon stage';
    final pages = <(String, String, Widget)>[
      (
        'Plan de formation',
        'Le programme par semaine ou par mois',
        PlanFormationPage(stage: nom),
      ),
      (
        'Planning de rotation',
        'Les horaires et les tâches prévues',
        PlanningRotationPage(stage: nom),
      ),
      (
        'Tâches assignées',
        'Les consignes et le suivi de vos travaux',
        TachesFormationPage(stage: nom),
      ),
      (
        'Feedback de superviseur',
        'Les observations et les recommandations',
        RetoursSuperviseurPage(stage: nom),
      ),
    ];
    final couleurs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (stage == null)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Vous pouvez consulter ces rubriques. Leur contenu sera disponible après votre affectation et sa publication par le responsable.',
            ),
          ),
        for (final page in pages)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: couleurs.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: couleurs.onSurface.withValues(alpha: .35),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.of(
                  context,
                  rootNavigator: true,
                ).push(MaterialPageRoute<void>(builder: (_) => page.$3)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        page.$1,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: couleurs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        page.$2,
                        style: TextStyle(color: couleurs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Consulter',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CarteServiceRotation extends StatelessWidget {
  const _CarteServiceRotation({required this.rotation, required this.numero});

  final Map<String, dynamic> rotation;
  final int numero;

  @override
  Widget build(BuildContext context) {
    final service =
        rotation['service_name'] ??
        rotation['unit_name'] ??
        rotation['service'] ??
        'Service $numero';
    final superviseur =
        rotation['supervisor_name'] ??
        rotation['superviseur_name'] ??
        rotation['superviseur'] ??
        '-';
    final debut = rotation['date_debut'] ?? rotation['start_date'] ?? '-';
    final fin = rotation['date_fin'] ?? rotation['end_date'] ?? '-';
    final statut =
        rotation['workflow_status'] ?? rotation['statut'] ?? 'PLANIFIÉE';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.toString(),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          _LigneService(libelle: 'Superviseur', valeur: superviseur.toString()),
          const SizedBox(height: 9),
          _LigneService(libelle: 'Période', valeur: '$debut au $fin'),
          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: .45),
          ),
          const SizedBox(height: 12),
          _LigneService(
            libelle: 'Rotation $numero',
            valeur: statut.toString(),
            valeurEnEvidence: true,
          ),
        ],
      ),
    );
  }
}

class _LigneService extends StatelessWidget {
  const _LigneService({
    required this.libelle,
    required this.valeur,
    this.valeurEnEvidence = false,
  });

  final String libelle;
  final String valeur;
  final bool valeurEnEvidence;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 104,
        child: Text(
          libelle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          valeur,
          style: TextStyle(
            fontWeight: valeurEnEvidence ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}

class _TitreSection extends StatelessWidget {
  const _TitreSection({required this.titre, required this.description});
  final String titre;
  final String description;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        titre,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 3),
      Text(
        description,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ],
  );
}

class _BlocFiche extends StatelessWidget {
  const _BlocFiche({required this.lignes});
  final List<_DonneeFiche> lignes;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .45),
      ),
    ),
    child: Column(
      children: List.generate(
        lignes.length,
        (index) => Column(
          children: [
            _LigneFiche(donnee: lignes[index]),
            if (index < lignes.length - 1)
              Divider(
                height: 1,
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: .45),
              ),
          ],
        ),
      ),
    ),
  );
}

class _LigneFiche extends StatelessWidget {
  const _LigneFiche({required this.donnee});
  final _DonneeFiche donnee;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 118,
          child: Text(
            donnee.libelle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            donnee.valeur,
            textAlign: TextAlign.left,
            style: const TextStyle(fontWeight: FontWeight.w800, height: 1.35),
          ),
        ),
      ],
    ),
  );
}

class _DonneeFiche {
  const _DonneeFiche(this.libelle, this.valeur);
  final String libelle;
  final String valeur;
}

class _CarteDocument extends StatelessWidget {
  const _CarteDocument({
    required this.document,
    required this.chargement,
    required this.onOuvrir,
  });
  final Map<String, dynamic> document;
  final bool chargement;
  final VoidCallback onOuvrir;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .45),
      ),
    ),
    child: Row(
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 54),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${document['type_document'] ?? 'DOC'}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                document['reference']?.toString() ?? 'Document',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 3),
              Text(
                '${document['status'] ?? 'Disponible'}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        chargement
            ? const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : TextButton(onPressed: onOuvrir, child: const Text('Ouvrir')),
      ],
    ),
  );
}

class _Vide extends StatelessWidget {
  const _Vide(this.texte);
  final String texte;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF242424)
          : Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(17),
    ),
    child: Text(texte, textAlign: TextAlign.center),
  );
}

List<Map<String, dynamic>> _items(Object? valeur) => valeur is List
    ? valeur.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : <Map<String, dynamic>>[];

List<Map<String, dynamic>> _rotationsDuStage(Map<String, dynamic>? stage) {
  if (stage == null) return const [];
  final parcours = stage['parcours'];
  final rotations =
      stage['rotations'] ??
      stage['rotation_items'] ??
      (parcours is Map ? parcours['rotations'] : null);
  return _items(rotations);
}
