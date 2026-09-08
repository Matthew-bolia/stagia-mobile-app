import 'package:flutter/material.dart';

class BarreNavigationPrincipale extends StatelessWidget {
  const BarreNavigationPrincipale({
    required this.indexActuel,
    required this.onDestinationSelectionnee,
    super.key,
  });

  final int indexActuel;
  final ValueChanged<int> onDestinationSelectionnee;

  static const _destinations = [
    _DestinationNavigation(
      libelle: 'Accueil',
      icone: Icons.home_outlined,
      iconeSelectionnee: Icons.home_rounded,
    ),
    _DestinationNavigation(
      libelle: 'Stages',
      icone: Icons.work_outline_rounded,
      iconeSelectionnee: Icons.work_rounded,
    ),
    _DestinationNavigation(
      libelle: 'Journal',
      icone: Icons.menu_book_outlined,
      iconeSelectionnee: Icons.menu_book_rounded,
    ),
    _DestinationNavigation(
      libelle: 'Profil',
      icone: Icons.person_outline_rounded,
      iconeSelectionnee: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final largeurEcran = MediaQuery.sizeOf(context).width;
    final marge = largeurEcran < 340 ? 10.0 : 16.0;
    final modeTablette = largeurEcran >= 600;

    return SafeArea(
      minimum: EdgeInsets.fromLTRB(marge, 0, marge, 10),
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: modeTablette ? 410 : double.infinity,
          height: modeTablette ? 72 : 66,
          padding: EdgeInsets.symmetric(
            horizontal: modeTablette ? 12 : 6,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFF7417),
            borderRadius: BorderRadius.circular(40),
            border: modeTablette
                ? Border.all(color: Colors.white, width: 2)
                : null,
            boxShadow: const [
              BoxShadow(
                color: Color(0x330D0D0D),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_destinations.length, (index) {
              final destination = _destinations[index];
              final selectionnee = index == indexActuel;

              return Expanded(
                child: InkWell(
                  onTap: () => onDestinationSelectionnee(index),
                  borderRadius: BorderRadius.circular(28),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: modeTablette ? 9 : 7,
                      vertical: modeTablette ? 5 : 6,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selectionnee
                              ? destination.iconeSelectionnee
                              : destination.icone,
                          size: modeTablette ? 23 : 19,
                          color: selectionnee
                              ? Colors.white
                              : const Color(0xFF0D0D0D),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          destination.libelle,
                          maxLines: 1,
                          style: TextStyle(
                            color: selectionnee
                                ? Colors.white
                                : const Color(0xFF0D0D0D),
                            fontSize: largeurEcran < 360 ? 10 : 11,
                            fontWeight: selectionnee
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _DestinationNavigation {
  const _DestinationNavigation({
    required this.libelle,
    required this.icone,
    required this.iconeSelectionnee,
  });

  final String libelle;
  final IconData icone;
  final IconData iconeSelectionnee;
}
