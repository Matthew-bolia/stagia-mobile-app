import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<_NotificationLocale> _notifications = [
    _NotificationLocale(
      titre: 'Candidature enregistrée',
      message: 'Votre candidature a bien été transmise.',
      date: 'Aujourd’hui · 10:24',
    ),
    _NotificationLocale(
      titre: 'Nouvelle tâche attribuée',
      message: 'Une nouvelle tâche est disponible dans votre journal.',
      date: 'Hier · 15:40',
    ),
    _NotificationLocale(
      titre: 'Rapport à corriger',
      message: 'Votre encadreur a ajouté une observation sur le rapport.',
      date: '26 août · 09:15',
    ),
  ];

  void _marquerCommeLue(int index) {
    setState(() => _notifications[index].lue = true);
  }

  void _toutMarquerCommeLu() {
    setState(() {
      for (final notification in _notifications) {
        notification.lue = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final marge = MediaQuery.sizeOf(context).width < 360 ? 14.0 : 18.0;
    final nonLues = _notifications.where((element) => !element.lue).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          if (nonLues > 0)
            TextButton(
              onPressed: _toutMarquerCommeLu,
              child: const Text('Tout lire'),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(child: Text('Aucune notification.'))
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(marge, 12, marge, 28),
              itemCount: _notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return Card(
                  color: notification.lue
                      ? Colors.white
                      : const Color(0xFFFFF3EB),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: notification.lue
                              ? const Color(0xFFF1F3F6)
                              : const Color(0xFFFFE3D1),
                          child: Icon(
                            Icons.notifications_rounded,
                            color: notification.lue
                                ? const Color(0xFF718096)
                                : const Color(0xFFE85D00),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.titre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(notification.message),
                              const SizedBox(height: 7),
                              Text(
                                notification.date,
                                style: const TextStyle(
                                  color: Color(0xFF718096),
                                  fontSize: 12,
                                ),
                              ),
                              if (!notification.lue)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => _marquerCommeLue(index),
                                    child: const Text('Marquer comme lue'),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _NotificationLocale {
  _NotificationLocale({
    required this.titre,
    required this.message,
    required this.date,
  }) : lue = false;
  final String titre;
  final String message;
  final String date;
  bool lue;
}
