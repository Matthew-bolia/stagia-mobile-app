import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import '../../../../core/network/client_api_http.dart';
import '../../../../core/network/source_etudiant_distante.dart';
import '../../../../core/widgets/contenu_adaptatif.dart';
import '../../../../core/widgets/erreur_chargement_api.dart';
import '../../../../core/mocks/depot_mock_etudiant.dart';
import '../widgets/section_rapport.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({this.estActif = true, super.key});
  final bool estActif;
  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage>
    with SingleTickerProviderStateMixin {
  final _source = SourceEtudiantDistante(ClientApiHttp());
  late final TabController _onglets;
  late Future<List<Map<String, dynamic>>> _chargement;
  int _indexOnglet = 0;

  @override
  void initState() {
    super.initState();
    _onglets = TabController(length: 3, vsync: this);
    _onglets.addListener(() {
      if (!_onglets.indexIsChanging && mounted) {
        setState(() => _indexOnglet = _onglets.index);
      }
    });
    _chargement = _charger();
  }

  Future<List<Map<String, dynamic>>> _charger() =>
      Future.wait([_source.journal(), _source.evaluations()]);

  Future<void> _actualiser() async {
    final futur = _charger();
    setState(() => _chargement = futur);
    await futur;
  }

  Future<void> _supprimerBrouillon(Map<String, dynamic> activite) async {
    DepotMockEtudiant.supprimerActivite(activite['uuid'].toString());
    await _actualiser();
  }

  Future<void> _soumettreBrouillon(Map<String, dynamic> activite) async {
    DepotMockEtudiant.soumettreActivite(activite['uuid'].toString());
    await _actualiser();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF1A7F37),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        content: Row(
          children: [
            FaIcon(FontAwesomeIcons.circleCheck, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _ouvrirDetailBrouillon(Map<String, dynamic> activite) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .82,
        minChildSize: .5,
        maxChildSize: .94,
        builder: (_, controleur) => ListView(
          controller: controleur,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          children: [
            const Text(
              'Détail du journal',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LigneDetail('Titre de l’activité', activite['learning']),
                  _LigneDetail('Date', _formatDateDetail(activite['date'])),
                  _LigneDetail('Service ou unité', activite['unit']?['name']),
                  _LigneDetail(
                    'Durée',
                    '${activite['duration'] ?? '-'} ${activite['duration'] == null ? '' : 'heure(s)'}',
                  ),
                  _LigneDetail(
                    'Catégorie',
                    _items(activite['activities']).isEmpty
                        ? '-'
                        : _items(activite['activities']).first['category'],
                  ),
                  _LigneDetail('Travail réalisé', activite['summary']),
                  _LigneDetail('Compétences travaillées', activite['skills']),
                  _LigneDetail('Difficultés', activite['difficulties']),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                _ajouterActivite(activite);
              },
              child: const Text('Modifier le journal'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                _soumettreBrouillon(activite);
              },
              child: const Text('Soumettre le journal'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _onglets.dispose();
    super.dispose();
  }

  Future<void> _ajouterActivite([Map<String, dynamic>? activite]) async {
    final activites = _items(activite?['activities']);
    final titre = TextEditingController(
      text: activite?['learning']?.toString(),
    );
    final description = TextEditingController(
      text: activite?['summary']?.toString(),
    );
    final difficulte = TextEditingController(
      text: activite?['difficulties']?.toString(),
    );
    final date = TextEditingController(
      text:
          _formatDateChamps(activite?['date']?.toString()) ??
          _formatDateChamps(DateTime.now().toIso8601String()),
    );
    final categorie = TextEditingController(
      text: activites.isEmpty ? '' : activites.first['category']?.toString(),
    );
    final duree = TextEditingController(
      text: activite?['duration']?.toString(),
    );
    final service = TextEditingController(
      text: activite?['unit']?['name']?.toString(),
    );
    final objectifs = TextEditingController(
      text: activite?['objectives']?.toString(),
    );
    final competences = TextEditingController(
      text: activite?['skills']?.toString(),
    );
    final resultats = TextEditingController(
      text: activite?['results']?.toString(),
    );
    final cle = GlobalKey<FormState>();
    final ajoutee = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          20,
          18,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              child: Form(
                key: cle,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        activite == null
                            ? 'Nouvelle activité'
                            : 'Modifier le brouillon',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: date,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Date de l’activité',
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: FaIcon(
                              FontAwesomeIcons.calendarDays,
                              size: 26,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        onTap: () async {
                          final choix = await showDatePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            initialDate: _dateDepuisChamps(date.text),
                          );
                          if (choix != null) {
                            date.text =
                                (_formatDateChamps(choix.toIso8601String()) ??
                                _formatDateChamps(
                                  DateTime.now().toIso8601String(),
                                ))!;
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: titre,
                        decoration: const InputDecoration(
                          labelText: 'Titre de l’activité',
                        ),
                        validator: (v) => (v?.trim().isEmpty ?? true)
                            ? 'Champ obligatoire'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: categorie,
                        decoration: const InputDecoration(
                          labelText: 'Catégorie de l’activité',
                        ),
                        validator: (v) => (v?.trim().isEmpty ?? true)
                            ? 'Champ obligatoire'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: duree,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Durée en heures',
                        ),
                        validator: (v) => (v?.trim().isEmpty ?? true)
                            ? 'Champ obligatoire'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: service,
                        decoration: const InputDecoration(
                          labelText: 'Service affecté',
                        ),
                        validator: (v) => (v?.trim().isEmpty ?? true)
                            ? 'Champ obligatoire'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: description,
                        minLines: 3,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Activité réalisée',
                        ),
                        validator: (v) => (v?.trim().isEmpty ?? true)
                            ? 'Champ obligatoire'
                            : null,
                      ),
                      //
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: competences,
                        decoration: const InputDecoration(
                          labelText: 'Compétences travaillées',
                        ),
                      ),
                      //
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: difficulte,
                        minLines: 2,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Difficultés (facultatif)',
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () {
                          if (!(cle.currentState?.validate() ?? false)) return;
                          final donnees = (
                            titre: titre.text.trim(),
                            description: description.text.trim(),
                            difficulte: difficulte.text.trim(),
                            date: date.text.trim(),
                            categorie: categorie.text.trim(),
                            duree: duree.text.trim(),
                            service: service.text.trim(),
                            objectifs: objectifs.text.trim(),
                            competences: competences.text.trim(),
                            resultats: resultats.text.trim(),
                          );
                          if (activite == null) {
                            DepotMockEtudiant.ajouterActivite(
                              titre: donnees.titre,
                              description: donnees.description,
                              difficulte: donnees.difficulte,
                              date: donnees.date,
                              categorie: donnees.categorie,
                              duree: donnees.duree,
                              service: donnees.service,
                              objectif: donnees.objectifs,
                              competences: donnees.competences,
                              resultats: donnees.resultats,
                            );
                          } else {
                            DepotMockEtudiant.modifierActivite(
                              activite['uuid'].toString(),
                              titre: donnees.titre,
                              description: donnees.description,
                              difficulte: donnees.difficulte,
                              date: donnees.date,
                              categorie: donnees.categorie,
                              duree: donnees.duree,
                              service: donnees.service,
                              objectifs: donnees.objectifs,
                              competences: donnees.competences,
                              resultats: donnees.resultats,
                            );
                          }
                          Navigator.pop(context, true);
                        },
                        child: Text(
                          activite == null
                              ? 'Enregistrer le journal'
                              : 'Enregistrer les modifications',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (ajoutee == true && mounted) {
      try {
        await _actualiser();
      } catch (_) {
        // Le FutureBuilder présente déjà l'erreur de chargement sans provoquer
        // d'exception non gérée pendant le retour du formulaire.
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF1A7F37),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          content: Row(
            children: [
              FaIcon(
                FontAwesomeIcons.circleCheck,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 12),
              Text('Activité enregistrée dans le journal.'),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      bottom: TabBar(
        controller: _onglets,
        indicatorColor: const Color(0xFFFF7417),
        labelColor: Theme.of(context).colorScheme.onSurface,
        tabs: const [
          Tab(text: 'Journal'),
          Tab(text: 'Rapport'),
          Tab(text: 'Évaluations'),
        ],
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
          final data = snapshot.data!;
          return TabBarView(
            controller: _onglets,
            children: [
              _ListeApi(
                items: _items(data[0]['items']),
                vide: 'Aucune entrée dans le journal.',
                constructeur: (item) => _journal(
                  context,
                  item,
                  onOuvrir: () => _ouvrirDetailBrouillon(item),
                  onSupprimer: () => _supprimerBrouillon(item),
                ),
              ),
              const SectionRapport(),
              _ListeApi(
                items: _items(data[1]['items']),
                vide: 'Aucune évaluation disponible.',
                constructeur: (item) => _evaluation(context, item),
              ),
            ],
          );
        },
      ),
    ),
    floatingActionButton: widget.estActif && _indexOnglet == 0
        ? FloatingActionButton(
            onPressed: _ajouterActivite,
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 6,
            shape: const CircleBorder(side: BorderSide(color: Colors.black)),
            tooltip: 'Ajouter une activité',
            child: const FaIcon(FontAwesomeIcons.plus, size: 20),
          )
        : null,
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
  );
}

class _ListeApi extends StatelessWidget {
  const _ListeApi({
    required this.items,
    required this.vide,
    required this.constructeur,
  });
  final List<Map<String, dynamic>> items;
  final String vide;
  final Widget Function(Map<String, dynamic>) constructeur;
  @override
  Widget build(BuildContext context) {
    final marge = MediaQuery.sizeOf(context).width < 360 ? 14.0 : 18.0;
    if (items.isEmpty) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          margin: EdgeInsets.all(marge),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                FontAwesomeIcons.inbox,
                size: 42,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                vide,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(marge, 16, marge, 28),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) => constructeur(items[index]),
    );
  }
}

class _LigneDetail extends StatelessWidget {
  const _LigneDetail(this.libelle, this.valeur);

  final String libelle;
  final Object? valeur;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 11),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          libelle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${valeur == null || '$valeur'.trim().isEmpty ? '-' : valeur}',
          textAlign: TextAlign.left,
          style: const TextStyle(height: 1.35, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

Widget _journal(
  BuildContext context,
  Map<String, dynamic> item, {
  required VoidCallback onOuvrir,
  required VoidCallback onSupprimer,
}) {
  final activites = _items(item['activities']);
  final brouillon = item['status']?.toString().toUpperCase() == 'BROUILLON';
  if (brouillon) {
    return Dismissible(
      key: ValueKey(item['uuid']),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Supprimer ce brouillon ?'),
          content: const Text(
            'Cette action supprimera définitivement cette activité.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Supprimer'),
            ),
          ],
        ),
      ),
      onDismissed: (_) => onSupprimer(),
      background: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 48,
          height: 48,
          margin: const EdgeInsets.only(right: 12),
          decoration: const BoxDecoration(
            color: Color(0xFFD92D20),
            shape: BoxShape.circle,
          ),
          child: const FaIcon(
            FontAwesomeIcons.trash,
            color: Colors.white,
            size: 25,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          margin: EdgeInsets.zero,
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: InkWell(
            onTap: onOuvrir,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item['learning']?.toString() ?? 'Journal intitulé',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE3D1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Journal',
                          style: TextStyle(
                            color: Color(0xFFE85D00),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${_dateCourte(item['date'])} · ${_heureCourte(item['created_at'])}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  return Card(
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item['campaign']?['title']?.toString() ?? 'Journal',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Chip(label: Text(item['status']?.toString() ?? '')),
            ],
          ),
          Text(
            '${item['hospital']?['name'] ?? ''} · ${item['unit']?['name'] ?? ''}',
            style: const TextStyle(color: Color(0xFF718096)),
          ),
          if (item['difficulties'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text('Difficultés : ${item['difficulties']}'),
            ),
          if ('${item['objectives'] ?? ''}'.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Objectifs : ${item['objectives']}'),
            ),
          if ('${item['skills'] ?? ''}'.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Compétences : ${item['skills']}'),
            ),
          if ('${item['results'] ?? ''}'.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Résultats : ${item['results']}'),
            ),
          for (final activite in activites)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.task_alt, color: Color(0xFFFF7417)),
              title: Text(activite['category']?.toString() ?? 'Activité'),
              subtitle: Text(
                '${activite['involvement_level'] ?? ''} · Quantité : ${activite['quantity'] ?? 0}',
              ),
            ),
        ],
      ),
    ),
  );
}

