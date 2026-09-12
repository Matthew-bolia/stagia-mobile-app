import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/widgets/contenu_adaptatif.dart';
import '../../data/models/etudiant_profil.dart';

class ModifierInformationsAcademiquesPage extends StatefulWidget {
  const ModifierInformationsAcademiquesPage({required this.profil, super.key});
  final EtudiantProfil profil;
  @override
  State<ModifierInformationsAcademiquesPage> createState() => _EtatAcademique();
}

class _EtatAcademique extends State<ModifierInformationsAcademiquesPage> {
  final _cle = GlobalKey<FormState>();
  late final List<TextEditingController> _controleurs;

  @override
  void initState() {
    super.initState();
    final p = widget.profil;
    _controleurs = [
      p.etablissement,
      p.faculte,
      p.filiere,
      p.option,
      p.niveau,
      p.anneeAcademique,
      p.matricule,
    ].map((e) => TextEditingController(text: e)).toList();
  }

  @override
  void dispose() {
    for (final controleur in _controleurs) {
      controleur.dispose();
    }
    super.dispose();
  }

  void _enregistrer() {
    FocusScope.of(context).unfocus();
    if (!(_cle.currentState?.validate() ?? false)) return;
    Navigator.pop(
      context,
      widget.profil.copyWith(
        etablissement: _controleurs[0].text.trim(),
        faculte: _controleurs[1].text.trim(),
        filiere: _controleurs[2].text.trim(),
        option: _controleurs[3].text.trim(),
        niveau: _controleurs[4].text.trim(),
        anneeAcademique: _controleurs[5].text.trim(),
        matricule: widget.profil.matricule,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final marge = MediaQuery.sizeOf(context).width < 360 ? 14.0 : 18.0;
    return Scaffold(
      appBar: AppBar(title: const Text('Informations universitaires')),
      body: ContenuAdaptatif(
        largeurMaximale: 720,
        enfant: Form(
          key: _cle,
          child: ListView(
            padding: EdgeInsets.fromLTRB(marge, 18, marge, 110),
            children: [
              const SizedBox(height: 5),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, contraintes) {
                  final deuxColonnes = contraintes.maxWidth >= 560;
                  final largeur = deuxColonnes
                      ? (contraintes.maxWidth - 16) / 2
                      : contraintes.maxWidth;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 18,
                    children: [
                      _ChampAcademique(
                        largeur: largeur,
                        controleur: _controleurs[0],
                        libelle: 'Université ou institut',
                        obligatoire: true,
                      ),
                      _ChampAcademique(
                        largeur: largeur,
                        controleur: _controleurs[1],
                        libelle: 'Faculté',
                        obligatoire: true,
                      ),
                      _ChampAcademique(
                        largeur: largeur,
                        controleur: _controleurs[2],
                        libelle: 'Département ou filière',
                        obligatoire: true,
                      ),
                      _ChampAcademique(
                        largeur: largeur,
                        controleur: _controleurs[3],
                        libelle: 'Option',
                      ),
                      _ChampAcademique(
                        largeur: largeur,
                        controleur: _controleurs[4],
                        libelle: 'Promotion et niveau',
                        obligatoire: true,
                      ),
                      _ChampAcademique(
                        largeur: largeur,
                        controleur: _controleurs[5],
                        libelle: 'Année académique',
                        indication: '2026-2027',
                        obligatoire: true,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(marge, 0, marge, 12),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _enregistrer,
                style: FilledButton.styleFrom(
                  backgroundColor: Color(Colors.black.value),
                  foregroundColor: Color(Colors.white.value),
                ),
                child: const Text('Enregistrer les modifications'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChampAcademique extends StatelessWidget {
  const _ChampAcademique({
    required this.largeur,
    required this.controleur,
    required this.libelle,
    this.indication,
    this.obligatoire = false,
  }) : lectureSeule = false,
       aide = null;
  final double largeur;
  final TextEditingController controleur;
  final String libelle;
  final String? indication;
  final String? aide;
  final bool lectureSeule;
  final bool obligatoire;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: largeur,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(libelle, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 7),
        TextFormField(
          controller: controleur,
          cursorColor: Theme.of(context).colorScheme.onSurface,
          readOnly: lectureSeule,
          decoration: InputDecoration(
            hintText: indication,
            helperText: aide,
            suffixIcon: lectureSeule
                ? const FaIcon(
                    FontAwesomeIcons.lock,
                    size: 17,
                    color: Color(0xFF7A7A7A),
                  )
                : null,
            filled: true,
            fillColor: lectureSeule
                ? (Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF292929)
                      : const Color(0xFFF1F3F5))
                : Theme.of(context).colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
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
          validator: obligatoire
              ? (valeur) => (valeur?.trim().isEmpty ?? true)
                    ? 'Champ obligatoire'
                    : null
              : null,
        ),
      ],
    ),
  );
}
