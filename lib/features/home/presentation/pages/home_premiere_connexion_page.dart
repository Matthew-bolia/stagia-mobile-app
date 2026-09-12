import 'package:flutter/material.dart';
import '../../../../core/mocks/depot_mock_etudiant.dart';

class HomePremiereConnexionPage extends StatelessWidget {
  const HomePremiereConnexionPage({
    required this.campagnes,
    required this.candidatures,
    required this.onVoirCampagnes,
    super.key,
  });

  final List<Map<String, dynamic>> campagnes;
  final List<Map<String, dynamic>> candidatures;
  final VoidCallback? onVoirCampagnes;

  @override
  Widget build(BuildContext context) {
    final marge = MediaQuery.sizeOf(context).width < 360 ? 14.0 : 18.0;
    final modeSombre = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(marge, 16, marge, 28),
      children: [
        _CarteBienvenuePremiereConnexion(modeSombre: modeSombre),
        const SizedBox(height: 22),
        const Text(
          'Votre parcours de stage',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        _ParcoursDebutant(candidatures: candidatures),
        if (campagnes.isNotEmpty) ...[
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Campagnes disponibles',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ),
              TextButton(
                onPressed: onVoirCampagnes,
                child: const Text('Voir tout'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final campagne in campagnes.take(2))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CarteCampagne(
                campagne: campagne,
                onVoirCampagnes: onVoirCampagnes,
              ),
            ),
        ],
      ],
    );
  }
}

class _CarteBienvenuePremiereConnexion extends StatelessWidget {
  const _CarteBienvenuePremiereConnexion({required this.modeSombre});

  final bool modeSombre;

  @override
  Widget build(BuildContext context) {
    final fond = modeSombre ? const Color(0xFFFFCAA7) : const Color(0xFF050505);
    final couleurTexte = modeSombre ? Colors.black : Colors.white;
    final couleurCercle = modeSombre
        ? const Color(0xFFFF9D61)
        : const Color(0xFF5B2708);

    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: fond,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          children: [
            _CercleDecoratif(
              couleur: couleurCercle,
              taille: 58,
              haut: -14,
              gauche: -17,
            ),
            _CercleDecoratif(
              couleur: couleurCercle,
              taille: 92,
              bas: -38,
              gauche: 62,
            ),
            _CercleDecoratif(
              couleur: couleurCercle,
              taille: 72,
              haut: -30,
              droite: 58,
            ),
            _CercleDecoratif(
              couleur: couleurCercle,
              taille: 40,
              bas: 17,
              droite: 82,
            ),
            Positioned(
              left: 3,
              bottom: -6,
              width: 230, // Réduction de la taille du personnage
              height: 370,
              child: Image.asset(
                'assets/icons/welcome.png',
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(130, 16, 12, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Text(
                          'Bienvenue dans STAGIA',
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: couleurTexte,
                            fontFamily: 'Georgia',
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Votre espace est prêt. Consultez les campagnes publiées par votre université',
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: couleurTexte,
                        fontFamily: 'Georgia',
                        fontSize: 12,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CercleDecoratif extends StatelessWidget {
  const _CercleDecoratif({
    required this.couleur,
    required this.taille,
    this.haut,
    this.bas,
    this.gauche,
    this.droite,
  });

  final Color couleur;
  final double taille;
  final double? haut;
  final double? bas;
  final double? gauche;
  final double? droite;

  @override
  Widget build(BuildContext context) => Positioned(
    top: haut,
    bottom: bas,
    left: gauche,
    right: droite,
    child: Container(
      width: taille,
      height: taille,
      decoration: BoxDecoration(color: couleur, shape: BoxShape.circle),
    ),
  );
}

class _ParcoursDebutant extends StatelessWidget {
  const _ParcoursDebutant({required this.candidatures});

  final List<Map<String, dynamic>> candidatures;

  @override
  Widget build(BuildContext context) {
    final campagneConsultee =
        DepotMockEtudiant.campagnesConsultees || candidatures.isNotEmpty;
    final candidatureEnvoyee = candidatures.isNotEmpty;
    final admissionConfirmee = candidatures.any((candidature) {
      final statut = candidature['statut']?.toString().toUpperCase() ?? '';
      return const ['ACCEPTEE', 'AFFECTEE', 'ADMISE'].contains(statut);
    });

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const _EtapeParcours(titre: 'Inscription au portail', terminee: true),
          _EtapeParcours(
            titre: 'Consulter une campagne ouverte',
            terminee: campagneConsultee,
            active: !campagneConsultee,
          ),
          _EtapeParcours(
            titre: 'Envoyer une candidature',
            terminee: candidatureEnvoyee,
            active: campagneConsultee && !candidatureEnvoyee,
          ),
          _EtapeParcours(
            titre: 'Attendre l’admission',
            terminee: admissionConfirmee,
            active: candidatureEnvoyee && !admissionConfirmee,
          ),
          _EtapeParcours(
            titre: 'Commencer le stage',
            active: admissionConfirmee,
            derniere: true,
          ),
        ],
      ),
    );
  }
}

class _EtapeParcours extends StatelessWidget {
  const _EtapeParcours({
    required this.titre,
    this.terminee = false,
    this.active = false,
    this.derniere = false,
  });

  final String titre;
  final bool terminee;
  final bool active;
  final bool derniere;

  @override
  Widget build(BuildContext context) {
    final couleur = terminee || active
        ? const Color(0xFFFF7417)
        : const Color(0xFFDDE3EA);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: terminee
                        ? couleur
                        : Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: couleur, width: 2),
                  ),
                  child: terminee
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : active
                      ? const Center(
                          child: CircleAvatar(
                            radius: 4,
                            backgroundColor: Color(0xFFFF7417),
                          ),
                        )
                      : null,
                ),
                if (!derniere)
                  Expanded(
                    child: Container(width: 2, color: const Color(0xFFDDE3EA)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                titre,
                style: TextStyle(
                  color: terminee || active
                      ? Theme.of(context).colorScheme.onSurface
                      : const Color(0xFF98A2B3),
                  fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarteCampagne extends StatelessWidget {
  const _CarteCampagne({required this.campagne, required this.onVoirCampagnes});

  final Map<String, dynamic> campagne;
  final VoidCallback? onVoirCampagnes;

  @override
  Widget build(BuildContext context) {
    final titre =
        campagne['title']?.toString() ??
        campagne['campaign_title']?.toString() ??
        'Campagne de stage';
    final code = campagne['code']?.toString() ?? '';
    final places =
        campagne['available_places'] ?? campagne['places_disponibles'];
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titre, style: const TextStyle(fontWeight: FontWeight.w900)),
            if (code.isNotEmpty)
              Text(code, style: const TextStyle(color: Color(0xFF718096))),
            if (places != null) ...[
              const SizedBox(height: 7),
              Text('$places places disponibles'),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onVoirCampagnes,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Voir les campagnes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
