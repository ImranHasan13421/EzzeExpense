// ============================================================
//  widgets/expense_tile.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/providers.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';

class ExpenseTile extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExpenseTile({
    super.key,
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cats     = context.read<CategoryProvider>();
    final settings = context.read<SettingsProvider>();
    final cat      = cats.getById(expense.categoryId);
    final sym      = settings.currencySymbol;

    return Dismissible(
      key: Key(expense.id),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.green.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit();
          return false;
        } else {
          return await _confirmDelete(context);
        }
      },
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cat != null
                  ? Color(cat.colorValue).withOpacity(0.15)
                  : Colors.grey.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(cat?.icon ?? '📦', style: const TextStyle(fontSize: 22)),
            ),
          ),
          title: Text(expense.title,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(
            _buildSubtitle(cat, expense),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: Text(
            '$sym ${expense.amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          onTap: onEdit,
        ),
      ),
    );
  }

  String _buildSubtitle(CategoryModel? cat, ExpenseModel e) {
    final catName = cat?.name ?? 'Unknown';
    final date    = _formatDate(e.date);
    if (e.subCategory.isEmpty) return '$catName • $date';
    if (catName == kCatFriendlyLoan) return '$catName • 🤝 ${e.subCategory} • $date';
    return '$catName • ${e.subCategory} • $date';
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    if (d.day == now.day && d.month == now.month && d.year == now.year)
      return 'Today';
    if (d.day == now.day - 1 && d.month == now.month && d.year == now.year)
      return 'Yesterday';
    return '${d.day}/${d.month}/${d.year}';
  }
}
