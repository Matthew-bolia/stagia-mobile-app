import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../core/services/preference_onboarding.dart';
import '../../../../core/widgets/auth_brand.dart';
import '../../../../core/widgets/contenu_adaptatif.dart';
import '../../../authentication/presentation/pages/connexion_page.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';

class EcranDemarrage extends StatefulWidget {
  const EcranDemarrage({super.key});

  @override
  State<EcranDemarrage> createState() => _EcranDemarrageState();
}

// les déclarations que j'ai fais pour pour les composants qui se trouvent dans le splash screen.
class _EcranDemarrageState extends State<EcranDemarrage> {
  static const _dureeAffichage = Duration(seconds: 8);
  // Modifiez ces trois valeurs pour ajuster facilement le logo du splash.
  static const _ratioLargeurLogo = 0.52;
  static const _largeurLogoMinimale = 130.0;
  static const _largeurLogoMaximale = 210.0;

  Timer? _minuterie;

  @override
  void initState() {
    super.initState();
    _minuterie = Timer(_dureeAffichage, _ouvrirApplication);
  }

  Future<void> _ouvrirApplication() async {
    if (!mounted) return;

    final onboardingTermine = await const PreferenceOnboarding().estTerminee();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, animation, secondaryAnimation) =>
            onboardingTermine ? const ConnexionPage() : const OnboardingPage(),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  void dispose() {
    _minuterie?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery donne les dimensions réelles du téléphone.
    final tailleEcran = MediaQuery.sizeOf(context);
    final largeurLogo = (tailleEcran.width * _ratioLargeurLogo)
        .clamp(_largeurLogoMinimale, _largeurLogoMaximale)
        .toDouble();
    final tailleChargement = (tailleEcran.width * 0.15)
        .clamp(44.0, 64.0)
        .toDouble();
    final margeBasseChargement = (tailleEcran.height * 0.06)
        .clamp(28.0, 56.0)
        .toDouble();

    return Scaffold(
      backgroundColor: Colors.black,
      body: ContenuAdaptatif(
        largeurMaximale: 600,
        enfant: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              Center(
                child: SizedBox(
                  width: largeurLogo,
                  child: AuthBrand(largeur: largeurLogo),
                ),
              ),
              Positioned(
                bottom: margeBasseChargement,
                child: SpinKitFadingCircle(
                  color: Colors.white,
                  size: tailleChargement,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
