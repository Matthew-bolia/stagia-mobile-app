import 'package:flutter/material.dart';
import '../../../../core/mocks/depot_mock_etudiant.dart';
import '../../../../core/network/client_api_http.dart';
import '../../../../core/network/source_etudiant_distante.dart';
import '../../../../core/services/session_authentification_service.dart';
import '../../../../core/widgets/contenu_adaptatif.dart';
import '../../../stage/data/datasources/source_stage_distante.dart';
import 'home_premiere_connexion_page.dart';
import 'home_shared_widgets.dart';
import 'home_stage_actif_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({this.onOuvrirStages, super.key});

  final VoidCallback? onOuvrirStages;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _source = SourceEtudiantDistante(ClientApiHttp());
  final _sourceStages = SourceStageDistante(ClientApiHttp());
  late Future<List<Map<String, dynamic>>> _chargement;
  Map<String, dynamic> _identiteSession = const {};

  @override
  void initState() {
    super.initState();
    DepotMockEtudiant.changements.addListener(_donneesLocalesModifiees);
    _chargement = _charger();
    _chargerIdentiteSession();
  }

  Future<void> _chargerIdentiteSession() async {
    final identite = await SessionAuthentificationService.identite();
    if (mounted) setState(() => _identiteSession = identite);
  }

  @override
  void dispose() {
    DepotMockEtudiant.changements.removeListener(_donneesLocalesModifiees);
    super.dispose();
  }

  void _donneesLocalesModifiees() {
    if (mounted) setState(() => _chargement = _charger());
  }

  Future<List<Map<String, dynamic>>> _charger() => Future.wait([
    _source.tableauDeBord(),
    _chargerCampagnes(),
    _source.candidatures(),
    _chargerProfil(),
  ]);

  Future<Map<String, dynamic>> _chargerCampagnes() async {
    try {
      return await _sourceStages.campagnes();
    } catch (_) {
      return const <String, dynamic>{'campaigns': <dynamic>[]};
    }
  }

  Future<Map<String, dynamic>> _chargerProfil() async {
    try {
      return await _source.profil();
    } catch (_) {
      return const <String, dynamic>{};
    }
  }

  Future<void> _actualiser() async {
    final futur = _charger();
    setState(() => _chargement = futur);
    await futur;
  }

  @override
  Widget build(
    BuildContext context,
  ) => FutureBuilder<List<Map<String, dynamic>>>(
    future: _chargement,
    builder: (context, snapshot) {
      final donnees = snapshot.data?.first ?? const <String, dynamic>{};
      final options = snapshot.data != null && snapshot.data!.length > 1
          ? snapshot.data![1]
          : const <String, dynamic>{};
      final candidatures = snapshot.data != null && snapshot.data!.length > 2
          ? snapshot.data![2]
          : const <String, dynamic>{};
      final profil = snapshot.data != null && snapshot.data!.length > 3
          ? snapshot.data![3]
          : const <String, dynamic>{};

      final etudiant = <String, dynamic>{};
      void ajouterIdentite(Map<String, dynamic> source) {
        for (final entree in source.entries) {
          if (entree.value.toString().trim().isNotEmpty) {
            etudiant[entree.key] = entree.value;
          }
        }
      }

      ajouterIdentite(mapApi(profil['user']));
      ajouterIdentite(mapApi(profil['student']));
      ajouterIdentite(mapApi(donnees['user']));
      ajouterIdentite(mapApi(donnees['student']));
      for (final entree in _identiteSession.entries) {
        if (entree.value.toString().trim().isNotEmpty) {
          etudiant[entree.key] = entree.value;
        }
      }
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: EnTeteAccueil(etudiant: etudiant),
        body: ContenuAdaptatif(
          enfant: snapshot.connectionState == ConnectionState.waiting
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF7417)),
                )
              : snapshot.hasError
              ? ErreurAccueil(onReessayer: _actualiser)
              : RefreshIndicator(
                  color: const Color(0xFFFF7417),
                  onRefresh: _actualiser,
                  child: _interfaceAccueil(
                    donnees: donnees,
                    campagnes: listeApi(options['campaigns']),
                    candidatures: listeApi(candidatures['items']),
                  ),
                ),
        ),
      );
    },
  );

  Widget _interfaceAccueil({
    required Map<String, dynamic> donnees,
    required List<Map<String, dynamic>> campagnes,
    required List<Map<String, dynamic>> candidatures,
  }) {
    final stats = mapApi(donnees['stats']);
    if (entierApi(stats['stages']) == 0) {
      return HomePremiereConnexionPage(
        campagnes: campagnes,
        candidatures: candidatures,
        onVoirCampagnes: widget.onOuvrirStages,
      );
    }

    return HomeStageActifPage(donnees: donnees);
  }
}
