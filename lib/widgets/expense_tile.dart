// ============================================================
//  widgets/expense_tile.dart — Dark Vault edition
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/providers.dart';
import '../core/theme.dart';
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
    final t = EzzeTheme.of(context);
    final cats     = context.read<CategoryProvider>();
    final settings = context.read<SettingsProvider>();
    final cat      = cats.getById(expense.categoryId);
    final sym      = settings.currencySymbol;

    return Dismissible(
      key: Key(expense.id),
      background: Container(
        margin:     const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color:        kAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border:       Border.all(color: kAccent.withOpacity(0.3)),
        ),
        alignment: Alignment.centerLeft,
        padding:   const EdgeInsets.only(left: 20),
        child: Row(children: [
          const Icon(Icons.edit_outlined, color: kAccent, size: 20),
          const SizedBox(width: 6),
          Text('Edit', style: TextStyle(color: kAccent, fontWeight: FontWeight.w600)),
        ]),
      ),
      secondaryBackground: Container(
        margin:     const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color:        kDanger.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border:       Border.all(color: kDanger.withOpacity(0.3)),
        ),
        alignment: Alignment.centerRight,
        padding:   const EdgeInsets.only(right: 20),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text('Delete', style: TextStyle(color: kDanger, fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          const Icon(Icons.delete_outline, color: kDanger, size: 20),
        ]),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit();
          return false;
        }
        return await _confirmDelete(context);
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        margin:     const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: t.glowCard(radius: 14),
        child: Material(
          color:        Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap:        onEdit,
            splashColor:  kAccent.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Category icon badge
                  Container(
                    width:  46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: cat != null
                          ? Color(cat.colorValue).withOpacity(0.12)
                          : t.bgCardAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: cat != null
                            ? Color(cat.colorValue).withOpacity(0.25)
                            : t.border,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(cat?.icon ?? '📦',
                          style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.title,
                          style: TextStyle(
                            color:      t.textPrimary,
                            fontSize:   14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 3),
                        Text(
                          _buildSubtitle(cat, expense),
                          style: TextStyle(
                            color:   t.textSecond,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  // Amount
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color:        kAccent.withOpacity(t.isDark ? 0.15 : 0.10),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: kAccent.withOpacity(t.isDark ? 0.25 : 0.35), width: 1),
                    ),
                    child: Text(
                      '$sym ${expense.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color:      kAccent,
                        fontWeight: FontWeight.w700,
                        fontSize:   13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _buildSubtitle(CategoryModel? cat, ExpenseModel e) {
    final catName = cat?.name ?? 'Unknown';
    final date    = _formatDate(e.date);
    if (e.subCategory.isEmpty) return '$catName  ·  $date';
    if (catName == kCatFriendlyLoan)
      return '$catName  ·  🤝 ${e.subCategory}  ·  $date';
    return '$catName  ·  ${e.subCategory}  ·  $date';
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    final t = EzzeTheme.of(context);
    return showDialog<bool>(
      context: context,
      builder: (_) {
          return AlertDialog(
        backgroundColor: t.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: t.border),
        ),
        title: Row(children: [
          Icon(Icons.delete_outline, color: kDanger, size: 22),
          SizedBox(width: 8),
          Text('Delete Expense',
              style: TextStyle(color: t.textPrimary, fontSize: 17)),
        ]),
        content: Text(
          'This expense will be permanently removed.',
          style: TextStyle(color: t.textSecond),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: TextStyle(color: t.textSecond)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: kDanger.withOpacity(0.15),
              foregroundColor: kDanger,
              side: const BorderSide(color: kDanger, width: 1),
            ),
            child: const Text('Delete'),
          ),
        ],
      );},
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
