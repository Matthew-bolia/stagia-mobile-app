import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<_NotificationLocale> _notifications = [
    _NotificationLocale(
      titre: 'Affectation de stage',
      message: 'Vous êtes affecté au stage de l\'hôpital de Kinshasa.',
      date: 'il y a 1h',
      type: _TypeNotification.security,
      lue: false,
    ),
    _NotificationLocale(
      titre: 'Rotation de stage',
      message:
          'Vous êtes affecté à la rotation de stage du service de chirurgie.',
      date: 'il y a 3h',
      type: _TypeNotification.security,
      lue: true,
    ),
    _NotificationLocale(
      titre: 'Paiement de stage',
      message: 'Votre paiement de stage a été effectué avec succès.',
      date: 'il y a 1j',
      type: _TypeNotification.promo,
      lue: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDEE),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: false,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _CarteNotification(notification: notification);
        },
      ),
    );
  }
}

class _CarteNotification extends StatelessWidget {
  const _CarteNotification({required this.notification});

  final _NotificationLocale notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCCD0D7), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFFDBEAFE),
            child: const FaIcon(
              FontAwesomeIcons.bell,
              color: Color(0xFF1D4ED8),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.titre,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF202124),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF53616F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.date,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF53616F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _TypeNotification { security, promo, subscription, follower }

class _NotificationLocale {
  _NotificationLocale({
    required this.titre,
    required this.message,
    required this.date,
    required this.type,
    this.lue = false,
  });

  final String titre;
  final String message;
  final String date;
  final _TypeNotification type;
  final bool lue;
}
