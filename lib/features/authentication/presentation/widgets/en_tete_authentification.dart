import 'package:flutter/material.dart';
import '../../../../core/widgets/auth_brand.dart';

class EnTeteAuthentification extends StatelessWidget {
  const EnTeteAuthentification({
    required this.titre,
    this.sousTitre,
    super.key,
  });

  final String titre;
  final String? sousTitre;

  @override
  Widget build(BuildContext context) {
    final tailleEcran = MediaQuery.sizeOf(context);
    final petitEcran = tailleEcran.height < 700 || tailleEcran.width < 360;
    final largeurLogo = (tailleEcran.width * 0.48)
        .clamp(145.0, 190.0)
        .toDouble();

    return Column(
      children: [
        AuthBrand(
          largeur: largeurLogo,
          hauteur: petitEcran ? 66 : 82,
          ajustement: BoxFit.contain,
        ),
        SizedBox(height: petitEcran ? 10 : 16),
        Text(
          titre,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: petitEcran ? 24 : 28,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF18233A),
          ),
        ),
        if (sousTitre != null) ...[
          const SizedBox(height: 8),
          Text(
            sousTitre!,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF718096)),
          ),
        ],
      ],
    );
  }
}
