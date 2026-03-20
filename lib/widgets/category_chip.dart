// ============================================================
//  widgets/category_chip.dart
// ============================================================

import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategoryChip extends StatelessWidget {
  final CategoryModel cat;
  final bool         selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.cat,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected:      selected,
      onSelected:    (_) => onTap(),
      avatar:        Text(cat.icon, style: const TextStyle(fontSize: 14)),
      label:         Text(cat.name),
      selectedColor: Color(cat.colorValue).withOpacity(0.25),
      checkmarkColor: Color(cat.colorValue),
    );
  }
}
