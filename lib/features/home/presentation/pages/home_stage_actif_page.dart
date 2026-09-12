import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'home_shared_widgets.dart';

class HomeStageActifPage extends StatelessWidget {
  const HomeStageActifPage({required this.donnees, super.key});

  final Map<String, dynamic> donnees;

  @override
  Widget build(BuildContext context) {
    final marge = MediaQuery.sizeOf(context).width < 360 ? 14.0 : 18.0;
    final stage = mapApi(donnees['current_stage']);
    final stats = mapApi(donnees['stats']);
    final paiementEffectue =
        stats['payment_paid'] == true ||
        stats['payment_status']?.toString().toUpperCase() == 'PAYE';

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(marge, 16, marge, 28),
      children: [
        stage.isEmpty
            ? const _CarteVide('Aucun stage actuel.')
            : _CarteStage(stage),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _Indicateur(
                'assets/icons/candidature.png',
                '${stats['applications'] ?? 0}',
                'Candidatures',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Indicateur(
                'assets/icons/stage_en_cours.png',
                '${stats['active_stages'] ?? stats['stages'] ?? 0}',
                'Stage en cours',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Indicateur(
                paiementEffectue
                    ? 'assets/icons/paiement_effectue.png'
                    : 'assets/icons/paiement.png',
                paiementEffectue ? 'Payé' : 'Non payé',
                'Paiements',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _Statut(
          'Présence quotidienne',
          '${stage['taux_presence'] ?? 0}%',
          'assets/icons/presence.png',
        ),
        const SizedBox(height: 12),
        _Statut(
          'Note',
          stage['note_finale'] == null
              ? 'Pas disponible'
              : '${stage['note_finale']}',
          'assets/icons/note.png',
        ),
        const SizedBox(height: 12),
        _Statut(
          'Documents envoyés',
          '${stats['documents'] ?? 0}',
          'assets/icons/documents.png',
        ),
      ],
    );
  }
}

class _CarteStage extends StatelessWidget {
  const _CarteStage(this.stage);

  final Map<String, dynamic> stage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jours = _joursRestants(stage['date_fin']);
    final unite = stage['unit_name']?.toString() ?? 'STAGE';
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surface.withValues(alpha: .9),
                const Color(0xFFDDF4F2).withValues(alpha: .62),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFF7417), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'STAGE EN COURS',
                style: TextStyle(
                  color: Color(0xFF00AFA3),
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      stage['hospital_name']?.toString() ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        height: 1.28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF17264C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        unite.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const FaIcon(
                    FontAwesomeIcons.calendarDays,
                    color: Color(0xFF718096),
                    size: 16,
                  ),
                  const SizedBox(width: 9),
                  Text(
                    jours == null
                        ? 'Durée non disponible'
                        : '$jours jours restants',
                    style: const TextStyle(color: Color(0xFF718096)),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progressionStage(
                    stage['date_debut'],
                    stage['date_fin'],
                  ),
                  minHeight: 7,
                  color: const Color(0xFF0CB5A8),
                  backgroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Indicateur extends StatelessWidget {
  const _Indicateur(this.cheminIcone, this.valeur, this.libelle);

  final String cheminIcone;
  final String valeur;
  final String libelle;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 134),
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFFF7417)),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          cheminIcone,
          width: 34,
          height: 34,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const SizedBox(
            width: 34,
            height: 34,
            child: Icon(Icons.image_not_supported_outlined),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          valeur,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: valeur.length > 4 ? 15 : 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          libelle,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFF718096), fontSize: 11),
        ),
      ],
    ),
  );
}

class _Statut extends StatelessWidget {
  const _Statut(this.titre, this.valeur, this.cheminIcone);

  final String titre;
  final String valeur;
  final String cheminIcone;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 92),
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFFF7417)),
    ),
    child: Row(
      children: [
        Image.asset(
          cheminIcone,
          width: 36,
          height: 36,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const SizedBox(
            width: 36,
            height: 36,
            child: Icon(Icons.image_not_supported_outlined),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '$titre : '),
                TextSpan(
                  text: valeur,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _CarteVide extends StatelessWidget {
  const _CarteVide(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(message, textAlign: TextAlign.center),
  );
}

int? _joursRestants(Object? valeur) {
  final fin = DateTime.tryParse(valeur?.toString() ?? '');
  if (fin == null) return null;
  final aujourdHui = DateTime.now();
  final debutJour = DateTime(aujourdHui.year, aujourdHui.month, aujourdHui.day);
  final finJour = DateTime(fin.year, fin.month, fin.day);
  final jours = finJour.difference(debutJour).inDays;
  return jours < 0 ? 0 : jours;
}

double _progressionStage(Object? debutValeur, Object? finValeur) {
  final debut = DateTime.tryParse(debutValeur?.toString() ?? '');
  final fin = DateTime.tryParse(finValeur?.toString() ?? '');
  if (debut == null || fin == null || !fin.isAfter(debut)) return 0;
  final total = fin.difference(debut).inMilliseconds;
  final effectue = DateTime.now().difference(debut).inMilliseconds;
  return (effectue / total).clamp(0.0, 1.0).toDouble();
}
