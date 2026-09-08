import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/network/client_api_http.dart';
import '../../../../core/network/source_etudiant_distante.dart';
import '../../../../core/widgets/contenu_adaptatif.dart';
import '../../../../core/widgets/erreur_chargement_api.dart';
import '../widgets/onglets_stage.dart';
import '../font_awesome_flutter_icons.dart';

enum FiltreCandidature { toutes, enCours, eligible, terminee }

class CandidaturesStagePage extends StatefulWidget {
  const CandidaturesStagePage({super.key});
  @override
  State<CandidaturesStagePage> createState() => _CandidaturesStagePageState();
}

class _CandidaturesStagePageState extends State<CandidaturesStagePage> {
  final _source = SourceEtudiantDistante(ClientApiHttp());
  late Future<Map<String, dynamic>> _chargement;
  FiltreCandidature _filtre = FiltreCandidature.toutes;

  @override
  void initState() {
    super.initState();
    _chargement = _source.candidatures();
  }

  Future<void> _actualiser() async {
    final futur = _source.candidatures();
    setState(() => _chargement = futur);
    await futur;
  }

  List<Map<String, dynamic>> _filtrer(List<Map<String, dynamic>> liste) =>
      liste.where((item) {
        final statut = item['statut']?.toString().toUpperCase() ?? '';
        return switch (_filtre) {
          FiltreCandidature.toutes => true,
          FiltreCandidature.enCours => [
            'SOUMISE',
            'EN_ATTENTE',
            'EN_COURS',
          ].contains(statut),
          FiltreCandidature.eligible => [
            'ELIGIBLE',
            'ACCEPTEE',
            'AFFECTEE',
          ].contains(statut),
          FiltreCandidature.terminee => [
            'TERMINEE',
            'REFUSEE',
            'ANNULEE',
          ].contains(statut),
        };
      }).toList();

  @override
  Widget build(BuildContext context) {
    final marge = MediaQuery.sizeOf(context).width < 360 ? 14.0 : 18.0;
    return Scaffold(
      appBar: const _AppBarCandidatures(),
      body: ContenuAdaptatif(
        enfant: FutureBuilder<Map<String, dynamic>>(
          future: _chargement,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF7417)),
              );
            }
            if (snapshot.hasError)
              return ErreurChargementApi(
                erreur: snapshot.error,
                onReessayer: _actualiser,
              );
            final items = _liste(snapshot.data?['items']);
            final visibles = _filtrer(items);
            return RefreshIndicator(
              color: const Color(0xFFFF7417),
              onRefresh: _actualiser,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(marge, 16, marge, 28),
                children: [
                  _Resume(items),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _Filtre(
                          'Toutes',
                          _filtre == FiltreCandidature.toutes,
                          () => setState(
                            () => _filtre = FiltreCandidature.toutes,
                          ),
                        ),
                        _Filtre(
                          'En cours',
                          _filtre == FiltreCandidature.enCours,
                          () => setState(
                            () => _filtre = FiltreCandidature.enCours,
                          ),
                        ),
                        _Filtre(
                          'Éligibles',
                          _filtre == FiltreCandidature.eligible,
                          () => setState(
                            () => _filtre = FiltreCandidature.eligible,
                          ),
                        ),
                        _Filtre(
                          'Terminées',
                          _filtre == FiltreCandidature.terminee,
                          () => setState(
                            () => _filtre = FiltreCandidature.terminee,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (visibles.isEmpty)
                    const _Vide()
                  else
                    for (final candidature in visibles)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CarteCandidature(candidature),
                      ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AppBarCandidatures extends StatelessWidget
    implements PreferredSizeWidget {
  const _AppBarCandidatures();
  @override
  Size get preferredSize => const Size.fromHeight(100);
  @override
  Widget build(BuildContext context) => AppBar(
    automaticallyImplyLeading: false,
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(44),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: OngletsStage(ongletActif: OngletStage.candidatures),
      ),
    ),
  );
}

class _Resume extends StatelessWidget {
  const _Resume(this.items);
  final List<Map<String, dynamic>> items;
  @override
  Widget build(BuildContext context) {
    int compter(List<String> statuts) => items
        .where((e) => statuts.contains(e['statut']?.toString().toUpperCase()))
        .length;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFF7417),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(child: _Nombre('${items.length}', 'Envoyées')),
          Expanded(
            child: _Nombre(
              '${compter(['ELIGIBLE', 'ACCEPTEE', 'AFFECTEE'])}',
              'Éligibles',
            ),
          ),
          Expanded(
            child: _Nombre(
              '${compter(['TERMINEE', 'REFUSEE', 'ANNULEE'])}',
              'Terminées',
            ),
          ),
        ],
      ),
    );
  }
}

class _Nombre extends StatelessWidget {
  const _Nombre(this.valeur, this.libelle);
  final String valeur;
  final String libelle;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        valeur,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
      Text(
        libelle,
        style: const TextStyle(color: Colors.white70, fontSize: 11),
      ),
    ],
  );
}

class _Filtre extends StatelessWidget {
  const _Filtre(this.texte, this.selectionne, this.onTap);
  final String texte;
  final bool selectionne;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(texte),
      selected: selectionne,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: Theme.of(context).colorScheme.inverseSurface,
      labelStyle: TextStyle(
        color: selectionne
            ? Theme.of(context).colorScheme.onInverseSurface
            : Theme.of(context).colorScheme.onSurface,
      ),
    ),
  );
}

class _CarteCandidature extends StatelessWidget {
  const _CarteCandidature(this.item);
  final Map<String, dynamic> item;
  @override
  Widget build(BuildContext context) {
    final statut = item['statut']?.toString() ?? '';
    final acceptee = [
      'ACCEPTEE',
      'ELIGIBLE',
      'AFFECTEE',
    ].contains(statut.toUpperCase());
    final couleur = acceptee
        ? const Color(0xFF178A52)
        : const Color(0xFFE85D00);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: couleur.withValues(alpha: .12),
                  child: Icon(
                    acceptee
                        ? Icons.verified_outlined
                        : Icons.schedule_outlined,
                    color: couleur,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['hospital_name']?.toString() ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        item['campaign_title']?.toString() ?? '',
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Chip(label: Text(statut)),
                if (item['taux_presence'] != null)
                  Chip(label: Text('Présence ${item['taux_presence']} %')),
                if (item['note_finale'] != null)
                  Chip(label: Text('Note ${item['note_finale']}')),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Soumise le ${item['submitted_at'] ?? '-'}',
              style: const TextStyle(color: Color(0xFF718096), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _Vide extends StatelessWidget {
  const _Vide();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(30),
    child: Column(
      children: [
        FaIcon(FontAwesomeIcons.inbox, size: 50),
        SizedBox(height: 10),
        Text('Aucune candidature dans cette catégorie.'),
      ],
    ),
  );
}

class _Erreur extends StatelessWidget {
  const _Erreur({required this.onReessayer});
  final VoidCallback onReessayer;
  @override
  Widget build(BuildContext context) => Center(
    child: TextButton(
      onPressed: onReessayer,
      child: const Text('Chargement impossible · Réessayer'),
    ),
  );
}

List<Map<String, dynamic>> _liste(Object? valeur) => valeur is List
    ? valeur.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : <Map<String, dynamic>>[];
