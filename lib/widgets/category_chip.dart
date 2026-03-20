import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/category_model.dart';

class CategoryChip extends StatelessWidget {
  final CategoryModel cat;
  final bool         selected;
  final VoidCallback onTap;
  const CategoryChip({super.key, required this.cat, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = EzzeTheme.of(context);
    final color = Color(cat.colorValue);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color:        selected ? color.withOpacity(0.13) : t.bgCardAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color.withOpacity(0.5) : t.border, width: 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(cat.icon, style: TextStyle(fontSize: 14)),
          SizedBox(width: 5),
          Text(cat.name,
            style: TextStyle(
              color:      selected ? color : t.textSecond,
              fontSize:   12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
        ]),
      ),
    );
  }
}
