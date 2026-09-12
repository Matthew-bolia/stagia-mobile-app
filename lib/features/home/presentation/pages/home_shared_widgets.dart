import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/services/photo_profil_service.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../messagerie/presentation/messages_page.dart';

class EnTeteAccueil extends StatelessWidget implements PreferredSizeWidget {
  const EnTeteAccueil({required this.etudiant, this.superviseur, super.key});

  final Map<String, dynamic> etudiant;
  final Map<String, String>? superviseur;

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    final nom = etudiant['nom']?.toString() ?? '';
    final prenom = etudiant['prenom']?.toString() ?? '';
    final modeSombre = Theme.of(context).brightness == Brightness.dark;
    final nomComplet = [
      prenom,
      nom,
    ].where((element) => element.isNotEmpty).join(' ');

    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          AnimatedBuilder(
            animation: PhotoProfilService.instance,
            builder: (_, _) {
              final photo = PhotoProfilService.instance.cheminPhoto;
              final photoValide = photo != null && File(photo).existsSync();
              return CircleAvatar(
                radius: 26,
                backgroundColor: modeSombre
                    ? Colors.black
                    : const Color(0xFFE5E7EB),
                backgroundImage: photoValide ? FileImage(File(photo)) : null,
                child: !photoValide
                    ? const FaIcon(
                        FontAwesomeIcons.user,
                        color: Color(0xFF9CA3AF),
                        size: 24,
                      )
                    : null,
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              nomComplet.isEmpty ? 'Étudiant' : nomComplet,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
          IconButton(
            tooltip: 'Messages',
            onPressed: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute<void>(
                builder: (_) => MessagesPage(
                  compte:
                      (etudiant['uuid'] ??
                              etudiant['stagia_code'] ??
                              etudiant['matricule'] ??
                              etudiant['email'] ??
                              'local')
                          .toString(),
                  superviseurId: superviseur?['id'],
                  superviseurNom: superviseur?['nom'],
                ),
              ),
            ),
            icon: FaIcon(
              FontAwesomeIcons.message,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            iconSize: 20,
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute<void>(
                builder: (_) => const NotificationsPage(),
              ),
            ),
            icon: FaIcon(
              FontAwesomeIcons.bell,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}

class ErreurAccueil extends StatelessWidget {
  const ErreurAccueil({required this.onReessayer, super.key});

  final VoidCallback onReessayer;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const FaIcon(
          FontAwesomeIcons.cloudArrowDown,
          color: Color(0xFF718096),
          size: 40,
        ),
        const SizedBox(height: 12),
        const Text('Impossible de charger les données.'),
        TextButton(onPressed: onReessayer, child: const Text('Réessayer')),
      ],
    ),
  );
}

Map<String, dynamic> mapApi(Object? valeur) =>
    valeur is Map ? Map<String, dynamic>.from(valeur) : <String, dynamic>{};

List<Map<String, dynamic>> listeApi(Object? valeur) => valeur is List
    ? valeur.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : <Map<String, dynamic>>[];

int entierApi(Object? valeur) => valeur is num
    ? valeur.toInt()
    : int.tryParse(valeur?.toString() ?? '') ?? 0;
