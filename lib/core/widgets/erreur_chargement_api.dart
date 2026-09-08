import 'package:flutter/material.dart';

import '../network/reponse_api.dart';

class ErreurChargementApi extends StatelessWidget {
  const ErreurChargementApi({required this.erreur, required this.onReessayer, super.key});
  final Object? erreur;
  final VoidCallback onReessayer;

  @override
  Widget build(BuildContext context) {
    final message = erreur is ErreurApi
        ? (erreur! as ErreurApi).message
        : 'Une erreur inattendue est survenue.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.cloud_off_outlined, size: 48, color: Color(0xFFFF7417)),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          TextButton(onPressed: onReessayer, child: const Text('Réessayer')),
        ]),
      ),
    );
  }
}
