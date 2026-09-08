import 'package:flutter/material.dart';

class AuthBrand extends StatelessWidget {
  const AuthBrand({
    this.largeur = 250,
    this.hauteur,
    this.ajustement = BoxFit.contain,
    super.key,
  });

  static const cheminLogo = 'assets/images/logo_stagia_auth_orange.png';
  static const _cheminLogoSecours =
      'assets/images/logo_stagia.png'; // celui-ci est pour le sphash screen
  final double largeur;
  final double? hauteur;
  final BoxFit ajustement;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      cheminLogo,
      width: largeur,
      height: hauteur,
      fit: ajustement,
      semanticLabel: 'Logo STAGIA',
      errorBuilder: (context, erreur, trace) {
        return Image.asset(
          _cheminLogoSecours,
          width: largeur,
          height: hauteur,
          fit: ajustement,
          semanticLabel: 'Logo STAGIA',
        );
      },
    );
  }
}
