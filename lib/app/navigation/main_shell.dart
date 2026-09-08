import 'package:flutter/material.dart';
import '../../core/mocks/depot_mock_etudiant.dart';
import '../barre_navigation/barre_navigation_principale.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/stage/presentation/pages/stage_page.dart';
import '../../features/journal/presentation/pages/journal_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _afficherBarreNavigation = true;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomePage(
        onOuvrirStages: () {
          DepotMockEtudiant.marquerCampagnesConsultees();
          setState(() => _currentIndex = 1);
        },
      ),
      StagePage(
        onVisibiliteNavigationChangee: (visible) {
          if (!mounted) return;
          if (_afficherBarreNavigation == visible) return;
          setState(() => _afficherBarreNavigation = visible);
        },
      ),
      const JournalPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: _afficherBarreNavigation
          ? BarreNavigationPrincipale(
              indexActuel: _currentIndex,
              onDestinationSelectionnee: (index) {
                if (index == 1) {
                  DepotMockEtudiant.marquerCampagnesConsultees();
                }
                setState(() => _currentIndex = index);
              },
            )
          : null,
    );
  }
}
