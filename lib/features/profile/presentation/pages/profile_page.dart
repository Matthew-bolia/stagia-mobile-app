import 'dart:io';
import 'package:alert_info/alert_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../app/routes/routes_application.dart';
import '../../../../core/services/photo_profil_service.dart';
import '../../../../core/services/session_authentification_service.dart';
import '../../../../core/widgets/contenu_adaptatif.dart';
import '../../../../core/network/client_api_http.dart';
import '../../../../core/network/source_etudiant_distante.dart';
import '../../data/models/etudiant_profil.dart';
import '../widgets/section_dossier_profil.dart';
import '../widgets/section_parametres_profil.dart';
import 'modifier_informations_academiques_page.dart';
import 'modifier_informations_personnelles_page.dart';
import 'notes_academiques_page.dart';
import 'parcours_academique_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _source = SourceEtudiantDistante(ClientApiHttp());
  EtudiantProfil _profil = EtudiantProfil.vide();
  bool _chargement = true;
  bool _erreurChargement = false;

  @override
  void initState() {
    super.initState();
    _chargerProfil();
  }

  Future<void> _chargerProfil() async {
    setState(() {
      _chargement = true;
      _erreurChargement = false;
    });
    try {
      final donnees = await _source.profil();
      final profilApi = EtudiantProfil.fromApi(donnees);
      final emailSession = await SessionAuthentificationService.email();
      final matriculeSession = await SessionAuthentificationService.matricule();
      if (!mounted) return;
      setState(
        () => _profil = profilApi.copyWith(
          email: profilApi.email.isEmpty ? emailSession : null,
          matricule: profilApi.matricule.isEmpty ? matriculeSession : null,
        ),
      );
    } catch (_) {
      if (mounted) setState(() => _erreurChargement = true);
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  Future<void> _choisirPhoto() async {
    try {
      final fichiers = await FilePicker.pickFiles(type: FileType.image);
      if (!mounted || fichiers.isEmpty) return;

      final chemin = fichiers.first.path;
      if (chemin == null || !await File(chemin).exists()) {
        throw const FileSystemException('Image inaccessible');
      }

      await PhotoProfilService.instance.definirPhoto(chemin);
      if (!mounted) return;
      AlertInfo.show(
        context: context,
        text: 'Photo de profil importée avec succès.',
        typeInfo: TypeInfo.success,
      );
    } catch (_) {
      if (!mounted) return;
      AlertInfo.show(
        context: context,
        text: 'Impossible d’importer cette image.',
        typeInfo: TypeInfo.error,
      );
    }
  }

  Future<void> _ouvrirModificationPersonnelle() async {
    final resultat = await Navigator.of(context, rootNavigator: true)
        .push<EtudiantProfil>(
          MaterialPageRoute(
            builder: (_) =>
                ModifierInformationsPersonnellesPage(profil: _profil),
          ),
        );
    if (resultat != null && mounted) setState(() => _profil = resultat);
  }

  Future<void> _ouvrirModificationAcademique() async {
    final resultat = await Navigator.of(context, rootNavigator: true)
        .push<EtudiantProfil>(
          MaterialPageRoute(
            builder: (_) =>
                ModifierInformationsAcademiquesPage(profil: _profil),
          ),
        );
    if (resultat != null && mounted) setState(() => _profil = resultat);
  }

  void _ouvrirPage(String titre, Widget contenu) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(
              titre,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          body: ContenuAdaptatif(largeurMaximale: 640, enfant: contenu),
        ),
      ),
    );
  }

  Future<void> _deconnecter() async {
    final confirmer = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text('Voulez-vous vraiment quitter votre session ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    if (confirmer == true && mounted) {
      await SessionAuthentificationService.supprimer();
      if (!mounted) return;
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamedAndRemoveUntil(RoutesApplication.connexion, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_chargement) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF7417)),
        ),
      );
    }
    if (_erreurChargement) {
      return Scaffold(
        body: Center(
          child: TextButton(
            onPressed: _chargerProfil,
            child: const Text('Chargement impossible · Réessayer'),
          ),
        ),
      );
    }

    final marge = MediaQuery.sizeOf(context).width < 360 ? 14.0 : 18.0;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: ContenuAdaptatif(
        largeurMaximale: 520,
        enfant: AnimatedBuilder(
          animation: PhotoProfilService.instance,
          builder: (context, _) => ListView(
            padding: EdgeInsets.fromLTRB(
              marge,
              MediaQuery.paddingOf(context).top + 22,
              marge,
              30,
            ),
            children: [
              _NouvelEnteteProfil(
                profil: _profil,
                cheminPhoto: PhotoProfilService.instance.cheminPhoto,
                onChoisirPhoto: _choisirPhoto,
              ),
              const SizedBox(height: 20),
              _BlocProfil(
                enfants: [
                  _ElementMenu(
                    icone: FontAwesomeIcons.user,
                    titre: 'Informations personnelles',
                    onTap: _ouvrirModificationPersonnelle,
                  ),
                  _ElementMenu(
                    icone: FontAwesomeIcons.graduationCap,
                    titre: 'Informations académiques',
                    onTap: _ouvrirModificationAcademique,
                  ),
                  _ElementMenu(
                    icone: FontAwesomeIcons.route,
                    titre: 'Parcours académique',
                    onTap: () =>
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                ParcoursAcademiquePage(profil: _profil),
                          ),
                        ),
                  ),
                  _ElementMenu(
                    icone: FontAwesomeIcons.noteSticky,
                    titre: 'Notes académiques',
                    onTap: () =>
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const NotesAcademiquesPage(),
                          ),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _BlocProfil(
                enfants: [
                  _ElementMenu(
                    icone: FontAwesomeIcons.addressCard,
                    titre: 'Matricule',
                    valeur: _profil.matricule,
                    onTap: () {},
                  ),
                  _ElementMenu(
                    icone: FontAwesomeIcons.envelope,
                    titre: 'Adresse e-mail',
                    valeur: _profil.email,
                    onTap: () {},
                  ),
                  _ElementMenu(
                    icone: FontAwesomeIcons.folderOpen,
                    titre: 'Mes documents',
                    onTap: () => _ouvrirPage(
                      'Mes documents',
                      const SectionDossierProfil(),
                    ),
                  ),
                  _ElementMenu(
                    icone: FontAwesomeIcons.gear,
                    titre: 'Paramètres',
                    onTap: () => _ouvrirPage(
                      'Paramètres',
                      const SectionParametresProfil(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // ignore: dead_code
              if (false)
                // ignore: dead_code
                _BlocProfil(
                  titre: 'SUPPORT',
                  enfants: [
                    _ElementMenu(
                      icone: FontAwesomeIcons.fileLines,
                      titre: 'Conditions d’utilisation',
                      onTap: () => _ouvrirPage(
                        'Conditions d’utilisation',
                        const SectionParametresProfil(),
                      ),
                    ),
                    _ElementMenu(
                      icone: FontAwesomeIcons.shieldHalved,
                      titre: 'Politique de confidentialité',
                      onTap: () => _ouvrirPage(
                        'Politique de confidentialité',
                        const SectionParametresProfil(),
                      ),
                    ),
                    _ElementMenu(
                      icone: FontAwesomeIcons.headset,
                      titre: 'Support et assistance',
                      onTap: () => _ouvrirPage(
                        'Support et assistance',
                        const SectionParametresProfil(),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              _BlocProfil(
                enfants: [
                  _ElementMenu(
                    icone: FontAwesomeIcons.rightFromBracket,
                    titre: 'Déconnexion',
                    couleur: Colors.red,
                    onTap: _deconnecter,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NouvelEnteteProfil extends StatelessWidget {
  const _NouvelEnteteProfil({
    required this.profil,
    required this.cheminPhoto,
    required this.onChoisirPhoto,
  });
  final EtudiantProfil profil;
  final String? cheminPhoto;
  final VoidCallback onChoisirPhoto;

  @override
  Widget build(BuildContext context) {
    final photoValide = cheminPhoto != null && File(cheminPhoto!).existsSync();
    final modeSombre = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: modeSombre ? Colors.black : Colors.white,
          ),
          child: CircleAvatar(
            radius: MediaQuery.sizeOf(context).width >= 600 ? 50 : 44,
            backgroundColor: modeSombre
                ? Colors.black
                : const Color(0xFFE5E7EB),
            backgroundImage: photoValide ? FileImage(File(cheminPhoto!)) : null,
            child: photoValide
                ? null
                : FaIcon(
                    FontAwesomeIcons.user,
                    color: modeSombre ? Colors.white : Colors.black,
                    size: 48,
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          profil.nomComplet,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onChoisirPhoto,
          icon: const FaIcon(FontAwesomeIcons.camera, size: 17),
          label: Text(photoValide ? 'Changer la photo' : 'Choisir une photo'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
          ),
        ),
      ],
    );
  }
}

class _BlocProfil extends StatelessWidget {
  const _BlocProfil({required this.enfants, this.titre}) : sousTitre = null;
  final String? titre;
  final String? sousTitre;
  final List<Widget> enfants;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(12, 11, 12, 5),
    decoration: BoxDecoration(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF242424)
          : const Color(0xFFF4F4F4),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titre != null)
          Text(
            titre!,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        if (sousTitre != null) ...[
          const SizedBox(height: 3),
          Text(
            sousTitre!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF718096), fontSize: 12),
          ),
        ],
        if (titre != null || sousTitre != null) const SizedBox(height: 4),
        for (var index = 0; index < enfants.length; index++) ...[
          enfants[index],
          if (index < enfants.length - 1)
            Divider(
              height: 1,
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: .35),
            ),
        ],
      ],
    ),
  );
}

// ignore: unused_element
class _EnteteProfil extends StatelessWidget {
  const _EnteteProfil({
    required this.profil,
    required this.cheminPhoto,
    required this.onChoisirPhoto,
  });

  final EtudiantProfil profil;
  final String? cheminPhoto;
  final VoidCallback onChoisirPhoto;

  @override
  Widget build(BuildContext context) {
    final margeSuperieure = MediaQuery.paddingOf(context).top;
    final modeTablette = MediaQuery.sizeOf(context).width >= 600;
    final rayonPhoto = modeTablette ? 58.0 : 52.0;
    final debutZoneBlanche = margeSuperieure + 96;
    final positionNom = margeSuperieure + 42 + (rayonPhoto * 2);

    return SizedBox(
      width: double.infinity,
      height: margeSuperieure + (modeTablette ? 226 : 214),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: debutZoneBlanche + 24,
            child: const ColoredBox(color: Color(0xFFFF7417)),
          ),
          Positioned(
            top: debutZoneBlanche,
            left: 0,
            right: 0,
            bottom: 0,
            child: const ColoredBox(color: Colors.white),
          ),
          Positioned(
            top: margeSuperieure + 18,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 15,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: rayonPhoto,
                    backgroundColor: const Color(0xFFFF7417),
                    backgroundImage: cheminPhoto == null
                        ? null
                        : FileImage(File(cheminPhoto!)),
                    child: cheminPhoto == null
                        ? Text(
                            profil.initiales,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: modeTablette ? 38 : 34,
                              fontWeight: FontWeight.w900,
                            ),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  right: 3,
                  bottom: 7,
                  child: IconButton(
                    tooltip: 'Modifier la photo de profil',
                    constraints: const BoxConstraints.tightFor(
                      width: 38,
                      height: 38,
                    ),
                    padding: EdgeInsets.zero,
                    iconSize: 22,
                    onPressed: onChoisirPhoto,
                    icon: const FaIcon(
                      FontAwesomeIcons.upload,
                      size: 19,
                      color: Colors.white,
                      // shadows: [Shadow(color: Colors.black54, blurRadius: 5)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: positionNom,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Text(
                  profil.nomComplet,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF0D0D0D),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Etudiant - ${profil.niveau}',
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _AncienEnteteProfil extends StatelessWidget {
  const _AncienEnteteProfil({
    required this.profil,
    required this.cheminPhoto,
    required this.onChoisirPhoto,
  });
  final EtudiantProfil profil;
  final String? cheminPhoto;
  final VoidCallback onChoisirPhoto;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.fromLTRB(
      20,
      MediaQuery.paddingOf(context).top + 18,
      20,
      24,
    ),
    color: const Color.fromARGB(255, 0, 0, 0),
    child: Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              foregroundColor: Colors.white,
              radius: 48,
              backgroundColor: const Color(0xFFFF7417),
              backgroundImage: cheminPhoto == null
                  ? null
                  : FileImage(File(cheminPhoto!)),
              child: cheminPhoto == null
                  ? Text(
                      profil.initiales,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  : null,
            ),
            Positioned(
              right: 2,
              bottom: 0,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 17,
                  onPressed: onChoisirPhoto,
                  icon: const FaIcon(
                    FontAwesomeIcons.upload,
                    size: 16,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          profil.nomComplet,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFF7417),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            'ÉTUDIANT ${profil.niveau.toUpperCase()}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}

// ignore: unused_element
class _CarteUniversite extends StatelessWidget {
  const _CarteUniversite({required this.profil});
  final EtudiantProfil profil;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      title: const Text(
        'Université',
        style: TextStyle(color: Color(0xFF718096), fontSize: 12),
      ),
      subtitle: Text(
        profil.etablissement,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
    ),
  );
}

// ignore: unused_element
class _CarteConnexion extends StatelessWidget {
  const _CarteConnexion({required this.profil, required this.onModifier});
  final EtudiantProfil profil;
  final VoidCallback onModifier;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Moyens de connexion',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          _LigneConnexion(titre: 'Matricule', valeur: profil.matricule),
          const Divider(),
          _LigneConnexion(titre: 'Email', valeur: profil.email),
          const Divider(),
          _LigneConnexion(
            titre: 'Téléphone',
            valeur: profil.telephone,
            onModifier: onModifier,
          ),
        ],
      ),
    ),
  );
}

class _LigneConnexion extends StatelessWidget {
  const _LigneConnexion({
    required this.titre,
    required this.valeur,
    this.onModifier,
  }) : badge = null;
  final String titre;
  final String valeur;
  final String? badge;
  final VoidCallback? onModifier;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titre,
              style: const TextStyle(color: Color(0xFF718096), fontSize: 12),
            ),
            Text(valeur, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
      if (badge != null)
        Chip(label: Text(badge!))
      else
        TextButton(onPressed: onModifier, child: const Text('Modifier')),
    ],
  );
}

class _ElementMenu extends StatelessWidget {
  const _ElementMenu({
    required this.icone,
    required this.titre,
    required this.onTap,
    this.couleur,
    this.valeur,
  });
  final FaIconData icone;
  final String titre;
  final VoidCallback onTap;
  final Color? couleur;
  final String? valeur;
  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    dense: true,
    visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
    minVerticalPadding: 5,
    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    leading: FaIcon(
      icone,
      size: 20,
      color:
          couleur ??
          (Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : const Color(0xFF172B4D)),
    ),
    title: Text(
      titre,
      style: TextStyle(
        color: couleur,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
    trailing: valeur == null
        ? FaIcon(
            FontAwesomeIcons.chevronRight,
            color:
                couleur ??
                (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : null),
          )
        : Text(
            valeur!,
            style: const TextStyle(
              color: Color(0xFF718096),
              fontWeight: FontWeight.w600,
            ),
          ),
  );
}
