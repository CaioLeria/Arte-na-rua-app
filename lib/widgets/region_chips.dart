import 'package:flutter/material.dart';

class RegionChips extends StatelessWidget {
  final List<String> regions;
  final String selected;
  final ValueChanged<String> onSelected;

  const RegionChips({
    super.key,
    required this.regions,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: regions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final region = regions[index];
          return ChoiceChip(
            label: Text(region),
            selected: region == selected,
            onSelected: (_) => onSelected(region),
          );
        },
      ),
    );
  }
}
