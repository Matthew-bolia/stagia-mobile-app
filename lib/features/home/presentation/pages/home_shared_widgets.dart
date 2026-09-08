import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/services/photo_profil_service.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';

class EnTeteAccueil extends StatelessWidget implements PreferredSizeWidget {
  const EnTeteAccueil({required this.etudiant, super.key});

  final Map<String, dynamic> etudiant;

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
                    ? Icon(
                        Icons.person_rounded,
                        color: modeSombre ? Colors.white : Colors.black,
                        size: 30,
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
            tooltip: 'Notifications',
            onPressed: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute<void>(
                builder: (_) => const NotificationsPage(),
              ),
            ),
            icon: const Icon(Icons.notifications_none_rounded),
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
        const Icon(
          Icons.cloud_off_outlined,
          size: 48,
          color: Color(0xFFFF7417),
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
