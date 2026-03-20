// ============================================================
//  screens/category/category_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/providers.dart';
import '../../models/category_model.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon:     const Icon(Icons.add),
            tooltip:  'Add Category',
            onPressed: () => _addCategory(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding:     const EdgeInsets.all(16),
        itemCount:   categories.length,
        itemBuilder: (_, i) {
          final cat = categories[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                width:  44,
                height: 44,
                decoration: BoxDecoration(
                  color:        cat.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(cat.icon,
                      style: const TextStyle(fontSize: 22)),
                ),
              ),
              title:    Text(cat.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: cat.isDefault
                  ? const Text('Default category')
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon:      const Icon(Icons.edit_outlined),
                    onPressed: () => _editCategory(context, cat),
                  ),
                  if (!cat.isDefault)
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red),
                      onPressed: () => _deleteCategory(context, cat),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _addCategory(BuildContext context) =>
      _showCategoryDialog(context, null);

  void _editCategory(BuildContext context, CategoryModel cat) =>
      _showCategoryDialog(context, cat);

  void _showCategoryDialog(
      BuildContext context, CategoryModel? existing) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final icons    = [
      '🍔','🚗','🛍️','💡','💊','🎬','📚','📦',
      '✈️','🏠','🎮','💼','🐾','⚽','🎵','🍕',
    ];
    final colors = [
      0xFFE53935, 0xFF1E88E5, 0xFF8E24AA, 0xFFFB8C00,
      0xFF00ACC1, 0xFF43A047, 0xFF6D4C41, 0xFF757575,
      0xFFE91E63, 0xFF009688, 0xFFFF5722, 0xFF3F51B5,
    ];
    String selectedIcon  = existing?.icon       ?? icons[0];
    int    selectedColor = existing?.colorValue  ?? colors[0];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: Text(existing != null ? 'Edit Category' : 'New Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize:     MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller:         nameCtrl,
                  decoration:         const InputDecoration(
                      labelText: 'Category Name'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                const Text('Icon',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing:    8,
                  runSpacing: 8,
                  children: icons.map((ic) {
                    final sel = selectedIcon == ic;
                    return GestureDetector(
                      onTap: () => set(() => selectedIcon = ic),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: sel
                              ? Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                              : null,
                          border: sel
                              ? Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                  width: 2)
                              : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(ic,
                            style: const TextStyle(fontSize: 20)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                const Text('Color',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing:    8,
                  runSpacing: 8,
                  children: colors.map((c) {
                    final sel = selectedColor == c;
                    return GestureDetector(
                      onTap: () => set(() => selectedColor = c),
                      child: Container(
                        width:  32,
                        height: 32,
                        decoration: BoxDecoration(
                          color:  Color(c),
                          shape:  BoxShape.circle,
                          border: sel
                              ? Border.all(
                                  color: Colors.black, width: 2)
                              : null,
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
                child: const Text('Cancel')),
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
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteCategory(BuildContext context, CategoryModel cat) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:   const Text('Delete Category'),
        content: Text(
            'Delete "${cat.name}"? Expenses in this category will remain.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              context.read<CategoryProvider>().deleteCategory(cat.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