Widget _evaluation(BuildContext context, Map<String, dynamic> item) => Card(
  color: Theme.of(context).colorScheme.surfaceContainerLow,
  surfaceTintColor: Colors.transparent,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item['type']?.toString() ?? 'Évaluation',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            Text(
              '${item['note'] ?? '-'} / 100',
              style: const TextStyle(
                color: Color(0xFFFF7417),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(item['appreciation']?.toString() ?? 'Aucune appréciation.'),
        const SizedBox(height: 8),
        Text(
          '${item['hospital']?['name'] ?? ''} · ${item['unit']?['name'] ?? ''}',
          style: const TextStyle(color: Color(0xFF718096)),
        ),
      ],
    ),
  ),
);

List<Map<String, dynamic>> _items(Object? valeur) => valeur is List
    ? valeur.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : <Map<String, dynamic>>[];

String? _formatDateChamps(Object? valeur) {
  final date = DateTime.tryParse(valeur?.toString() ?? '');
  if (date == null) return null;
  final jour = date.day.toString().padLeft(2, '0');
  final mois = date.month.toString().padLeft(2, '0');
  final annee = (date.year % 100).toString().padLeft(2, '0');
  return '$jour-$mois-$annee';
}

String _formatDateDetail(Object? valeur) {
  return _formatDateChamps(valeur) ?? '-';
}

DateTime _dateDepuisChamps(String? valeur) {
  final date = DateTime.tryParse(valeur?.toString() ?? '');
  if (date != null) return date;

  final parts = (valeur ?? '').split('-');
  if (parts.length == 3) {
    final jour = int.tryParse(parts[0]);
    final mois = int.tryParse(parts[1]);
    final annee = int.tryParse(parts[2]);
    if (jour != null && mois != null && annee != null) {
      return DateTime(2000 + annee, mois, jour);
    }
  }

  return DateTime.now();
}

String _dateCourte(Object? valeur) {
  final date = DateTime.tryParse(valeur?.toString() ?? '');
  if (date == null) return '-';
  final jour = date.day.toString().padLeft(2, '0');
  final mois = date.month.toString().padLeft(2, '0');
  final annee = (date.year % 100).toString().padLeft(2, '0');
  return '$jour/$mois/$annee';
}

String _heureCourte(Object? valeur) {
  final date = DateTime.tryParse(valeur?.toString() ?? '') ?? DateTime.now();
  final heure = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$heure:$minute';
}
