import 'package:flutter/material.dart';
import 'package:worldwildprova/aux/iconsMap.dart';
import 'package:worldwildprova/models_fromddbb/tag.dart'; // aquí està el iconsMap

class TagChip extends StatelessWidget {
  final Tag tag;
  final bool? selected;
  final Function(bool)? onSelected;

  const TagChip({
    required this.tag,
    this.selected = false,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    //final sizes = {'small': 12.0, 'medium': 14.0};

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          /*Icon(
            tag.icon ?? Icons.help_outline,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),*/
          Text(tag.icon),
          const SizedBox(width: 4),
          Text(
            tag.name,
            style: TextStyle(
                fontSize: 20, color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
      selected: selected ?? false, //defecte false
      onSelected:
          onSelected != null // si no se li passa un onSelected, no fa res
              ? onSelected
              : (_) {},
      backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
      shape: StadiumBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary, // color del borde
          width: 1,
        ),
      ),
      visualDensity:
          VisualDensity.compact, // Esto reduce el padding y tamaño general
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    );
  }
}
