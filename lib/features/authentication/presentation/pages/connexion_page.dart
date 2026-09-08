import 'package:flutter/material.dart';
import 'package:stagia/features/authentication/presentation/widgets/en_tete_authentification.dart';
import '../../../../app/navigation/main_shell.dart';
import '../../../../core/network/client_api_http.dart';
import '../../../../core/network/configuration_api.dart';
import '../../../../core/network/reponse_api.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/session_authentification_service.dart';
import '../../data/datasources/source_authentification_distante.dart';
import '../widgets/champ_authentification.dart';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  final _cleFormulaire = GlobalKey<FormState>();
  final _identifiant = TextEditingController();
  final _motDePasse = TextEditingController();
  final _sourceAuthentification = SourceAuthentificationDistante(
    ClientApiHttp(),
  );
  bool _motDePasseMasque = true;
  bool _connexionEnCours = false;
  String? _erreurMotDePasse;
  String? _erreurIdentifiant;

  @override
  void dispose() {
    _identifiant.dispose();
    _motDePasse.dispose();
    super.dispose();
  }

  Future<void> _seConnecter() async {
    setState(() {
      _erreurIdentifiant = null;
      _erreurMotDePasse = null;
    });
    if (!(_cleFormulaire.currentState?.validate() ?? false)) return;

    if (!ConfigurationApi.utiliserAuthentificationApi) {
      if (_connexionEnCours) return;
      FocusScope.of(context).unfocus();
      setState(() => _connexionEnCours = true);
      await Future<void>.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF16803C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),

          content: Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text('Connexion réussie.'),
            ],
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const MainShell()),
      );
      if (mounted) setState(() => _connexionEnCours = false);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _connexionEnCours = true);

    try {
      final session = await _sourceAuthentification.connecter(
        identifiant: _identifiant.text.trim(),
        motDePasse: _motDePasse.text,
      );
      await SessionAuthentificationService.enregistrer(session);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF16803C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          content: Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text('Connexion réussie.'),
            ],
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const MainShell()),
      );
    } on ErreurApi catch (erreur) {
      if (!mounted) return;
      if (_erreurReseau(erreur)) {
        _afficherMessage(_messageErreurConnexion(erreur), erreur: true);
      } else {
        setState(() {
          if (_erreurConcerneIdentifiant(erreur)) {
            _erreurIdentifiant = _messageErreurConnexion(erreur);
          } else {
            _erreurMotDePasse = _messageErreurConnexion(erreur);
          }
        });
      }
    } catch (_) {
      if (!mounted) return;
      _afficherMessage(
        'Connexion impossible. Vérifiez votre connexion internet.',
      );
    } finally {
      if (mounted) setState(() => _connexionEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tailleEcran = MediaQuery.sizeOf(context);
    final clavierOuvert = MediaQuery.viewInsetsOf(context).bottom > 0;
    final petitEcran = tailleEcran.height < 700;
    final modeTablette = tailleEcran.width >= 600;
    final margeHorizontale = tailleEcran.width < 360 ? 16.0 : 24.0;

    return Theme(
      // Les écrans d'authentification conservent volontairement leur design clair,
      // même lorsque le reste de l'application utilise le thème sombre.
      data: AppTheme.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, contraintes) {
              final margeVerticale = petitEcran ? 12.0 : 24.0;
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: petitEcran || clavierOuvert
                    ? const ClampingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  margeHorizontale,
                  margeVerticale,
                  margeHorizontale,
                  margeVerticale,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: contraintes.maxHeight - (margeVerticale * 2),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: modeTablette ? 420 : 480,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const EnTeteAuthentification(titre: 'Connexion'),
                          SizedBox(height: petitEcran ? 18 : 26),
                          SizedBox(
                            width: double.infinity,
                            child: _carteFormulaire(),
                          ),
                          SizedBox(height: petitEcran ? 22 : 32),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _carteFormulaire() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: _decorationCarte,
      child: Form(
        key: _cleFormulaire,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChampAuthentification(
              controleur: _identifiant,
              libelle: 'E-mail ou matricule',
              indication: 'Entrez votre identifiant',
              icone: Icons.person_outline_rounded,
              typeClavier: TextInputType.text,
              onChanged: (_) {
                if (_erreurIdentifiant != null) {
                  setState(() => _erreurIdentifiant = null);
                }
              },
              validateur: (valeur) =>
                  _erreurIdentifiant ?? _identifiantValide(valeur),
            ),
            const SizedBox(height: 14),
            ChampAuthentification(
              controleur: _motDePasse,
              libelle: 'Mot de passe',
              indication: 'Entrez votre mot de passe',
              icone: Icons.lock_outline_rounded,
              masquerTexte: _motDePasseMasque,
              actionSuffixe: () =>
                  setState(() => _motDePasseMasque = !_motDePasseMasque),
              iconeSuffixe: _motDePasseMasque
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              onChanged: (_) {
                if (_erreurMotDePasse != null) {
                  setState(() => _erreurMotDePasse = null);
                }
              },
              validateur: _motDePasseValide,
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _connexionEnCours ? null : _motDePasseOublie,
                child: const Text('Mot de passe oublié ?'),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width >= 600
                      ? 320
                      : double.infinity,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: _connexionEnCours ? null : _seConnecter,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0D0D0D),
                      shape: const StadiumBorder(),
                    ),
                    child: _connexionEnCours
                        ? const SizedBox.square(
                            dimension: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Se connecter',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _decorationCarte = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(22)),
    boxShadow: [
      BoxShadow(
        color: Color(0x12000000),
        blurRadius: 22,
        offset: Offset(0, 10),
      ),
    ],
  );

  static String? _champObligatoire(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) {
      return 'Ce champ est obligatoire';
    }
    return null;
  }

  static String? _emailValide(String? valeur) {
    final erreur = _champObligatoire(valeur);
    if (erreur != null) return erreur;
    final email = valeur!.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Entrez une adresse e-mail valide';
    }
    return null;
  }

  static String? _identifiantValide(String? valeur) {
    final identifiant = valeur?.trim() ?? '';
    if (identifiant.isEmpty) return 'Ce champ est obligatoire';
    return identifiant.contains('@')
        ? _emailValide(identifiant)
        : _matriculeValide(identifiant);
  }

  static String? _matriculeValide(String? valeur) {
    final erreur = _champObligatoire(valeur);
    if (erreur != null) return erreur;
    if (valeur!.trim().length < 3) return 'Entrez un matricule valide';
    return null;
  }

  String? _motDePasseValide(String? valeur) =>
      _erreurMotDePasse ?? _champObligatoire(valeur);

  Future<void> _motDePasseOublie() async {
    final identifiant = _identifiant.text.trim();
    final erreur = _identifiantValide(identifiant);
    if (erreur != null) {
      setState(() => _erreurIdentifiant = erreur);
      return;
    }

    final confirmation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mot de passe oublié ?'),
        content: Text(
          'Un lien de réinitialisation sera envoyé pour « $identifiant ».',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
    if (confirmation != true || !mounted) return;

    try {
      await _sourceAuthentification.demanderReinitialisation(identifiant);
      if (!mounted) return;
      _afficherMessage('Le lien de réinitialisation a été envoyé.');
    } on ErreurApi catch (erreur) {
      if (!mounted) return;
      _afficherMessage(erreur.message, erreur: true);
    } catch (_) {
      if (!mounted) return;
      _afficherMessage(
        'Impossible de contacter le serveur. Vérifiez votre connexion internet.',
        erreur: true,
      );
    }
  }

  void _afficherMessage(String message, {bool erreur = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor: erreur
            ? const Color(0xFFB3261E)
            : const Color(0xFF16803C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(message),
      ),
    );
  }

  static bool _erreurConcerneIdentifiant(ErreurApi erreur) {
    final message = erreur.message.toLowerCase();
    return message.contains('identifiant') ||
        message.contains('email') ||
        message.contains('e-mail') ||
        message.contains('matricule');
  }

  static bool _erreurReseau(ErreurApi erreur) => const {
    'DELAI_DEPASSE',
    'SERVEUR_INJOIGNABLE',
    'SERVEUR_NGROK_HORS_LIGNE',
    'URL_API_ABSENTE',
    'REPONSE_INVALIDE',
  }.contains(erreur.code);

  static String _messageErreurConnexion(ErreurApi erreur) {
    if (erreur.code == 'DELAI_DEPASSE') {
      return 'Vérifiez votre connexion internet.';
    }
    if (erreur.code == 'SERVEUR_INJOIGNABLE' ||
        erreur.code == 'SERVEUR_NGROK_HORS_LIGNE') {
      return 'Impossible de se connecter';
    }
    final message = erreur.message.toLowerCase();
    if ((erreur.code == 'CONNEXION_REFUSEE' ||
            erreur.code == 'HTTP_401' ||
            erreur.code == 'HTTP_403') &&
        (message.contains('password') ||
            message.contains('mot de passe') ||
            message.contains('credential'))) {
      return 'Identifiant ou mot de passe incorrect.';
    }
    if (erreur.code == 'CONNEXION_REFUSEE' ||
        erreur.code == 'HTTP_401' ||
        erreur.code == 'HTTP_403') {
      return 'Identifiant ou mot de passe incorrect.';
    }
    if (erreur.code == 'CONNEXION_REFUSEE' &&
        (message.contains('email') ||
            message.contains('e-mail') ||
            message.contains('identifiant'))) {
      return 'Identifiant incorrect.';
    }
    return erreur.message.isEmpty
        ? 'Identifiant ou mot de passe incorrect.'
        : erreur.message;
  }
}
