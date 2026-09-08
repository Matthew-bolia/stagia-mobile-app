import 'package:flutter/material.dart';
import '../../../../core/widgets/contenu_adaptatif.dart';

class NotesAcademiquesPage extends StatelessWidget {
  const NotesAcademiquesPage({this.notes = const [], super.key});

  final List<Map<String, dynamic>> notes;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Notes académiques')),
    body: ContenuAdaptatif(
      largeurMaximale: 640,
      enfant: notes.isEmpty
          ? Center(
              child: Container(
                margin: const EdgeInsets.all(18),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: const Text(
                  'Aucune note académique publiée.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: notes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _CarteNote(notes[index]),
            ),
    ),
  );
}

class _CarteNote extends StatelessWidget {
  const _CarteNote(this.note);
  final Map<String, dynamic> note;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          note['matiere']?.toString() ?? 'Matière',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        _Ligne('Évaluation', note['type_evaluation']),
        _Ligne('Note', note['note']),
        _Ligne('Résultat', note['resultat']),
        _Ligne('Date', note['date']),
      ],
    ),
  );
}

class _Ligne extends StatelessWidget {
  const _Ligne(this.libelle, this.valeur);
  final String libelle;
  final Object? valeur;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 7),
    child: Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            libelle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            valeur?.toString() ?? '-',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}
