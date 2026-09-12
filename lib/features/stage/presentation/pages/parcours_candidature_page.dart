import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/mocks/depot_mock_etudiant.dart';
import '../../../../core/widgets/contenu_adaptatif.dart';
import '../routes/routes_stage.dart';

class ParcoursCandidaturePage extends StatefulWidget {
  const ParcoursCandidaturePage({required this.option, super.key});
  final Map<String, dynamic> option;
  @override
  State<ParcoursCandidaturePage> createState() => _EtatParcours();
}

class _EtatParcours extends State<ParcoursCandidaturePage> {
  final _cle = GlobalKey<FormState>();
  final _motivation = TextEditingController();
  int _etape = 0;
  PlatformFile? _document;
  Map<String, dynamic>? _candidature;

  @override
  void dispose() {
    _motivation.dispose();
    super.dispose();
  }

  Future<void> _importer() async {
    final resultat = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx', 'excel', 'xlsx'],
    );
    if (mounted && resultat.isNotEmpty) {
      setState(() => _document = resultat.first);
    }
  }

  void _continuer() {
    if (_etape == 1 && !(_cle.currentState?.validate() ?? false)) return;
    setState(() => _etape++);
  }

  void _soumettre() {
    _candidature = DepotMockEtudiant.ajouterCandidature(
      cleOption: '${widget.option['cle_option'] ?? ''}',
      campagneId: '${widget.option['campagne_id'] ?? ''}',
      campagne: '${widget.option['campagne'] ?? ''}',
      etablissement: '${widget.option['etablissement'] ?? ''}',
      localisation: '${widget.option['localisation'] ?? ''}',
      motivation: _motivation.text.trim(),
      document: _document?.name,
      cheminDocument: _document?.path,
    );
    setState(() => _etape = 3);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        ['Éligibilité', 'Candidature', 'Récapitulatif', 'Confirmation'][_etape],
      ),
    ),
    body: ContenuAdaptatif(
      enfant: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _Progression(_etape),
          const SizedBox(height: 24),
          if (_etape == 0) _eligibilite(),
          if (_etape == 1) _formulaire(),
          if (_etape == 2) _recapitulatif(),
          if (_etape == 3) _confirmation(),
        ],
      ),
    ),
  );

  Widget _eligibilite() => Column(
    children: [
      FaIcon(FontAwesomeIcons.circleCheck, size: 72, color: Color(0xFFFF7417)),
      const SizedBox(height: 14),
      const Text(
        'Vous êtes éligible',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 8),
      Text(
        'Votre profil correspond à cette campagne auprès de ${widget.option['etablissement']}.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 18),
      const _Critere('Profil académique complété'),
      const _Critere('Étudiant actif et matricule vérifié'),
      const _Critere('Campagne actuellement disponible'),
      const SizedBox(height: 18),
      _Bouton(
        child: FilledButton(
          onPressed: _continuer,
          child: const Text('Continuer'),
        ),
      ),
    ],
  );

  Widget _formulaire() => Form(
    key: _cle,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Entete(option: widget.option),
        const SizedBox(height: 22),
        const SizedBox(height: 14),
        TextFormField(
          controller: _motivation,
          minLines: 5,
          maxLines: 7,
          decoration: InputDecoration(
            labelText: 'Motivation',
            hintText: 'Expliquez votre intérêt pour ce stage',
            alignLabelWithHint: true,
            filled: true,
            fillColor: Colors.white,
            labelStyle: const TextStyle(color: Colors.black),
            hintStyle: const TextStyle(color: Color(0xFF667085)),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(color: Colors.black, width: 1.6),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
          style: const TextStyle(color: Colors.black),
          cursorColor: Colors.black,
          validator: (v) => (v?.trim().length ?? 0) < 20
              ? 'Saisissez au moins 20 caractères.'
              : null,
        ),
        const SizedBox(height: 24),
        const SizedBox(height: 14),
        _ZoneImport(
          document: _document,
          importer: _importer,
          supprimer: () => setState(() => _document = null),
        ),
        const SizedBox(height: 24),
        _Bouton(
          child: FilledButton.icon(
            onPressed: _continuer,
            label: const Text('Vérifier ma candidature'),
          ),
        ),
      ],
    ),
  );

  Widget _recapitulatif() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Vérifiez vos informations',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 4),
      const Text(
        'Assurez-vous que tout est correct avant l’envoi.',
        style: TextStyle(color: Color(0xFF718096), height: 1.35),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black),
        ),
        child: Column(
          children: [
            _Ligne(null, 'Établissement', widget.option['etablissement']),
            const Divider(height: 24),
            _Ligne(
              Icons.campaign_outlined,
              'Campagne',
              widget.option['campagne'],
            ),
            const Divider(height: 24),
            _Ligne(
              Icons.location_on_outlined,
              'Localisation',
              widget.option['localisation'],
            ),
            const Divider(height: 24),
            _Ligne(
              Icons.description_outlined,
              'Document',
              _document?.name ?? 'Aucun document',
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Motivation',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _motivation.text,
              style: const TextStyle(color: Colors.black, height: 1.45),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      _Bouton(
        child: FilledButton(
          onPressed: _soumettre,
          child: const Text('Envoyer ma candidature'),
        ),
      ),
      _Bouton(
        child: TextButton(
          onPressed: () => setState(() => _etape = 1),
          child: const Text('Modifier les informations'),
        ),
      ),
    ],
  );

  Widget _confirmation() => Column(
    children: [
      const Icon(Icons.check_circle, size: 82, color: Color(0xFF178A52)),
      const SizedBox(height: 14),
      const Text(
        'Candidature envoyée',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 8),
      Text(
        'Référence : ${_candidature?['uuid'] ?? ''}',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),
      _Bouton(
        child: FilledButton(
          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
            RoutesStage.candidatures,
            (route) => route.isFirst,
          ),
          child: const Text('Voir mes candidatures'),
        ),
      ),
    ],
  );
}

