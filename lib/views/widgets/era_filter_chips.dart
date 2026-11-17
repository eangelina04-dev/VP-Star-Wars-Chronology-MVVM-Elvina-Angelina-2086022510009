import 'package:flutter/material.dart';

import '../../domain/models/era.dart';

class EraFilterChips extends StatelessWidget {
  const EraFilterChips({
    super.key,
    required this.selectedEra,
    required this.favoritesOnly,
    required this.onEraSelected,
    required this.onFavoritesOnlyToggled,
  });

  final Era? selectedEra;
  final bool favoritesOnly;
  final ValueChanged<Era?> onEraSelected;
  final VoidCallback onFavoritesOnlyToggled;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: selectedEra == null,
            onSelected: (_) => onEraSelected(null),
          ),
          for (final era in Era.values) ...[
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(era.label),
              selected: selectedEra == era,
              onSelected: (_) => onEraSelected(era),
            ),
          ],
          const SizedBox(width: 16),
          FilterChip(
            label: const Text('Saved'),
            avatar: Icon(
              favoritesOnly ? Icons.star : Icons.star_border,
              size: 18,
            ),
            showCheckmark: false,
            selected: favoritesOnly,
            onSelected: (_) => onFavoritesOnlyToggled(),
          ),
        ],
      ),
    );
  }
}