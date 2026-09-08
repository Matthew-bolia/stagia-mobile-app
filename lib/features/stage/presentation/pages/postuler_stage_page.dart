import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/network/client_api_http.dart';
import '../../../../core/mocks/depot_mock_etudiant.dart';
import '../../data/datasources/source_stage_distante.dart';
import '../../../../core/widgets/contenu_adaptatif.dart';
import '../../../../core/widgets/erreur_chargement_api.dart';
import '../widgets/onglets_stage.dart';
import '../routes/routes_stage.dart';

class PostulerStagePage extends StatefulWidget {
  const PostulerStagePage({super.key});
  @override
  State<PostulerStagePage> createState() => _PostulerStagePageState();
}

class _PostulerStagePageState extends State<PostulerStagePage> {
  final _source = SourceStageDistante(ClientApiHttp());
  late Future<List<Map<String, dynamic>>> _chargement;

  @override
  void initState() {
    super.initState();
    _chargement = _charger();
  }

  Future<List<Map<String, dynamic>>> _charger() =>
      Future.wait([_source.campagnes(), _source.candidatures()]);

  Future<void> _actualiser() async {
    final futur = _charger();
    setState(() => _chargement = futur);
    await futur;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const AppBarPostuler(),
    body: ContenuAdaptatif(
      enfant: FutureBuilder<List<Map<String, dynamic>>>(
        future: _chargement,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF7417)),
            );
          }
          if (snapshot.hasError) {
            return ErreurChargementApi(
              erreur: snapshot.error,
              onReessayer: _actualiser,
            );
          }
          final campagnes = _items(snapshot.data?[0]['campaigns']);
          final candidatures = _items(snapshot.data?[1]['items']);
          final options = _extraireOptions(campagnes);
          return RefreshIndicator(
            color: const Color(0xFFFF7417),
            onRefresh: _actualiser,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher un établissement',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onSurface,
                        width: 1.2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onSurface,
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onSurface,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * .24,
                  child: FlutterMap(
                    options: const MapOptions(
                      initialCenter: LatLng(-4.325, 15.31),
                      initialZoom: 12.2,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.stagia.stagia',
                      ),
                      MarkerLayer(
                        markers: options
                            .where(
                              (e) => e.latitude != null && e.longitude != null,
                            )
                            .map(
                              (e) => Marker(
                                point: LatLng(e.latitude!, e.longitude!),
                                width: 42,
                                height: 42,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Color(0xFFFF7417),
                                  size: 38,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const SizedBox(height: 12),
                if (options.isEmpty)
                  const _EtatVide()
                else
                  for (final option in options)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CarteOption(
                        option,
                        candidatures: candidatures,
                        onEtatModifie: () => setState(() {}),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

class AppBarPostuler extends StatelessWidget implements PreferredSizeWidget {
  const AppBarPostuler({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(100);
  @override
  Widget build(BuildContext context) => AppBar(
    automaticallyImplyLeading: false,
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(44),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: OngletsStage(ongletActif: OngletStage.postuler),
      ),
    ),
  );
}

class _CarteOption extends StatelessWidget {
  const _CarteOption(
    this.option, {
    required this.candidatures,
    required this.onEtatModifie,
  });
  final _OptionStage option;
  final List<Map<String, dynamic>> candidatures;
  final VoidCallback onEtatModifie;
  @override
  Widget build(BuildContext context) {
    final candidatureEnvoyee =
        DepotMockEtudiant.candidatureEnvoyeePour(option.cleOption) ||
        candidatures.any((candidature) => _candidaturePourOption(candidature));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              option.hopital,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(option.campagne),
            Text(
              option.localisation,
              style: const TextStyle(color: Color(0xFF718096)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: candidatureEnvoyee
                    ? null
                    : () async {
                        final donnees = option.versMap();
                        await Navigator.of(context).pushNamed(
                          RoutesStage.parcoursCandidature,
                          arguments: donnees,
                        );
                        onEtatModifie();
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  candidatureEnvoyee ? 'Candidature déjà envoyée' : 'Postuler',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _candidaturePourOption(Map<String, dynamic> candidature) {
    final cle = candidature['option_key']?.toString();
    if (cle == option.cleOption) return true;
    final campagneId = candidature['campaign_id']?.toString();
    final optionId =
        candidature['option_id']?.toString() ??
        candidature['stage_option_id']?.toString();
    return campagneId == option.campagneId && optionId == option.optionId;
  }
}

class _EtatVide extends StatelessWidget {
  const _EtatVide();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Column(
      children: [
        Icon(Icons.work_off_outlined, size: 52, color: Color(0xFFFF7417)),
        SizedBox(height: 12),
        Text(
          'Aucune campagne de stage disponible.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 5),
        Text(
          'Actualisez la page lorsque votre université publiera de nouvelles options.',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class _OptionStage {
  const _OptionStage({
    required this.hopital,
    required this.campagne,
    required this.localisation,
    required this.campagneId,
    required this.optionId,
    this.latitude,
    this.longitude,
  });
  final String hopital;
  final String campagne;
  final String localisation;
  final String campagneId;
  final String optionId;
  final double? latitude;
  final double? longitude;

  String get cleOption => '$campagneId::$optionId';

  Map<String, dynamic> versMap() => {
    'campagne_id': campagneId,
    'option_id': optionId,
    'cle_option': cleOption,
    'etablissement': hopital,
    'campagne': campagne,
    'localisation': localisation,
  };
}

List<_OptionStage> _extraireOptions(List<Map<String, dynamic>> campagnes) {
  final resultat = <_OptionStage>[];
  for (final campagne in campagnes) {
    final etablissements = _items(
      campagne['hospitals'] ?? campagne['options'] ?? campagne['stage_options'],
    );
    for (final etablissement in etablissements) {
      resultat.add(
        _OptionStage(
          hopital:
              etablissement['name']?.toString() ??
              etablissement['hospital_name']?.toString() ??
              'Établissement',
          campagne:
              campagne['title']?.toString() ??
              campagne['campaign_title']?.toString() ??
              '',
          campagneId:
              campagne['campaign_id']?.toString() ??
              campagne['campaign_uuid']?.toString() ??
              campagne['code']?.toString() ??
              campagne['uuid']?.toString() ??
              campagne['id']?.toString() ??
              campagne['title']?.toString() ??
              '',
          optionId:
              etablissement['stage_option_id']?.toString() ??
              etablissement['option_id']?.toString() ??
              etablissement['code']?.toString() ??
              etablissement['uuid']?.toString() ??
              etablissement['id']?.toString() ??
              etablissement['name']?.toString() ??
              '',
          localisation: [
            etablissement['city'],
            etablissement['province'],
          ].where((e) => e != null).join(' · '),
          latitude: _double(etablissement['latitude']),
          longitude: _double(etablissement['longitude']),
        ),
      );
    }
  }
  return resultat;
}

double? _double(Object? valeur) => valeur is num
    ? valeur.toDouble()
    : double.tryParse(valeur?.toString() ?? '');
List<Map<String, dynamic>> _items(Object? valeur) => valeur is List
    ? valeur.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : <Map<String, dynamic>>[];
