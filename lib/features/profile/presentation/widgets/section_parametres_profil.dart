import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/preferences_application_service.dart';

class SectionParametresProfil extends StatelessWidget {
  const SectionParametresProfil({super.key});

  void _afficher(BuildContext context, String titre, String contenu) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titre,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            Text(contenu),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final preferences = context.watch<PreferencesApplicationService>();
    final couleurIcone = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return IconTheme(
      data: IconThemeData(color: couleurIcone),
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _BlocParametres(
            titre: 'Préférences',
            enfants: [
              _LigneInterrupteur(
                icone: FontAwesomeIcons.bell,
                titre: 'Recevoir les notifications',
                messageActive: 'Notifications activées.',
                messageInactive: 'Notifications désactivées.',
                valeur: preferences.notificationsAutorisees,
                onChanged: (valeur) async {
                  await context
                      .read<PreferencesApplicationService>()
                      .autoriserNotifications(valeur);
                },
              ),
              const Divider(height: 1),
              _LigneInterrupteur(
                icone: FontAwesomeIcons.moon,
                titre: 'Mode sombre',
                messageActive: 'Mode sombre activé.',
                messageInactive: 'Mode clair activé.',
                valeur: preferences.modeSombre,
                onChanged: (valeur) async {
                  await context
                      .read<PreferencesApplicationService>()
                      .activerModeSombre(valeur);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          _BlocParametres(
            titre: 'Support',
            enfants: [
              ListTile(
                onTap: () => _afficher(
                  context,
                  'Conditions d’utilisation',
                  'Les conditions d’utilisation de STAGIA seront publiées ici.',
                ),
                leading: const FaIcon(FontAwesomeIcons.fileLines, size: 18),
                title: const Text('Conditions d’utilisation'),
                trailing: const FaIcon(FontAwesomeIcons.chevronRight, size: 15),
              ),
              const Divider(height: 1),
              ListTile(
                onTap: () => _afficher(
                  context,
                  'Politique de confidentialité',
                  'La politique de traitement et de protection des données sera publiée ici.',
                ),
                leading: const FaIcon(FontAwesomeIcons.shieldHalved, size: 18),
                title: const Text('Politique de confidentialité'),
                trailing: const FaIcon(FontAwesomeIcons.chevronRight, size: 15),
              ),
              const Divider(height: 1),
              ListTile(
                onTap: () => _afficher(
                  context,
                  'Support et assistance',
                  'Contactez l’assistance STAGIA en cas de difficulté avec votre compte ou votre dossier.',
                ),
                leading: const FaIcon(FontAwesomeIcons.headset, size: 18),
                title: const Text('Support et assistance'),
                trailing: const FaIcon(FontAwesomeIcons.chevronRight, size: 15),
              ),
              const Divider(height: 1),
              const ListTile(
                leading: FaIcon(FontAwesomeIcons.circleInfo, size: 18),
                title: Text('Version de l’application'),
                trailing: Text('1.0.0'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LigneInterrupteur extends StatefulWidget {
  const _LigneInterrupteur({
    required this.icone,
    required this.titre,
    required this.valeur,
    required this.onChanged,
    required this.messageActive,
    required this.messageInactive,
  }) : sousTitre = null;

  final FaIconData icone;
  final String titre;
  final String? sousTitre;
  final bool valeur;
  final ValueChanged<bool> onChanged;
  final String messageActive;
  final String messageInactive;

  @override
  State<_LigneInterrupteur> createState() => _LigneInterrupteurState();
}

class _LigneInterrupteurState extends State<_LigneInterrupteur> {
  String? _message;
  Timer? _minuteurMessage;

  void _changer(bool valeur) {
    _minuteurMessage?.cancel();
    setState(
      () => _message = valeur ? widget.messageActive : widget.messageInactive,
    );
    widget.onChanged(valeur);
    _minuteurMessage = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _message = null);
    });
  }

  @override
  void dispose() {
    _minuteurMessage?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ListTile(
        dense: true,
        visualDensity: const VisualDensity(horizontal: -1, vertical: -3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        minLeadingWidth: 24,
        horizontalTitleGap: 10,
        leading: FaIcon(widget.icone, size: 18),
        title: Text(widget.titre, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: widget.sousTitre == null
            ? null
            : Text(
                widget.sousTitre!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        trailing: Transform.scale(
          scale: .78,
          child: Switch(
            value: widget.valeur,
            activeThumbColor: const Color(0xFFFF7417),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: _changer,
          ),
        ),
        onTap: () => _changer(!widget.valeur),
      ),
      SizedBox(
        height: 25,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: _message == null
              ? const SizedBox.expand()
              : Padding(
                  key: ValueKey(_message),
                  padding: const EdgeInsets.fromLTRB(46, 0, 12, 7),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.circleCheck,
                        color: Color(0xFF16A34A),
                        size: 17,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _message!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 11.5,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    ],
  );
}

class _BlocParametres extends StatelessWidget {
  const _BlocParametres({required this.titre, required this.enfants});
  final String titre;
  final List<Widget> enfants;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 2),
          child: Text(
            titre,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ),
        ...enfants,
      ],
    ),
  );
}
