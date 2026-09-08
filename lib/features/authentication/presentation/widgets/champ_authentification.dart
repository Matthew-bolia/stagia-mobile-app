import 'package:flutter/material.dart';

class ChampAuthentification extends StatelessWidget {
  const ChampAuthentification({
    required this.libelle,
    required this.indication,
    this.icone,
    this.controleur,
    this.masquerTexte = false,
    this.actionSuffixe,
    this.iconeSuffixe,
    this.validateur,
    this.typeClavier,
    this.actionClavier,
    this.onChanged,
    this.capitalisation = TextCapitalization.none,
    super.key,
  });

  final String libelle;
  final String indication;
  final IconData? icone;
  final TextEditingController? controleur;
  final bool masquerTexte;
  final VoidCallback? actionSuffixe;
  final IconData? iconeSuffixe;
  final String? Function(String?)? validateur;
  final TextInputType? typeClavier;
  final TextInputAction? actionClavier;
  final ValueChanged<String>? onChanged;
  final TextCapitalization capitalisation;

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
        TextFormField(
          controller: controleur,
          obscureText: masquerTexte,
          validator: validateur,
          keyboardType: typeClavier,
          textInputAction: actionClavier,
          onChanged: onChanged,
          textCapitalization: capitalisation,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: indication,
            hintMaxLines: 1,
            hintStyle: const TextStyle(fontSize: 13),
            prefixIcon: icone == null ? null : Icon(icone),
            suffixIcon: iconeSuffixe == null
                ? null
                : IconButton(
                    onPressed: actionSuffixe,
                    icon: Icon(iconeSuffixe),
                  ),
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
        ),
      ],
    );
  }
}
