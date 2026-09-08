import 'package:flutter/material.dart';
import '../../../../core/widgets/contenu_adaptatif.dart';
import '../../data/models/etudiant_profil.dart';

class ModifierInformationsPersonnellesPage extends StatefulWidget {
  const ModifierInformationsPersonnellesPage({required this.profil, super.key});
  final EtudiantProfil profil;

  @override
  State<ModifierInformationsPersonnellesPage> createState() =>
      _ModifierInformationsPersonnellesPageState();
}

class _ModifierInformationsPersonnellesPageState
    extends State<ModifierInformationsPersonnellesPage> {
  final _cle = GlobalKey<FormState>();
  late final TextEditingController _nom;
  late final TextEditingController _postnom;
  late final TextEditingController _prenom;
  late final TextEditingController _naissance;
  late final TextEditingController _adresse;
  late final TextEditingController _province;
  late final TextEditingController _telephone;
  late final TextEditingController _email;
  late String _sexe;

  @override
  void initState() {
    super.initState();
    final p = widget.profil;
    final parties = p.nomComplet.trim().split(RegExp(r'\s+'));
    _nom = TextEditingController(text: parties.isEmpty ? '' : parties.first);
    _prenom = TextEditingController(
      text: parties.length < 2 ? '' : parties.last,
    );
    _postnom = TextEditingController(
      text: parties.length < 3
          ? ''
          : parties.sublist(1, parties.length - 1).join(' '),
    );
    _naissance = TextEditingController(text: p.dateNaissance);
    _adresse = TextEditingController(text: p.adresse);
    _province = TextEditingController(text: p.province);
    _telephone = TextEditingController(text: p.telephone);
    _email = TextEditingController(text: p.email);
    _sexe = p.sexe;
  }

  @override
  void dispose() {
    for (final controleur in [
      _nom,
      _postnom,
      _prenom,
      _naissance,
      _adresse,
      _province,
      _telephone,
      _email,
    ]) {
      controleur.dispose();
    }
    super.dispose();
  }

  Future<void> _choisirDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      initialDate: DateTime(2003, 3, 14),
    );
    if (date != null) {
      _naissance.text =
          '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    }
  }

  void _enregistrer() {
    FocusScope.of(context).unfocus();
    if (!(_cle.currentState?.validate() ?? false)) return;
    final nomComplet = [
      _nom.text,
      _postnom.text,
      _prenom.text,
    ].map((e) => e.trim()).where((e) => e.isNotEmpty).join(' ');
    Navigator.pop(
      context,
      widget.profil.copyWith(
        nomComplet: nomComplet,
        sexe: _sexe,
        dateNaissance: _naissance.text.trim(),
        adresse: _adresse.text.trim(),
        province: _province.text.trim(),
        telephone: _telephone.text.trim(),
        email: widget.profil.email,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final marge = MediaQuery.sizeOf(context).width < 360 ? 14.0 : 18.0;
    return Scaffold(
      appBar: AppBar(title: const Text('Informations personnelles')),
      body: ContenuAdaptatif(
        largeurMaximale: 720,
        enfant: Form(
          key: _cle,
          child: ListView(
            padding: EdgeInsets.fromLTRB(marge, 18, marge, 110),
            children: [
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
                      _Champ(
                        largeur: largeur,
                        controleur: _nom,
                        libelle: 'Nom',
                        obligatoire: true,
                      ),
                      _Champ(
                        largeur: largeur,
                        controleur: _postnom,
                        libelle: 'Postnom',
                      ),
                      _Champ(
                        largeur: largeur,
                        controleur: _prenom,
                        libelle: 'Prénom',
                        obligatoire: true,
                      ),
                      SizedBox(
                        width: largeur,
                        child: _LibelleChamp(
                          libelle: 'Sexe',
                          enfant: DropdownButtonFormField<String>(
                            initialValue: _sexe.isEmpty ? null : _sexe,
                            decoration: _decoration(context),
                            items: const ['Féminin', 'Masculin']
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (valeur) =>
                                setState(() => _sexe = valeur ?? _sexe),
                          ),
                        ),
                      ),
                      _Champ(
                        largeur: largeur,
                        controleur: _naissance,
                        libelle: 'Date de naissance',
                        indication: 'JJ-MM-AAAA',
                        lectureSeule: true,
                        onTap: _choisirDate,
                      ),
                      _Champ(
                        largeur: largeur,
                        controleur: _province,
                        libelle: 'Province et ville',
                        obligatoire: true,
                      ),
                      _Champ(
                        largeur: contraintes.maxWidth,
                        controleur: _adresse,
                        libelle: 'Adresse complète',
                        lignes: 3,
                        obligatoire: true,
                      ),
                      _Champ(
                        largeur: largeur,
                        controleur: _telephone,
                        libelle: 'Numéro de téléphone',
                        clavier: TextInputType.phone,
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
      bottomNavigationBar: _BarreEnregistrement(
        marge: marge,
        onEnregistrer: _enregistrer,
      ),
    );
  }
}

class _Champ extends StatelessWidget {
  const _Champ({
    required this.largeur,
    required this.controleur,
    required this.libelle,
    this.indication,
    this.aide,
    this.clavier,
    this.lignes = 1,
    this.lectureSeule = false,
    this.obligatoire = false,
    this.onTap,
  });
  final double largeur;
  final TextEditingController controleur;
  final String libelle;
  final String? indication;
  final String? aide;
  final TextInputType? clavier;
  final int lignes;
  final bool lectureSeule;
  final bool obligatoire;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: largeur,
    child: _LibelleChamp(
      libelle: libelle,
      obligatoire: obligatoire,
      enfant: TextFormField(
        controller: controleur,
        cursorColor: Theme.of(context).colorScheme.onSurface,
        readOnly: lectureSeule,
        keyboardType: clavier,
        minLines: lignes,
        maxLines: lignes,
        onTap: onTap,
        decoration: _decoration(
          context,
          indication: indication,
          aide: aide,
          lectureSeule: lectureSeule,
        ),
        validator: obligatoire
            ? (valeur) =>
                  (valeur?.trim().isEmpty ?? true) ? 'Champ obligatoire' : null
            : null,
      ),
    ),
  );
}

class _LibelleChamp extends StatelessWidget {
  const _LibelleChamp({
    required this.libelle,
    required this.enfant,
    this.obligatoire = false,
  });
  final String libelle;
  final Widget enfant;
  final bool obligatoire;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(libelle, style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 7),
      enfant,
    ],
  );
}

InputDecoration _decoration(
  BuildContext context, {
  String? indication,
  String? aide,
  bool lectureSeule = false,
}) => InputDecoration(
  hintText: indication,
  helperText: aide,
  filled: true,
  fillColor: lectureSeule
      ? (Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF292929)
            : const Color(0xFFF1F3F5))
      : Theme.of(context).colorScheme.surface,
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(9),
    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(9),
    borderSide: BorderSide(
      color: Theme.of(context).colorScheme.onSurface,
      width: 1.5,
    ),
  ),
);

// ignore: unused_element
class _Introduction extends StatelessWidget {
  const _Introduction({required this.titre, required this.description});
  final String titre;
  final String description;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        titre,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 5),
      Text(
        description,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ],
  );
}

class _BarreEnregistrement extends StatelessWidget {
  const _BarreEnregistrement({
    required this.marge,
    required this.onEnregistrer,
  });
  final double marge;
  final VoidCallback onEnregistrer;
  @override
  Widget build(BuildContext context) => SafeArea(
    minimum: EdgeInsets.fromLTRB(marge, 0, marge, 12),
    child: Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: onEnregistrer,
            style: FilledButton.styleFrom(
              backgroundColor: Color(Colors.black.value),
              foregroundColor: Color(Colors.white.value),
            ),
            child: const Text('Enregistrer les modifications'),
          ),
        ),
      ),
    ),
  );
}
