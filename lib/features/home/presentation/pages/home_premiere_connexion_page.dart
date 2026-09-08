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
        Container(
          height: 164,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: modeSombre ? Colors.white : const Color(0xFF111111),
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 120,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/icons/welcome.png',
                      width: 144,
                      height: 120,
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenue dans STAGIA',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: modeSombre ? Colors.black : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Votre espace est prêt. Consultez les campagnes publiées par votre université.',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: modeSombre
                            ? const Color(0xFF4B5563)
                            : const Color(0xFFCACACA),
                        fontSize: 11.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
