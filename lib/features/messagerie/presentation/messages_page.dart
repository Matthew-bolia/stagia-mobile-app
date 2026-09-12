import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/widgets/contenu_adaptatif.dart';
import '../data/messagerie_locale.dart';

const _orange = Color(0xFFFF7417);

class MessagesPage extends StatefulWidget {
  const MessagesPage({
    required this.compte,
    this.superviseurId,
    this.superviseurNom,
    super.key,
  });
  final String compte;
  final String? superviseurId;
  final String? superviseurNom;
  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage>
    with SingleTickerProviderStateMixin {
  late final MessagerieLocale _stockage = MessagerieLocale(widget.compte);
  late final TabController _onglets;
  List<DiscussionLocale> _discussions = [];
  bool _charge = false;
  bool _erreur = false;
  int _ongletActuel = 0;
  @override
  void initState() {
    super.initState();
    _onglets = TabController(length: 5, vsync: this);
    _onglets.addListener(() {
      if (!_onglets.indexIsChanging && mounted) {
        setState(() => _ongletActuel = _onglets.index);
      }
    });
    _charger();
  }

  @override
  void dispose() {
    _onglets.dispose();
    super.dispose();
  }

  Future<void> _charger() async {
    try {
      final liste = await _stockage.charger();
      if (mounted) {
        setState(() {
          _discussions = liste;
          _charge = true;
          _erreur = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _charge = true;
          _erreur = true;
        });
      }
    }
  }

  Future<void> _nouvelleDiscussion() async {
    final resultat = await Navigator.of(context).push<_NouvelEchange>(
      MaterialPageRoute<_NouvelEchange>(
        builder: (_) => _NouvelleDiscussionPage(
          superviseurId: widget.superviseurId,
          superviseurNom: widget.superviseurNom,
        ),
      ),
    );
    if (resultat == null || !mounted) return;

    final discussion = DiscussionLocale(
      id: 'echange-${resultat.destinataire.id}-${DateTime.now().microsecondsSinceEpoch}',
      titre: resultat.titre,
      objet: resultat.objet,
      destinataireNom: resultat.destinataire.nom,
      destinataireRole: resultat.destinataire.role,
    );
    _discussions.insert(0, discussion);
    try {
      await _stockage.enregistrer(_discussions);
    } catch (_) {
      _discussions.remove(discussion);
      if (mounted) _alerte(context, 'Impossible de créer cette discussion.');
      return;
    }
    if (!mounted) return;
    setState(() {});
    await _ouvrir(discussion);
  }

  Future<void> _ouvrirParametres() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => _PreferencesMessageriePage(stockage: _stockage),
    ),
  );

  Widget _etatVide() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Aucune discussion.\nAppuyez sur + pour créer un nouvel échange.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> _ouvrir(DiscussionLocale discussion) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _DiscussionPage(
          discussion: discussion,
          stockage: _stockage,
          sauvegarder: () => _stockage.enregistrer(_discussions),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    final liste = List<DiscussionLocale>.from(_discussions)
      ..sort(
        (a, b) =>
            (b.messages.isEmpty
                    ? b.id
                    : b.messages.last.date.microsecondsSinceEpoch.toString())
                .compareTo(
                  a.messages.isEmpty
                      ? a.id
                      : a.messages.last.date.microsecondsSinceEpoch.toString(),
                ),
      );
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Discussions',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Préférences de notification',
            onPressed: _ouvrirParametres,
            icon: FaIcon(
              FontAwesomeIcons.sliders,
              size: 19,
              color: couleurs.onSurfaceVariant,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _onglets,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: _orange,
          labelColor: couleurs.onSurface,
          unselectedLabelColor: couleurs.onSurfaceVariant,
          tabs: const [
            Tab(text: 'Messagerie'),
            Tab(text: 'Communication'),
            Tab(text: 'Espace'),
            Tab(text: 'Forums'),
            Tab(text: 'Visio'),
          ],
        ),
      ),
      body: ContenuAdaptatif(
        largeurMaximale: 680,
        enfant: TabBarView(
          controller: _onglets,
          children: [
            !_charge
                ? const Center(child: CircularProgressIndicator())
                : _erreur
                ? Center(
                    child: TextButton(
                      onPressed: _charger,
                      child: const Text('Chargement impossible. Réessayer'),
                    ),
                  )
                : liste.isEmpty
                ? _etatVide()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 90),
                    itemCount: liste.length,
                    itemBuilder: (_, i) {
                      final d = liste[i];
                      final m = d.messages.isEmpty ? null : d.messages.last;
                      final destinataire = d.destinataireNom.isEmpty
                          ? 'Superviseur'
                          : d.destinataireNom;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: couleurs.surfaceContainerHighest,
                          foregroundColor: couleurs.onSurface,
                          child: const FaIcon(
                            FontAwesomeIcons.message,
                            size: 17,
                          ),
                        ),
                        title: Text(
                          destinataire,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          m?.texte ??
                              '${d.titre}${d.objet.isEmpty ? '' : ' · ${d.objet}'}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          m == null ? 'Local' : _heure(m.date),
                          style: TextStyle(
                            color: couleurs.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        onTap: () => _ouvrir(d),
                      );
                    },
                  ),
            const _EtatRubrique(
              titre: 'Aucune communication publiée',
              description:
                  'Les communications de votre université et de votre hôpital affecté apparaîtront ici en lecture seule.',
              icone: FontAwesomeIcons.bullhorn,
            ),
            const _EtatRubrique(
              titre: 'Aucun espace disponible',
              description:
                  'Vos espaces institutionnels et groupes de collaboration apparaîtront ici.',
              icone: FontAwesomeIcons.peopleGroup,
            ),
            const _EtatRubrique(
              titre: 'Aucune question publiée',
              description:
                  'Les questions des forums et de la FAQ auxquelles vous pouvez répondre apparaîtront ici.',
              icone: FontAwesomeIcons.comments,
            ),
            const _EtatRubrique(
              titre: 'Aucune visioconférence planifiée',
              description:
                  'Les liens vers Google Meet ou une autre plateforme apparaîtront ici.',
              icone: FontAwesomeIcons.video,
            ),
          ],
        ),
      ),
      floatingActionButton: _charge && !_erreur && _ongletActuel == 0
          ? FloatingActionButton(
              backgroundColor: _orange,
              foregroundColor: Colors.white,
              onPressed: _nouvelleDiscussion,
              tooltip: 'Nouvelle discussion',
              child: const FaIcon(FontAwesomeIcons.plus, size: 20),
            )
          : null,
    );
  }
}