class _ZoneImport extends StatelessWidget {
  const _ZoneImport({
    required this.document,
    required this.importer,
    required this.supprimer,
  });
  final PlatformFile? document;
  final VoidCallback importer;
  final VoidCallback supprimer;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.black),
    ),
    child: document == null
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: importer,
                  tooltip: 'Importer un fichier',
                  iconSize: 38,
                  color: Colors.black,
                  icon: const Icon(Icons.cloud_upload_outlined),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Importer un fichier',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )
        : Row(
            children: [
              const Icon(
                Icons.description_outlined,
                color: Colors.black,
                size: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      document!.extension?.toUpperCase() ?? 'DOCUMENT',
                      style: const TextStyle(color: Color(0xFF4B5563)),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: importer,
                tooltip: 'Remplacer',
                icon: const Icon(Icons.refresh_rounded, color: Colors.black),
              ),
              IconButton(
                onPressed: supprimer,
                tooltip: 'Supprimer',
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
  );
}

class _Bouton extends StatelessWidget {
  const _Bouton({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: SizedBox(width: double.infinity, height: 50, child: child),
    ),
  );
}

class _Entete extends StatelessWidget {
  const _Entete({required this.option});
  final Map<String, dynamic> option;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.inverseSurface,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: Color(0xFFFF7417),
          foregroundColor: Theme.of(context).colorScheme.onInverseSurface,
          child: Icon(Icons.business_center_outlined),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${option['etablissement'] ?? ''}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '${option['campagne'] ?? ''}',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onInverseSurface.withValues(alpha: .7),
                ),
              ),
              Text(
                '${option['localisation'] ?? ''}',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onInverseSurface.withValues(alpha: .55),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Titre extends StatelessWidget {
  const _Titre(this.icone, this.titre, this.description);
  final IconData icone;
  final String titre;
  final String description;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icone, color: const Color(0xFFFF7417)),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titre,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            Text(
              description,
              style: const TextStyle(color: Color(0xFF718096), height: 1.35),
            ),
          ],
        ),
      ),
    ],
  );
}

class _Ligne extends StatelessWidget {
  const _Ligne(this.icone, this.titre, this.valeur);
  final IconData? icone;
  final String titre;
  final Object? valeur;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (icone != null) ...[
        Icon(icone, color: Colors.black, size: 21),
        const SizedBox(width: 12),
      ],
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titre,
              style: const TextStyle(color: Color(0xFF718096), fontSize: 12),
            ),
            Text(
              '${valeur ?? '-'}',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _Progression extends StatelessWidget {
  const _Progression(this.etape);
  final int etape;
  @override
  Widget build(BuildContext context) => Row(
    children: List.generate(
      4,
      (index) => Expanded(
        child: Container(
          height: 5,
          margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
          decoration: BoxDecoration(
            color: index <= etape
                ? const Color(0xFFFF7417)
                : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    ),
  );
}

class _Critere extends StatelessWidget {
  const _Critere(this.texte);
  final String texte;
  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Icons.check_circle_outline, color: Color(0xFF178A52)),
    title: Text(texte),
  );
}
