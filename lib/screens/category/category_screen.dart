// ============================================================
//  screens/category/category_screen.dart — Dark Vault edition
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../models/category_model.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = EzzeTheme.of(context);
    final categories = context.watch<CategoryProvider>().categories;

    return Scaffold(
      backgroundColor: t.bgBase,
      appBar: AppBar(
        title: const Text('🏷️ Categories'),
        actions: [
          GestureDetector(
            onTap: () => _showCategoryDialog(context, null),
            child: Container(
              margin:  const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:        t.accentGlow,
                borderRadius: BorderRadius.circular(10),
                border:       Border.all(color: kAccent.withOpacity(0.4)),
              ),
              child: const Icon(Icons.add_rounded, color: kAccent, size: 18),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding:     const EdgeInsets.all(16),
        itemCount:   categories.length,
        itemBuilder: (_, i) {
          final cat      = categories[i];
          final catColor = Color(cat.colorValue);
          return Container(
            margin:     const EdgeInsets.only(bottom: 8),
            decoration: t.glowCard(radius: 14),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              leading: Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color:        catColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border:       Border.all(
                      color: catColor.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(cat.icon,
                      style: TextStyle(fontSize: 20)),
                ),
              ),
              title: Text(cat.name,
                style: TextStyle(
                  color: t.textPrimary, fontWeight: FontWeight.w600,
                  fontSize: 14)),
              subtitle: cat.isDefault
                  ? Text('⭐  Default category',
                      style: TextStyle(color: t.textHint, fontSize: 11))
                  : null,
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                GestureDetector(
                  onTap: () => _showCategoryDialog(context, cat),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color:        t.bgCardAlt,
                      borderRadius: BorderRadius.circular(8),
                      border:       Border.all(color: t.border),
                    ),
                    child: Icon(Icons.edit_outlined,
                        color: t.textSecond, size: 15),
                  ),
                ),
                if (!cat.isDefault) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _deleteCategory(context, cat),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color:        kDanger.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: kDanger.withOpacity(0.25)),
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: kDanger, size: 15),
                    ),
                  ),
                ],
              ]),
            ),
          );
        },
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, CategoryModel? existing) {
    final t = EzzeTheme.of(context);
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final icons    = [
      '🍔','🚗','🛍️','💡','💊','🎬','📚','📦',
      '✈️','🏠','🎮','💼','🐾','⚽','🎵','🍕',
      '☕','🎓','💈','🏥','🤝','💰','🔧','🛒',
    ];
    final colors = [
      0xFFE53935, 0xFF1E88E5, 0xFF8E24AA, 0xFFFB8C00,
      0xFF00ACC1, 0xFF43A047, 0xFF6D4C41, 0xFF757575,
      0xFFE91E63, 0xFF009688, 0xFFFF5722, 0xFF3F51B5,
      0xFF00C9A7, 0xFF9B72FF, 0xFF3D9EFF, 0xFFFFB547,
    ];
    String selectedIcon  = existing?.icon       ?? icons[0];
    int    selectedColor = existing?.colorValue  ?? colors[0];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          backgroundColor: t.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: t.border)),
          title: Row(children: [
            Text(existing != null ? '✏️ ' : '➕ ',
                style: TextStyle(fontSize: 18)),
            Text(existing != null ? 'Edit Category' : 'New Category',
              style: TextStyle(
                color: t.textPrimary, fontSize: 17,
                fontWeight: FontWeight.w700)),
          ]),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize:      MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller:         nameCtrl,
                  style:              TextStyle(color: t.textPrimary),
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText:  'Category Name',
                    hintText:   'e.g. Groceries, Gym, Travel...',
                    prefixIcon: Icon(Icons.label_outline_rounded, size: 18),
                  ),
                ),
                SizedBox(height: 16),
                Text('🎨  Choose Icon',
                  style: TextStyle(
                    color: t.textSecond, fontSize: 12,
                    fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8,
                  children: icons.map((ic) {
                    final sel = selectedIcon == ic;
                    return GestureDetector(
                      onTap: () => set(() => selectedIcon = ic),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding:  const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: sel ? t.accentGlow : t.bgCardAlt,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: sel
                                ? kAccent.withOpacity(0.6) : t.border,
                            width: sel ? 1.5 : 1),
                        ),
                        child: Text(ic,
                            style: const TextStyle(fontSize: 20)),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 14),
                Text('🌈  Choose Color',
                  style: TextStyle(
                    color: t.textSecond, fontSize: 12,
                    fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8,
                  children: colors.map((c) {
                    final sel = selectedColor == c;
                    return GestureDetector(
                      onTap: () => set(() => selectedColor = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color:  Color(c),
                          shape:  BoxShape.circle,
                          border: sel
                              ? Border.all(
                                  color: Colors.white, width: 2.5)
                              : Border.all(
                                  color: Color(c).withOpacity(0.3)),
                          boxShadow: sel ? [BoxShadow(
                            color: Color(c).withOpacity(0.4),
                            blurRadius: 8)] : null,
                        ),
                        child: sel
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 16)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: TextStyle(color: t.textSecond))),
            FilledButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                final cat = CategoryModel(
                  id:         existing?.id ?? const Uuid().v4(),
                  name:       nameCtrl.text.trim(),
                  icon:       selectedIcon,
                  colorValue: selectedColor,
                  isDefault:  existing?.isDefault ?? false,
                );
                if (existing != null) {
                  context.read<CategoryProvider>().updateCategory(cat);
                } else {
                  context.read<CategoryProvider>().addCategory(cat);
                }
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: t.accentGlow,
                foregroundColor: kAccent,
                side: const BorderSide(color: kAccent)),
              child: const Text('Save')),
          ],
        ),
      ),
    );
  }

  void _deleteCategory(BuildContext context, CategoryModel cat) {
    final t = EzzeTheme.of(context);
    showDialog(
      context: context,
      builder: (_) {
          final t = EzzeTheme.of(context);
          return AlertDialog(
        backgroundColor: t.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: t.border)),
        title: Row(children: [
          Text('🗑️ ', style: TextStyle(fontSize: 18)),
          Text('Delete Category',
            style: TextStyle(color: t.textPrimary, fontSize: 17)),
        ]),
        content: Text(
          'Delete "${cat.name}"?\nExpenses in this category will remain.',
          style: TextStyle(color: t.textSecond)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: t.textSecond))),
          FilledButton(
            onPressed: () {
              context.read<CategoryProvider>().deleteCategory(cat.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: kDanger.withOpacity(0.12),
              foregroundColor: kDanger,
              side: const BorderSide(color: kDanger)),
            child: const Text('Delete')),
        ],
      );},
    );
  }
}
