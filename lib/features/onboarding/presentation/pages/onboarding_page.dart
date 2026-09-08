import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/preference_onboarding.dart';
import '../../../../core/widgets/contenu_adaptatif.dart';
import '../../../authentication/presentation/pages/connexion_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _pages = [
    _ContenuPage(
      imageFond: 'assets/images/onb1.jpg',
      iconeSecours: Icons.travel_explore_rounded,
      premiereLigne: 'Trouvez votre stage',
      deuxiemeLigne: 'Simplement et rapidement',
      description:
          'Découvrez des opportunités adaptées à votre formation et suivez vos candidatures.',
    ),
    _ContenuPage(
      imageFond: 'assets/images/onb2.jpg',
      iconeSecours: Icons.workspace_premium_rounded,
      premiereLigne: 'Suivez votre parcours',
      deuxiemeLigne: 'Valorisez vos compétences',
      description:
          'Journal, évaluations et attestations réunis dans votre dossier numérique.',
    ),
  ];

  final _controleurPages = PageController();
  final _preference = const PreferenceOnboarding();
  int _indexActuel = 0;

  bool get _estDernierePage => _indexActuel == _pages.length - 1;

  @override
  void dispose() {
    _controleurPages.dispose();
    super.dispose();
  }

  Future<void> _terminer() async {
    await _preference.terminer();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const ConnexionPage()),
    );
  }

  void _suivant() {
    if (_estDernierePage) {
      _terminer();
      return;
    }

    _controleurPages.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tailleEcran = MediaQuery.sizeOf(context);
    final margeIndicateur = tailleEcran.width < 360 ? 14.0 : 18.0;
    final positionIndicateur = tailleEcran.height < 700 ? 8.0 : 12.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: ContenuAdaptatif(
        largeurMaximale: 600,
        enfant: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _controleurPages,
              itemCount: _pages.length,
              onPageChanged: (index) => setState(() => _indexActuel = index),
              itemBuilder: (context, index) {
                return _PageOnboarding(
                  contenu: _pages[index],
                  estActive: index == _indexActuel,
                  estDernierePage: index == _pages.length - 1,
                  onBoutonPresse: _suivant,
                );
              },
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    margeIndicateur,
                    positionIndicateur,
                    margeIndicateur,
                    0,
                  ),
                  child: Row(
                    children: List.generate(_pages.length, (index) {
                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 3,
                          margin: EdgeInsets.only(
                            right: index == _pages.length - 1 ? 0 : 7,
                          ),
                          decoration: BoxDecoration(
                            color: index <= _indexActuel
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.38),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageOnboarding extends StatefulWidget {
  const _PageOnboarding({
    required this.contenu,
    required this.estActive,
    required this.estDernierePage,
    required this.onBoutonPresse,
  });

  static const orange = Color(0xFFFF7417);
  final _ContenuPage contenu;
  final bool estActive;
  final bool estDernierePage;
  final VoidCallback onBoutonPresse;

  @override
  State<_PageOnboarding> createState() => _PageOnboardingState();
}

class _PageOnboardingState extends State<_PageOnboarding>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controleur;
  late final Animation<double> _image;
  late final Animation<double> _formeUne;
  late final Animation<double> _formeDeux;
  late final Animation<double> _description;
  late final Animation<double> _bouton;
  bool _animationJouee = false;

  @override
  void initState() {
    super.initState();
    _controleur = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _image = _intervalle(0, 0.45);
    _formeUne = _intervalle(0, 0.42);
    _formeDeux = _intervalle(0.15, 0.58);
    _description = _intervalle(0.42, 0.80);
    _bouton = _intervalle(0.68, 1);
    // Le post-frame garantit que l'animation de la toute première image est
    // visible dès l'ouverture de l'onboarding.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _demarrerSiNecessaire();
    });
  }

  Animation<double> _intervalle(double debut, double fin) {
    return CurvedAnimation(
      parent: _controleur,
      curve: Interval(debut, fin, curve: Curves.easeOutCubic),
    );
  }

  void _demarrerSiNecessaire() {
    if (widget.estActive && !_animationJouee) {
      _animationJouee = true;
      _controleur.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _PageOnboarding oldWidget) {
    super.didUpdateWidget(oldWidget);
    _demarrerSiNecessaire();
  }

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tailleEcran = MediaQuery.sizeOf(context);
    final petitEcran = tailleEcran.height < 700 || tailleEcran.width < 360;
    final margeHorizontale = tailleEcran.width < 360 ? 16.0 : 20.0;
    final largeurDescription = (tailleEcran.width * 0.82)
        .clamp(260.0, 330.0)
        .toDouble();
    final tailleDescription = (tailleEcran.width * 0.043)
        .clamp(14.0, 17.0)
        .toDouble();
    final hauteurBouton = (tailleEcran.height * 0.07)
        .clamp(48.0, 56.0)
        .toDouble();

    return Stack(
      fit: StackFit.expand,
      children: [
        FadeTransition(
          opacity: _image,
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.08, end: 1).animate(_image),
            child: Image.asset(
              widget.contenu.imageFond,
              fit: BoxFit.contain,
              alignment: Alignment.center,
              errorBuilder: (context, erreur, trace) {
                return _FondDeSecours(icone: widget.contenu.iconeSecours);
              },
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x26000000), Color(0x10000000), Color(0xB8000000)],
              stops: [0, 0.45, 1],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              margeHorizontale,
              petitEcran ? 38 : 50,
              margeHorizontale,
              petitEcran ? 14 : 22,
            ),
            child: Column(
              children: [
                Spacer(flex: petitEcran ? 5 : 6),
                _EntreeAnimee(
                  progression: _formeUne,
                  positionInitiale: const Offset(-0.9, 0),
                  child: _BanniereOrange(
                    texte: widget.contenu.premiereLigne,
                    angle: -0.035,
                  ),
                ),
                SizedBox(height: petitEcran ? 3 : 5),
                _EntreeAnimee(
                  progression: _formeDeux,
                  positionInitiale: const Offset(0.9, 0),
                  child: _BanniereOrange(
                    texte: widget.contenu.deuxiemeLigne,
                    angle: 0.025,
                  ),
                ),
                SizedBox(height: petitEcran ? 18 : 30),
                _EntreeAnimee(
                  progression: _description,
                  positionInitiale: const Offset(0, 0.35),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: largeurDescription),
                    child: Text(
                      widget.contenu.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: tailleDescription,
                        height: petitEcran ? 1.25 : 1.4,
                        fontWeight: FontWeight.w500,
                        shadows: const [
                          Shadow(color: Colors.black54, blurRadius: 8),
                        ],
                      ),
                    ),
                  ),
                ),
                Spacer(flex: petitEcran ? 1 : 2),
                _EntreeAnimee(
                  progression: _bouton,
                  positionInitiale: const Offset(0, 0.45),
                  child: SizedBox(
                    width: double.infinity,
                    height: hauteurBouton,
                    child: FilledButton(
                      onPressed: widget.onBoutonPresse,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          255,
                          255,
                          255,
                        ),
                        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text(
                        widget.estDernierePage ? 'Commencer' : 'Suivant',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EntreeAnimee extends StatelessWidget {
  const _EntreeAnimee({
    required this.progression,
    required this.positionInitiale,
    required this.child,
  });

  final Animation<double> progression;
  final Offset positionInitiale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: progression,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: positionInitiale,
          end: Offset.zero,
        ).animate(progression),
        child: child,
      ),
    );
  }
}

class _BanniereOrange extends StatelessWidget {
  const _BanniereOrange({required this.texte, required this.angle});

  final String texte;
  final double angle;

  @override
  Widget build(BuildContext context) {
    final largeurEcran = MediaQuery.sizeOf(context).width;
    final petitEcran = largeurEcran < 360;
    final tailleTexte = (largeurEcran * 0.075).clamp(23.0, 30.0).toDouble();

    return Transform.rotate(
      angle: angle,
      child: Container(
        constraints: BoxConstraints(maxWidth: largeurEcran * 0.88),
        padding: EdgeInsets.symmetric(
          horizontal: petitEcran ? 14 : 22,
          vertical: petitEcran ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: _PageOnboarding.orange,
          borderRadius: BorderRadius.circular(2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55000000),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          texte,
          textAlign: TextAlign.center,
          style: GoogleFonts.caveat(
            color: const Color.fromARGB(255, 0, 0, 0),
            fontSize: tailleTexte,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _FondDeSecours extends StatelessWidget {
  const _FondDeSecours({required this.icone});

  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C2635), Color(0xFF0A0D12)],
        ),
      ),
      child: Center(child: Icon(icone, size: 150, color: Colors.white24)),
    );
  }
}

class _ContenuPage {
  const _ContenuPage({
    required this.imageFond,
    required this.iconeSecours,
    required this.premiereLigne,
    required this.deuxiemeLigne,
    required this.description,
  });

  final String imageFond;
  final IconData iconeSecours;
  final String premiereLigne;
  final String deuxiemeLigne;
  final String description;
}