class _EtatRubrique extends StatelessWidget {
  const _EtatRubrique({
    required this.titre,
    required this.description,
    required this.icone,
  });

  final String titre;
  final String description;
  final FaIconData icone;

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 430),
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: couleurs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: couleurs.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icone, size: 28, color: _orange),
            const SizedBox(height: 14),
            Text(
              titre,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(color: couleurs.onSurfaceVariant, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreferencesMessageriePage extends StatefulWidget {
  const _PreferencesMessageriePage({required this.stockage});

  final MessagerieLocale stockage;

  @override
  State<_PreferencesMessageriePage> createState() =>
      _PreferencesMessageriePageState();
}

class _PreferencesMessageriePageState
    extends State<_PreferencesMessageriePage> {
  PreferencesMessagerieLocale _preferences =
      const PreferencesMessagerieLocale();
  bool _chargement = true;
  bool _enregistrement = false;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    try {
      final preferences = await widget.stockage.chargerPreferences();
      if (mounted) setState(() => _preferences = preferences);
    } catch (_) {
      if (mounted) _alerte(context, 'Impossible de charger les préférences.');
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  Future<void> _modifier(PreferencesMessagerieLocale nouvellesValeurs) async {
    if (_enregistrement) return;
    final anciennesValeurs = _preferences;
    setState(() {
      _preferences = nouvellesValeurs;
      _enregistrement = true;
    });
    try {
      await widget.stockage.enregistrerPreferences(nouvellesValeurs);
    } catch (_) {
      if (!mounted) return;
      setState(() => _preferences = anciennesValeurs);
      _alerte(context, 'Impossible d’enregistrer cette préférence.');
    } finally {
      if (mounted) setState(() => _enregistrement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Préférences de notification')),
      body: ContenuAdaptatif(
        largeurMaximale: 680,
        enfant: _chargement
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
                children: [
                  Text(
                    'Choisissez comment recevoir les notifications liées à vos messages et communications.',
                    style: TextStyle(
                      color: couleurs.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _OptionNotification(
                    titre: 'Par Push',
                    description: 'Afficher les nouvelles activités par Push.',
                    valeur: _preferences.parPush,
                    active: !_enregistrement,
                    onChange: (valeur) =>
                        _modifier(_preferences.copyWith(parPush: valeur)),
                  ),
                  const SizedBox(height: 10),
                  _OptionNotification(
                    titre: 'Par e-mail',
                    description:
                        'Recevoir une alerte sur votre adresse e-mail.',
                    valeur: _preferences.parEmail,
                    active: !_enregistrement,
                    onChange: (valeur) =>
                        _modifier(_preferences.copyWith(parEmail: valeur)),
                  ),
                  const SizedBox(height: 10),
                  _OptionNotification(
                    titre: 'Par SMS',
                    description:
                        'Recevoir une alerte sur votre numéro de téléphone.',
                    valeur: _preferences.parSms,
                    active: !_enregistrement,
                    onChange: (valeur) =>
                        _modifier(_preferences.copyWith(parSms: valeur)),
                  ),
                ],
              ),
      ),
    );
  }
}

class _OptionNotification extends StatelessWidget {
  const _OptionNotification({
    required this.titre,
    required this.description,
    required this.valeur,
    required this.active,
    required this.onChange,
  });

  final String titre;
  final String description;
  final bool valeur;
  final bool active;
  final ValueChanged<bool> onChange;

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
      decoration: BoxDecoration(
        color: couleurs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: couleurs.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    color: couleurs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: .82,
            child: Switch.adaptive(
              value: valeur,
              activeThumbColor: _orange,
              onChanged: active ? onChange : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _DestinataireLocal {
  const _DestinataireLocal({
    required this.id,
    required this.nom,
    required this.role,
  });

  final String id;
  final String nom;
  final String role;
}

class _CategorieDestinataires {
  const _CategorieDestinataires({
    required this.id,
    required this.titre,
    required this.contacts,
  });

  final String id;
  final String titre;
  final List<_DestinataireLocal> contacts;
}

class _NouvelEchange {
  const _NouvelEchange({
    required this.titre,
    required this.objet,
    required this.destinataire,
  });

  final String titre;
  final String objet;
  final _DestinataireLocal destinataire;
}

class _NouvelleDiscussionPage extends StatefulWidget {
  const _NouvelleDiscussionPage({
    required this.superviseurId,
    required this.superviseurNom,
  });

  final String? superviseurId;
  final String? superviseurNom;

  @override
  State<_NouvelleDiscussionPage> createState() =>
      _NouvelleDiscussionPageState();
}

class _NouvelleDiscussionPageState extends State<_NouvelleDiscussionPage> {
  final _formulaire = GlobalKey<FormState>();
  final _titre = TextEditingController();
  final _objet = TextEditingController();
  _DestinataireLocal? _destinataire;

  List<_CategorieDestinataires> get _categories {
    final id = widget.superviseurId?.trim();
    final nom = widget.superviseurNom?.trim();
    final superviseur =
        id != null && id.isNotEmpty && nom != null && nom.isNotEmpty
        ? _DestinataireLocal(
            id: id,
            nom: nom,
            role: 'Superviseur de stage · Hôpital affecté',
          )
        : const _DestinataireLocal(
            id: 'superviseur',
            nom: 'Superviseur de stage',
            role: 'Hôpital affecté',
          );

    const chefDepartement = _DestinataireLocal(
      id: 'responsable-chef-departement',
      nom: 'Dr Matthew Kabila',
      role: 'Cheffe de département',
    );
    const doyen = _DestinataireLocal(
      id: 'responsable-doyen',
      nom: 'Prof. Alain Bolia',
      role: 'Doyen de la faculté',
    );
    const serviceStages = _DestinataireLocal(
      id: 'responsable-service-stages',
      nom: 'Service des stages',
      role: 'Responsable universitaire autorisé',
    );
    const responsableHopital = _DestinataireLocal(
      id: 'responsable-hopital',
      nom: 'Bureau des stages hospitaliers',
      role: 'Responsable de l’hôpital affecté',
    );

    return [
      const _CategorieDestinataires(
        id: 'etablissement',
        titre: 'Étudiants de mon établissement',
        contacts: [
          _DestinataireLocal(
            id: 'etudiant-etablissement-1',
            nom: 'Grâce Mbala',
            role: 'Étudiante du même établissement',
          ),
          _DestinataireLocal(
            id: 'etudiant-etablissement-2',
            nom: 'Patrick Ilunga',
            role: 'Étudiant du même établissement',
          ),
        ],
      ),
      const _CategorieDestinataires(
        id: 'faculte',
        titre: 'Étudiants de ma faculté',
        contacts: [
          _DestinataireLocal(
            id: 'etudiant-faculte-1',
            nom: 'Sarah Kanku',
            role: 'Étudiante de la même faculté',
          ),
          _DestinataireLocal(
            id: 'etudiant-faculte-2',
            nom: 'David Ilunga',
            role: 'Étudiant de la même faculté',
          ),
        ],
      ),
      const _CategorieDestinataires(
        id: 'annee',
        titre: 'Étudiants de mon année',
        contacts: [
          _DestinataireLocal(
            id: 'etudiant-annee-1',
            nom: 'Marie Kabeya',
            role: 'Étudiante de la même année',
          ),
          _DestinataireLocal(
            id: 'etudiant-annee-2',
            nom: 'Jonathan Nsenga',
            role: 'Étudiant de la même année',
          ),
        ],
      ),
      const _CategorieDestinataires(
        id: 'responsables-universitaires',
        titre: 'Responsables universitaires',
        contacts: [chefDepartement, doyen, serviceStages],
      ),
      _CategorieDestinataires(
        id: 'responsables-autorises',
        titre: 'Tous les responsables autorisés',
        contacts: [
          chefDepartement,
          doyen,
          serviceStages,
          responsableHopital,
          superviseur,
        ],
      ),
      _CategorieDestinataires(
        id: 'responsables-hopitaux',
        titre: 'Responsables des hôpitaux',
        contacts: [superviseur, responsableHopital],
      ),
    ];
  }

  Future<void> _ouvrirCategorie(_CategorieDestinataires categorie) async {
    final contact = await showModalBottomSheet<_DestinataireLocal>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .72,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                child: Text(
                  categorie.titre,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                  itemCount: categorie.contacts.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final contact = categorie.contacts[index];
                    return ListTile(
                      title: Text(
                        contact.nom,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(contact.role),
                      trailing: const FaIcon(
                        FontAwesomeIcons.chevronRight,
                        size: 14,
                      ),
                      onTap: () => Navigator.pop(context, contact),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (contact == null || !mounted) return;
    setState(() => _destinataire = contact);
    if (_formulaire.currentState?.validate() ?? false) {
      _soumettre();
    } else {
      _alerte(context, 'Contact sélectionné. Complétez le titre et l’objet.');
    }
  }

  @override
  void dispose() {
    _titre.dispose();
    _objet.dispose();
    super.dispose();
  }

  void _soumettre() {
    if (!(_formulaire.currentState?.validate() ?? false)) return;
    final destinataire = _destinataire;
    if (destinataire == null) {
      _alerte(context, 'Choisissez un destinataire.');
      return;
    }
    Navigator.pop(
      context,
      _NouvelEchange(
        titre: _titre.text.trim(),
        objet: _objet.text.trim(),
        destinataire: destinataire,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle discussion')),
      body: ContenuAdaptatif(
        largeurMaximale: 680,
        enfant: Form(
          key: _formulaire,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
            children: [
              TextFormField(
                controller: _titre,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Titre de la discussion',
                ),
                validator: (valeur) => valeur?.trim().isEmpty == true
                    ? 'Saisissez le titre de la discussion.'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _objet,
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Objet',
                  hintText: 'Précisez le sujet de votre échange',
                ),
                validator: (valeur) => valeur?.trim().isEmpty == true
                    ? 'Saisissez l’objet de la discussion.'
                    : null,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: couleurs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 10),
              for (final categorie in _categories)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: couleurs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: couleurs.outlineVariant),
                  ),
                  child: ListTile(
                    title: Text(
                      categorie.titre,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${categorie.contacts.length} contact${categorie.contacts.length > 1 ? 's' : ''}',
                    ),
                    trailing: const FaIcon(
                      FontAwesomeIcons.chevronRight,
                      size: 14,
                    ),
                    onTap: () => _ouvrirCategorie(categorie),
                  ),
                ),
              if (_destinataire != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: couleurs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _orange),
                  ),
                  child: Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.solidCircleCheck,
                        color: _orange,
                        size: 19,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _destinataire!.nom,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              _destinataire!.role,
                              style: TextStyle(
                                color: couleurs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.center,
                child: FilledButton(
                  onPressed: _soumettre,
                  style: FilledButton.styleFrom(
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                  ),
                  child: const Text('Commencer la discussion'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscussionPage extends StatefulWidget {
  const _DiscussionPage({
    required this.discussion,
    required this.stockage,
    required this.sauvegarder,
  });
  final DiscussionLocale discussion;
  final MessagerieLocale stockage;
  final Future<void> Function() sauvegarder;
  @override
  State<_DiscussionPage> createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<_DiscussionPage>
    with WidgetsBindingObserver {
  final _texte = TextEditingController();
  final _scroll = ScrollController();
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  StreamSubscription<void>? _finLecture;
  StreamSubscription<Duration>? _positionLecture;
  StreamSubscription<Duration>? _dureeLecture;
  Timer? _timer;
  bool _occupe = false, _enregistrement = false;
  int _secondes = 0;
  String? _vocal, _lecture, _audioCharge, _audioGlisse;
  Duration _positionAudio = Duration.zero;
  Duration _dureeAudio = Duration.zero;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _texte.addListener(_actualiserSaisie);
    _finLecture = _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _lecture = null;
          _audioCharge = null;
          _positionAudio = Duration.zero;
        });
      }
    });
    _positionLecture = _player.onPositionChanged.listen((position) {
      if (mounted && _audioGlisse == null) {
        setState(() => _positionAudio = position);
      }
    });
    _dureeLecture = _player.onDurationChanged.listen((duree) {
      if (mounted) setState(() => _dureeAudio = duree);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (_enregistrement && !_occupe) _action(_arreter);
      _player.pause();
      if (mounted) setState(() => _lecture = null);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _finLecture?.cancel();
    _positionLecture?.cancel();
    _dureeLecture?.cancel();
    _recorder.dispose();
    _player.dispose();
    _texte.removeListener(_actualiserSaisie);
    _texte.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _actualiserSaisie() {
    if (mounted) setState(() {});
  }

  Future<void> _action(Future<void> Function() operation) async {
    if (_occupe) return;
    setState(() => _occupe = true);
    try {
      await operation();
    } catch (_) {
      if (mounted) {
        _alerte(
          context,
          'Impossible de terminer cette action. Vérifiez le fichier et les autorisations.',
        );
      }
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  Future<void> _ajouter(MessageLocal message) async {
    widget.discussion.messages.add(message);
    try {
      await widget.sauvegarder();
    } catch (_) {
      widget.discussion.messages.remove(message);
      rethrow;
    }
    if (!mounted) return;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _envoyerTexte() async {
    final texte = _texte.text.trim();
    if (texte.isEmpty) return;
    await _ajouter(
      MessageLocal(type: 'texte', texte: texte, date: DateTime.now()),
    );
    if (mounted) _texte.clear();
  }

  Future<void> _joindre(String type) async {
    String? chemin;
    String nom = 'Photo';
    if (type == 'photo') {
      final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      chemin = image?.path;
      nom = image?.name ?? nom;
    } else if (type == 'image') {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      chemin = image?.path;
      nom = image?.name ?? nom;
    } else {
      final fichiers = await FilePicker.pickFiles();
      if (fichiers.isNotEmpty) {
        chemin = fichiers.first.path;
        nom = fichiers.first.name;
      }
    }
    if (chemin == null || !mounted) return;
    final accord = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          type == 'photo'
              ? 'Envoyer la photo'
              : type == 'image'
              ? 'Envoyer l’image'
              : 'Envoyer le document',
        ),
        content: Text(nom),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
    if (accord != true) return;
    final copie = await widget.stockage.copier(chemin);
    await _ajouter(
      MessageLocal(
        type: type == 'document' ? 'document' : 'photo',
        texte: nom,
        date: DateTime.now(),
        chemin: copie,
      ),
    );
  }

  Future<void> _demarrer() async {
    if (!await _recorder.hasPermission()) {
      if (mounted) {
        _alerte(context, 'Autorisez le microphone pour enregistrer un vocal.');
      }
      return;
    }
    await _player.stop();
    final dossier = await getTemporaryDirectory();
    await _recorder.start(
      const RecordConfig(),
      path:
          '${dossier.path}/vocal_${DateTime.now().microsecondsSinceEpoch}.m4a',
    );
    if (!mounted) {
      await _recorder.cancel();
      return;
    }
    setState(() {
      _enregistrement = true;
      _secondes = 0;
      _lecture = null;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _secondes++);
    });
  }

  Future<void> _arreter() async {
    _timer?.cancel();
    final path = await _recorder.stop();
    if (mounted) {
      setState(() {
        _enregistrement = false;
        _vocal = path;
      });
    }
  }

  Future<void> _annuler() async {
    _timer?.cancel();
    if (_enregistrement) await _recorder.cancel();
    await _player.stop();
    if (mounted) {
      setState(() {
        _enregistrement = false;
        _vocal = null;
        _lecture = null;
      });
    }
  }

  Future<void> _envoyerVocal() async {
    final path = _vocal;
    if (path == null) return;
    final copie = await widget.stockage.copier(path);
    await _ajouter(
      MessageLocal(
        type: 'vocal',
        texte: 'Message vocal · ${_duree(_secondes)}',
        date: DateTime.now(),
        chemin: copie,
      ),
    );
    if (mounted) setState(() => _vocal = null);
  }

  Future<void> _lire(String chemin) async {
    if (_lecture == chemin) {
      await _player.pause();
      if (mounted) setState(() => _lecture = null);
    } else if (_audioCharge == chemin) {
      await _player.resume();
      if (mounted) setState(() => _lecture = chemin);
    } else {
      await _player.stop();
      _positionAudio = Duration.zero;
      _dureeAudio = Duration.zero;
      await _player.play(DeviceFileSource(chemin));
      if (mounted) {
        setState(() {
          _audioCharge = chemin;
          _lecture = chemin;
        });
      }
    }
  }

  Future<void> _deplacerLecture(String chemin, Duration position) async {
    if (_audioCharge != chemin) {
      await _player.stop();
      await _player.setSource(DeviceFileSource(chemin));
      _audioCharge = chemin;
      _lecture = null;
      _dureeAudio = await _player.getDuration() ?? Duration.zero;
    }
    await _player.seek(position);
    if (mounted) setState(() => _positionAudio = position);
  }

  Future<void> _terminerDeplacement(String chemin, Duration position) async {
    try {
      await _deplacerLecture(chemin, position);
    } finally {
      if (mounted) setState(() => _audioGlisse = null);
    }
  }

  Future<void> _ouvrir(String path) async {
    final resultat = await OpenFilex.open(path);
    if (resultat.type != ResultType.done) throw StateError(resultat.message);
  }

  Future<void> _ouvrirImage(String path) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.88,
            maxHeight: MediaQuery.of(context).size.height * 0.84,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: 'Fermer',
                    onPressed: () => Navigator.pop(ctx),
                    icon: FaIcon(FontAwesomeIcons.xmark),
                  ),
                ),
                Flexible(
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 3,
                    child: Image.file(
                      File(path),
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Text(
                        'Image inaccessible',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _afficherActionsMessage(int index) async {
    final message = widget.discussion.messages[index];
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Actions du message',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            if (message.type == 'texte')
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.pen, size: 18),
                title: const Text('Modifier'),
                onTap: () => Navigator.pop(context, 'modifier'),
              ),
            ListTile(
              leading: const FaIcon(
                FontAwesomeIcons.trash,
                size: 18,
                color: Color(0xFFD92D20),
              ),
              title: const Text(
                'Supprimer',
                style: TextStyle(color: Color(0xFFD92D20)),
              ),
              onTap: () => Navigator.pop(context, 'supprimer'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (action == 'modifier') {
      await _modifierMessage(index);
    } else if (action == 'supprimer') {
      await _supprimerMessage(index);
    }
  }

  Future<void> _modifierMessage(int index) async {
    final ancien = widget.discussion.messages[index];
    final controleur = TextEditingController(text: ancien.texte);
    final nouveauTexte = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le message'),
        content: TextField(
          controller: controleur,
          autofocus: true,
          minLines: 1,
          maxLines: 2,
          decoration: const InputDecoration(hintText: 'Votre message'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              final texte = controleur.text.trim();
              if (texte.isNotEmpty) Navigator.pop(context, texte);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    controleur.dispose();
    if (nouveauTexte == null || !mounted) return;

    widget.discussion.messages[index] = MessageLocal(
      type: ancien.type,
      texte: nouveauTexte,
      date: ancien.date,
      chemin: ancien.chemin,
    );
    try {
      await widget.sauvegarder();
      if (mounted) setState(() {});
    } catch (_) {
      widget.discussion.messages[index] = ancien;
      if (mounted) _alerte(context, 'Impossible de modifier le message.');
    }
  }

  Future<void> _supprimerMessage(int index) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le message ?'),
        content: const Text(
          'Cette action supprimera définitivement le message.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Oui'),
          ),
        ],
      ),
    );
    if (confirmation != true || !mounted) return;

    final supprime = widget.discussion.messages.removeAt(index);
    try {
      if (_audioCharge == supprime.chemin) {
        await _player.stop();
        _lecture = null;
        _audioCharge = null;
        _positionAudio = Duration.zero;
        _dureeAudio = Duration.zero;
      }
      await widget.sauvegarder();
      final chemin = supprime.chemin;
      if (chemin != null) {
        try {
          final fichier = File(chemin);
          if (await fichier.exists()) await fichier.delete();
        } on FileSystemException {
          // Le message reste supprimé même si Android conserve temporairement
          // le fichier local verrouillé par un autre lecteur.
        }
      }
      if (mounted) setState(() {});
    } catch (_) {
      widget.discussion.messages.insert(index, supprime);
      if (mounted) _alerte(context, 'Impossible de supprimer le message.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? couleurs.surface
          : const Color(0xFFFFF5EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.discussion.titre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (widget.discussion.destinataireNom.isNotEmpty)
              Text(
                widget.discussion.destinataireNom,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: couleurs.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
      body: ContenuAdaptatif(
        largeurMaximale: 680,
        enfant: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: ColoredBox(
            color: couleurs.surface,
            child: Column(
              children: [
                if (widget.discussion.objet.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: couleurs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Objet : ${widget.discussion.objet}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                Expanded(
                  child: widget.discussion.messages.isEmpty
                      ? const Center(
                          child: Text(
                            'Écrivez votre message.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          controller: _scroll,
                          padding: const EdgeInsets.all(18),
                          itemCount: widget.discussion.messages.length,
                          itemBuilder: (_, i) {
                            final m = widget.discussion.messages[i];
                            final precedent = i == 0
                                ? null
                                : widget.discussion.messages[i - 1].date;
                            return Column(
                              children: [
                                if (precedent == null ||
                                    _date(precedent) != _date(m.date))
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    child: Text(
                                      _date(m.date),
                                      style: TextStyle(
                                        color: couleurs.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.sizeOf(context).width *
                                          (m.type == 'vocal' ? .62 : .76),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onLongPress:
                                              m.type == 'texte' ||
                                                  m.type == 'vocal' ||
                                                  m.type == 'photo' ||
                                                  m.type == 'document'
                                              ? () => _afficherActionsMessage(i)
                                              : null,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 9,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _orange,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: m.type == 'texte'
                                                ? Text(
                                                    m.texte,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      height: 1.45,
                                                    ),
                                                  )
                                                : m.type == 'photo'
                                                ? InkWell(
                                                    onTap: () => _action(
                                                      () => _ouvrirImage(
                                                        m.chemin!,
                                                      ),
                                                    ),
                                                    child: Image.file(
                                                      File(m.chemin!),
                                                      height: 150,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, _, _) =>
                                                          const Text(
                                                            'Photo inaccessible',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                    ),
                                                  )
                                                : m.type == 'vocal'
                                                ? Row(
                                                    children: [
                                                      IconButton(
                                                        tooltip:
                                                            'Lire ou mettre en pause',
                                                        visualDensity:
                                                            VisualDensity
                                                                .compact,
                                                        padding:
                                                            EdgeInsets.zero,
                                                        constraints:
                                                            const BoxConstraints(
                                                              minWidth: 34,
                                                              minHeight: 34,
                                                            ),
                                                        onPressed: _occupe
                                                            ? null
                                                            : () => _action(
                                                                () => _lire(
                                                                  m.chemin!,
                                                                ),
                                                              ),
                                                        icon: FaIcon(
                                                          _lecture == m.chemin
                                                              ? FontAwesomeIcons
                                                                    .pause
                                                              : FontAwesomeIcons
                                                                    .play,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Builder(
                                                          builder: (context) {
                                                            final actif =
                                                                _audioCharge ==
                                                                    m.chemin ||
                                                                _audioGlisse ==
                                                                    m.chemin;
                                                            final dureeStockee =
                                                                _dureeVocale(
                                                                  m.texte,
                                                                );
                                                            final duree =
                                                                actif &&
                                                                    _dureeAudio >
                                                                        Duration
                                                                            .zero
                                                                ? _dureeAudio
                                                                : dureeStockee;
                                                            final position =
                                                                actif
                                                                ? _positionAudio
                                                                : Duration.zero;
                                                            final maximum = duree
                                                                .inMilliseconds
                                                                .clamp(
                                                                  1,
                                                                  86400000,
                                                                )
                                                                .toDouble();
                                                            final valeur = position
                                                                .inMilliseconds
                                                                .clamp(
                                                                  0,
                                                                  maximum
                                                                      .toInt(),
                                                                )
                                                                .toDouble();
                                                            return Column(
                                                              children: [
                                                                SizedBox(
                                                                  height: 28,
                                                                  child: SliderTheme(
                                                                    data: SliderTheme.of(context).copyWith(
                                                                      activeTrackColor:
                                                                          Colors
                                                                              .white,
                                                                      inactiveTrackColor:
                                                                          Colors
                                                                              .white54,
                                                                      thumbColor:
                                                                          Colors
                                                                              .white,
                                                                      overlayColor:
                                                                          Colors
                                                                              .white24,
                                                                      trackHeight:
                                                                          2,
                                                                      thumbShape:
                                                                          const RoundSliderThumbShape(
                                                                            enabledThumbRadius:
                                                                                5,
                                                                          ),
                                                                    ),
                                                                    child: Slider(
                                                                      value:
                                                                          valeur,
                                                                      max:
                                                                          maximum,
                                                                      onChanged:
                                                                          _occupe
                                                                          ? null
                                                                          : (
                                                                              nouvelleValeur,
                                                                            ) {
                                                                              setState(
                                                                                () => _positionAudio = Duration(
                                                                                  milliseconds: nouvelleValeur.round(),
                                                                                ),
                                                                              );
                                                                            },
                                                                      onChangeStart:
                                                                          _occupe
                                                                          ? null
                                                                          : (
                                                                              _,
                                                                            ) {
                                                                              setState(
                                                                                () {
                                                                                  if (_audioCharge !=
                                                                                      m.chemin) {
                                                                                    _positionAudio = Duration.zero;
                                                                                  }
                                                                                  _audioGlisse = m.chemin;
                                                                                },
                                                                              );
                                                                            },
                                                                      onChangeEnd:
                                                                          _occupe
                                                                          ? null
                                                                          : (
                                                                              nouvelleValeur,
                                                                            ) => _action(
                                                                              () => _terminerDeplacement(
                                                                                m.chemin!,
                                                                                Duration(
                                                                                  milliseconds: nouvelleValeur.round(),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      _duree(
                                                                        position
                                                                            .inSeconds,
                                                                      ),
                                                                      style: const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            10,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      _duree(
                                                                        duree
                                                                            .inSeconds,
                                                                      ),
                                                                      style: const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            10,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Row(
                                                    children: [
                                                      IconButton(
                                                        tooltip:
                                                            'Ouvrir le document',
                                                        visualDensity:
                                                            VisualDensity
                                                                .compact,
                                                        onPressed: _occupe
                                                            ? null
                                                            : () => _action(
                                                                () => _ouvrir(
                                                                  m.chemin!,
                                                                ),
                                                              ),
                                                        icon: const FaIcon(
                                                          FontAwesomeIcons.file,
                                                          color: Colors.white,
                                                          size: 18,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          m.texte,
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            8,
                                            6,
                                            8,
                                            16,
                                          ),
                                          child: Text(
                                            '${_heure(m.date)} · Envoyé',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: couleurs.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
                if (_enregistrement || _vocal != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Annuler le vocal',
                          onPressed: _occupe ? null : () => _action(_annuler),
                          icon: FaIcon(
                            FontAwesomeIcons.xmark,
                            size: 20,
                            color: couleurs.onSurfaceVariant,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${_enregistrement ? 'Enregistrement' : 'Vocal prêt'} · ${_duree(_secondes)}',
                          ),
                        ),
                        if (_vocal != null)
                          IconButton(
                            tooltip: 'Écouter le vocal',
                            onPressed: _occupe
                                ? null
                                : () => _action(() => _lire(_vocal!)),
                            icon: FaIcon(
                              _lecture == _vocal
                                  ? FontAwesomeIcons.pause
                                  : FontAwesomeIcons.play,
                            ),
                          ),
                        IconButton(
                          tooltip: _enregistrement ? 'Arrêter' : 'Envoyer',
                          onPressed: _occupe
                              ? null
                              : () => _action(
                                  _enregistrement ? _arreter : _envoyerVocal,
                                ),
                          icon: FaIcon(
                            _enregistrement
                                ? FontAwesomeIcons.stop
                                : FontAwesomeIcons.paperPlane,
                            color: _orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
                    child: Row(
                      children: [
                        PopupMenuButton<String>(
                          enabled:
                              !_occupe && !_enregistrement && _vocal == null,
                          tooltip: 'Ajouter une pièce jointe',
                          icon: FaIcon(
                            FontAwesomeIcons.paperclip,
                            size: 18,
                            color: couleurs.onSurfaceVariant,
                          ),
                          onSelected: (type) => _action(() => _joindre(type)),
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'photo',
                              child: Row(
                                children: [
                                  FaIcon(FontAwesomeIcons.camera, size: 18),
                                  SizedBox(width: 12),
                                  Text('Prendre une photo'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'image',
                              child: Row(
                                children: [
                                  FaIcon(FontAwesomeIcons.image, size: 18),
                                  SizedBox(width: 12),
                                  Text('Importer une image'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'document',
                              child: Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.fileArrowUp,
                                    size: 18,
                                  ),
                                  SizedBox(width: 12),
                                  Text('Importer un document'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: TextField(
                            controller: _texte,
                            enabled:
                                !_occupe && !_enregistrement && _vocal == null,
                            minLines: 1,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Message…',
                              filled: true,
                              fillColor: couleurs.surfaceContainerLow,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color: couleurs.onSurface,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color: couleurs.onSurface,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color: couleurs.onSurface,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Enregistrer un vocal',
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.all(7),
                          constraints: const BoxConstraints(
                            minWidth: 38,
                            minHeight: 38,
                          ),
                          onPressed:
                              _occupe || _enregistrement || _vocal != null
                              ? null
                              : () => _action(_demarrer),
                          icon: FaIcon(
                            FontAwesomeIcons.microphone,
                            size: 18,
                            color: couleurs.onSurfaceVariant,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Envoyer',
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.all(7),
                          constraints: const BoxConstraints(
                            minWidth: 38,
                            minHeight: 38,
                          ),
                          onPressed:
                              _occupe || _enregistrement || _vocal != null
                              ? null
                              : () => _action(_envoyerTexte),
                          icon: FaIcon(
                            FontAwesomeIcons.paperPlane,
                            size: 18,
                            color: _texte.text.trim().isEmpty
                                ? couleurs.onSurfaceVariant
                                : _orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _alerte(BuildContext context, String message) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
String _heure(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
String _date(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
String _duree(int secondes) =>
    '${(secondes ~/ 60).toString().padLeft(2, '0')}:${(secondes % 60).toString().padLeft(2, '0')}';

Duration _dureeVocale(String texte) {
  final correspondance = RegExp(r'(\d{2}):(\d{2})$').firstMatch(texte);
  if (correspondance == null) return Duration.zero;
  final minutes = int.tryParse(correspondance.group(1) ?? '') ?? 0;
  final secondes = int.tryParse(correspondance.group(2) ?? '') ?? 0;
  return Duration(minutes: minutes, seconds: secondes);
}
