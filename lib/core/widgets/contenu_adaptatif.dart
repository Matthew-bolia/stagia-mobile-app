import 'package:flutter/material.dart';

class ContenuAdaptatif extends StatelessWidget {
  const ContenuAdaptatif({
    required this.enfant,
    this.largeurMaximale = 760,
    super.key,
  });
  final Widget enfant;
  final double largeurMaximale;

  @override
  Widget build(BuildContext context) {
    final modeTablette = MediaQuery.sizeOf(context).width >= 600;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: modeTablette ? largeurMaximale : double.infinity,
        ),
        child: enfant,
      ),
    );
  }
}
