import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../core/network/client_api_http.dart';
import '../../../../core/network/configuration_api.dart';
import '../../../../core/network/source_media_distante.dart';
import '../../../../core/services/documents_etudiant_service.dart';

class SectionDossierProfil extends StatefulWidget {
  const SectionDossierProfil({super.key});
  @override
  State<SectionDossierProfil> createState() => _SectionDossierProfilState();
}

class _SectionDossierProfilState extends State<SectionDossierProfil> {
  static const _categories = [
    'Identité', 'Académique', 'Candidature', 'Stage', 'Administratif', 'Autre',
  ];
  final _media = SourceMediaDistante(ClientApiHttp());
  List<DocumentEtudiantLocal> _documents = [];
  bool _chargement = true;
  bool _importation = false;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final documents = await DocumentsEtudiantService.charger();
    if (mounted) setState(() { _documents = documents; _chargement = false; });
  }

  Future<void> _importer([DocumentEtudiantLocal? ancien]) async {
    String categorie = ancien?.categorie ?? _categories.first;
    final choix = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, modifier) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Catégorie du document', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: categorie,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                items: _categories.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (v) { if (v != null) modifier(() => categorie = v); },
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.pop(sheetContext, categorie),
                  child: const Text('Choisir le fichier'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (choix == null || !mounted) return;
    final resultat = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );
    if (!mounted || resultat.isEmpty || resultat.first.path == null) return;
    setState(() => _importation = true);
    try {
      final fichier = resultat.first;
      String? mediaId;
      if (!ConfigurationApi.utiliserDonneesMockees) {
        try {
          final reponse = await _media.uploader(
            cheminFichier: fichier.path!,
            type: 'STUDENT_DOCUMENT',
            classification: 'PRIVATE',
            politiqueConservation: 'STANDARD',
          );
          final data = reponse['data'];
          if (data is Map) mediaId = data['id']?.toString();
        } catch (_) {
          // La copie locale reste utilisable en cas d'échec de synchronisation.
        }
      }
      final nouveau = await DocumentsEtudiantService.importer(
        cheminSource: fichier.path!, nom: fichier.name,
        categorie: choix, mediaId: mediaId,
      );
      if (ancien != null) {
        await DocumentsEtudiantService.supprimer(ancien);
        _documents.removeWhere((d) => d.id == ancien.id);
      }
      _documents.insert(0, nouveau);
      await DocumentsEtudiantService.enregistrer(_documents);
      if (mounted) { setState(() {}); _message('Document conservé dans l’application.'); }
    } catch (_) {
      if (mounted) _message('Impossible d’importer ce document.', erreur: true);
    } finally {
      if (mounted) setState(() => _importation = false);
    }
  }

  Future<void> _ouvrir(DocumentEtudiantLocal document) async {
    final resultat = await OpenFilex.open(document.chemin);
    if (mounted && resultat.type != ResultType.done) {
      _message('Impossible d’ouvrir ce document.', erreur: true);
    }
  }

  Future<void> _supprimer(DocumentEtudiantLocal document) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le document ?'), content: Text(document.nom),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirme != true) return;
    await DocumentsEtudiantService.supprimer(document);
    _documents.removeWhere((d) => d.id == document.id);
    await DocumentsEtudiantService.enregistrer(_documents);
    if (mounted) setState(() {});
  }

  void _message(String texte, {bool erreur = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: erreur ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.inverseSurface,
      content: Text(texte),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final marge = MediaQuery.sizeOf(context).width < 360 ? 14.0 : 18.0;
    if (_chargement) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: EdgeInsets.fromLTRB(marge, 18, marge, 28),
      children: [
        const Text('Mes documents', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Text('Importez et classez les documents utiles à votre parcours.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 18),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton(onPressed: _importation ? null : _importer, child: Text(_importation ? 'Importation…' : 'Importer un document')),
        ),
        const SizedBox(height: 20),
        if (_documents.isEmpty)
          _BlocVide(theme: theme)
        else
          for (final document in _documents)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CarteDocument(
                document: document,
                onOuvrir: () => _ouvrir(document),
                onRemplacer: () => _importer(document),
                onSupprimer: () => _supprimer(document),
              ),
            ),
      ],
    );
  }
}

class _BlocVide extends StatelessWidget {
  const _BlocVide({required this.theme});
  final ThemeData theme;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: theme.colorScheme.outlineVariant),
    ),
    child: const Text('Aucun document importé.', textAlign: TextAlign.center),
  );
}

class _CarteDocument extends StatelessWidget {
  const _CarteDocument({required this.document, required this.onOuvrir, required this.onRemplacer, required this.onSupprimer});
  final DocumentEtudiantLocal document;
  final VoidCallback onOuvrir;
  final VoidCallback onRemplacer;
  final VoidCallback onSupprimer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(document.nom, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        const SizedBox(height: 9),
        Text('Catégorie : ${document.categorie}'),
        Text('Taille : ${_taille(document.taille)}'),
        Text('Ajouté le : ${_date(document.ajouteLe)}'),
        Text(document.mediaId == null ? 'Conservé sur le téléphone' : 'Synchronisé avec STAGIA', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, children: [
          TextButton(onPressed: onOuvrir, child: const Text('Ouvrir')),
          TextButton(onPressed: onRemplacer, child: const Text('Remplacer')),
          TextButton(onPressed: onSupprimer, child: Text('Supprimer', style: TextStyle(color: theme.colorScheme.error))),
        ]),
      ]),
    );
  }
}

String _taille(int octets) => octets >= 1048576
    ? '${(octets / 1048576).toStringAsFixed(1)} Mo'
    : '${(octets / 1024).toStringAsFixed(1)} Ko';
String _date(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
