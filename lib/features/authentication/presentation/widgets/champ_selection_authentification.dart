import 'package:flutter/material.dart';

class ChampSelectionAuthentification extends StatelessWidget {
  const ChampSelectionAuthentification({
    required this.libelle,
    required this.indication,
    this.icone,
    required this.elements,
    required this.valeur,
    required this.onChanged,
    this.actif = true,
    super.key,
  });

  final String libelle;
  final String indication;
  final IconData? icone;
  final List<String> elements;
  final String? valeur;
  final ValueChanged<String?> onChanged;
  final bool actif;

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    final bordure = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Color(0xFFDDE3EA)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          libelle,
          style: TextStyle(
            color: couleurs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: valeur,
          isExpanded: true,
          itemHeight: null,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          decoration: InputDecoration(
            hint: Text(
              indication,
              maxLines: 1,
              softWrap: true,
              style: const TextStyle(fontSize: 13),
            ),
            prefixIcon: icone == null ? null : Icon(icone),
            filled: true,
            fillColor: const Color(0xFFF0F3F7),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 17,
            ),
            border: bordure,
            enabledBorder: bordure,
            focusedBorder: bordure.copyWith(
              borderSide: BorderSide(color: couleurs.primary, width: 1.6),
            ),
            errorBorder: bordure.copyWith(
              borderSide: BorderSide(color: couleurs.error),
            ),
          ),
          items: elements
              .map(
                (element) => DropdownMenuItem<String>(
                  value: element,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      element,
                      maxLines: 1,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: actif ? onChanged : null,
          validator: (selection) {
            if (selection == null || selection.isEmpty) {
              return 'Veuillez sélectionner $libelle';
            }
            return null;
          },
        ),
      ],
    );
  }
}
