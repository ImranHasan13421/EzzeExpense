// ============================================================
//  screens/budget/budget_screen.dart — Dark Vault edition
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../widgets/budget_progress_bar.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = EzzeTheme.of(context);
    final budget     = context.watch<BudgetProvider>().budget;
    final expenses   = context.watch<ExpenseProvider>();
    final categories = context.watch<CategoryProvider>();
    final settings   = context.read<SettingsProvider>();
    final sym        = settings.currencySymbol;
    final monthSpent = expenses.totalThisMonth;
    final catTotals  = expenses.categoryTotals(expenses.thisMonthExpenses);

    return Scaffold(
      backgroundColor: t.bgBase,
      appBar: AppBar(
        title: const Text('🎯 Budget'),
        actions: [
          GestureDetector(
            onTap: () => _editMonthlyBudget(context),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:        t.bgCard,
                borderRadius: BorderRadius.circular(10),
                border:       Border.all(color: t.border),
              ),
              child: const Icon(Icons.edit_outlined,
                  color: kAccent, size: 18),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Monthly overview ───────────────────────────────
          Container(
            decoration: t.accentCard(),
            padding:    const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('💰', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text('Monthly Budget',
                    style: TextStyle(
                      color: t.textPrimary, fontSize: 15,
                      fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 16),
                if (budget.monthlyTotal <= 0)
                  GestureDetector(
                    onTap: () => _editMonthlyBudget(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color:        t.accentGlow,
                        borderRadius: BorderRadius.circular(10),
                        border:       Border.all(
                            color: kAccent.withOpacity(0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_circle_outline,
                              color: kAccent, size: 18),
                          SizedBox(width: 8),
                          Text('Set Monthly Budget',
                            style: TextStyle(
                              color: kAccent, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  )
                else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('💸 Spent',
                            style: TextStyle(color: t.textSecond, fontSize: 12)),
                          Text('$sym ${monthSpent.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: t.textPrimary, fontSize: 22,
                              fontWeight: FontWeight.w800)),
                        ]),
                      Column(crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Budget',
                            style: TextStyle(color: t.textSecond, fontSize: 12)),
                          Text('$sym ${budget.monthlyTotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: kAccent, fontSize: 22,
                              fontWeight: FontWeight.w800)),
                        ]),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BudgetProgressBar(
                      spent: monthSpent, total: budget.monthlyTotal),
                  if (monthSpent >= budget.monthlyTotal * 0.8) ...[
                    const SizedBox(height: 10),
                    _warningBanner(monthSpent, budget.monthlyTotal, sym),
                  ],
                ],
              ],
            ),
          ),
          SizedBox(height: 20),

          // ── Category budgets header ────────────────────────
          Row(children: [
            Text('📊 ', style: TextStyle(fontSize: 15)),
            Text('Category Budgets',
              style: TextStyle(
                color: t.textPrimary, fontSize: 15,
                fontWeight: FontWeight.w700)),
            const Spacer(),
            GestureDetector(
              onTap: () => _addCategoryBudget(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:        t.accentGlow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kAccent.withOpacity(0.4)),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.add, color: kAccent, size: 15),
                  SizedBox(width: 4),
                  Text('Add', style: TextStyle(
                      color: kAccent, fontSize: 12,
                      fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ]),
          SizedBox(height: 12),

          if (budget.categoryBudgets.isEmpty)
            Container(
              decoration: t.glowCard(),
              padding:    const EdgeInsets.all(28),
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('🎯', style: TextStyle(fontSize: 40)),
                  SizedBox(height: 10),
                  Text('No category budgets yet',
                    style: TextStyle(
                      color: t.textPrimary, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('Tap ＋ Add to set limits per category',
                    style: TextStyle(color: t.textSecond, fontSize: 13)),
                ]),
              ),
            )
          else
            ...budget.categoryBudgets.entries.map((entry) {
              final cat        = categories.getById(entry.key);
              final spent      = catTotals[entry.key] ?? 0;
              final pct        = entry.value > 0 ? spent / entry.value : 0.0;
              final isLoanCat  = cat?.name == kCatFriendlyLoan;
              final hasSubCats = cat?.name == kCatBills ||
                  cat?.name == kCatOther || isLoanCat;
              final subTotals  = <String, double>{};
              if (hasSubCats) {
                for (final e in expenses.thisMonthExpenses.where((e) =>
                    e.categoryId == entry.key && e.subCategory.isNotEmpty)) {
                  subTotals[e.subCategory] =
                      (subTotals[e.subCategory] ?? 0) + e.amount;
                }
              }
              final catColor = cat != null
                  ? Color(cat.colorValue) : kAccent;

              return Container(
                margin:     const EdgeInsets.only(bottom: 10),
                decoration: t.glowCard(),
                padding:    const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color:        catColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: catColor.withOpacity(0.25)),
                        ),
                        child: Center(child: Text(cat?.icon ?? '📦',
                            style: const TextStyle(fontSize: 18))),
                      ),
                      SizedBox(width: 10),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cat?.name ?? '?',
                            style: TextStyle(
                              color: t.textPrimary, fontWeight: FontWeight.w600,
                              fontSize: 14)),
                          Text('$sym ${spent.toStringAsFixed(0)} / $sym ${entry.value.toStringAsFixed(0)}',
                            style: TextStyle(
                                color: t.textSecond, fontSize: 12)),
                        ],
                      )),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        GestureDetector(
                          onTap: () => _editCatBudget(
                              context, entry.key, entry.value),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: t.bgCardAlt,
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(color: t.border),
                            ),
                            child: Icon(Icons.edit_outlined,
                                size: 13, color: t.textSecond),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => context.read<BudgetProvider>()
                              .removeCategoryBudget(entry.key),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color:        kDanger.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                  color: kDanger.withOpacity(0.2)),
                            ),
                            child: const Icon(Icons.close_rounded,
                                size: 13, color: kDanger),
                          ),
                        ),
                      ]),
                    ]),
                    const SizedBox(height: 10),
                    BudgetProgressBar(spent: spent, total: entry.value),
                    // Sub-breakdown
                    if (subTotals.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...subTotals.entries.map((s) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(children: [
                          SizedBox(width: 4),
                          Text(isLoanCat ? '🤝' : '›',
                            style: TextStyle(
                              fontSize: isLoanCat ? 12 : 14,
                              color: t.textHint)),
                          SizedBox(width: 6),
                          Expanded(child: Text(s.key,
                            style: TextStyle(
                                color: t.textSecond, fontSize: 12))),
                          Text('$sym ${s.value.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: t.textSecond, fontSize: 12,
                              fontWeight: FontWeight.w600)),
                        ]),
                      )),
                    ],
                    // Warning
                    if (pct >= 0.8) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: spent > entry.value
                              ? kDanger.withOpacity(0.08)
                              : kWarning.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: spent > entry.value
                                ? kDanger.withOpacity(0.3)
                                : kWarning.withOpacity(0.3)),
                        ),
                        child: Row(children: [
                          Icon(
                            spent > entry.value
                                ? Icons.cancel_outlined
                                : pct >= 1
                                    ? Icons.check_circle_outline
                                    : Icons.warning_amber_rounded,
                            color: spent > entry.value
                                ? kDanger : kWarning,
                            size: 14),
                          const SizedBox(width: 6),
                          Expanded(child: Text(
                            spent > entry.value
                                ? 'Overspending on ${cat?.name}! $sym ${(spent - entry.value).toStringAsFixed(0)} over'
                                : pct >= 1
                                    ? 'You have used all your budget!'
                                    : 'Almost at budget limit for ${cat?.name}',
                            style: TextStyle(
                              fontSize: 12,
                              color: spent > entry.value
                                  ? kDanger : kWarning),
                          )),
                        ]),
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _warningBanner(double spent, double total, String sym) {
    final isOver  = spent > total;
    final isExact = spent >= total;
    final color   = isOver ? kDanger : kWarning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(
          isOver ? Icons.cancel_outlined
            : isExact ? Icons.check_circle_outline
            : Icons.warning_amber_rounded,
          color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(
          isOver
            ? '❌ Overspending! $sym ${(spent - total).toStringAsFixed(0)} over budget'
            : isExact
                ? '✅ You have used all your budget!'
                : '⚠️ 80% of budget used',
          style: TextStyle(color: color, fontWeight: FontWeight.w600,
              fontSize: 13),
        )),
      ]),
    );
  }

  void _editMonthlyBudget(BuildContext context) {
    final t = EzzeTheme.of(context);
    final ctrl = TextEditingController(
      text: context.read<BudgetProvider>().budget.monthlyTotal > 0
          ? context.read<BudgetProvider>().budget.monthlyTotal.toStringAsFixed(0)
          : '',
    );
    final sym = context.read<SettingsProvider>().currencySymbol;
    _showDialog(context,
      title: '💰  Set Monthly Budget',
      child: TextField(
        controller: ctrl, keyboardType: TextInputType.number,
        style: TextStyle(color: t.textPrimary),
        decoration: InputDecoration(
          labelText: 'Amount', prefixText: '$sym '),
        autofocus: true,
      ),
      onSave: () {
        final v = double.tryParse(ctrl.text);
        if (v != null && v > 0)
          context.read<BudgetProvider>().setMonthlyBudget(v);
      },
    );
  }

  void _addCategoryBudget(BuildContext context) {
    final t = EzzeTheme.of(context);
    final cats   = context.read<CategoryProvider>().categories;
    final budget = context.read<BudgetProvider>().budget;
    final sym    = context.read<SettingsProvider>().currencySymbol;
    final available = cats.where(
        (c) => !budget.categoryBudgets.containsKey(c.id)).toList();
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅  All categories already have budgets')));
      return;
    }
    String? selectedId = available.first.id;
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          backgroundColor: t.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: t.border)),
          title: Text('📊 Category Budget',
            style: TextStyle(color: t.textPrimary, fontSize: 17)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<String>(
              value:        selectedId,
              dropdownColor: t.bgCard,
              style:        TextStyle(color: t.textPrimary),
              items: available.map((c) => DropdownMenuItem(
                value: c.id,
                child: Text('${c.icon} ${c.name}'))).toList(),
              onChanged: (v) => set(() => selectedId = v),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            SizedBox(height: 12),
            TextField(
              controller:   ctrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: t.textPrimary),
              decoration: InputDecoration(
                  labelText: 'Budget amount', prefixText: '$sym '),
              autofocus: true,
            ),
          ]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: TextStyle(color: t.textSecond))),
            FilledButton(
              onPressed: () {
                final v = double.tryParse(ctrl.text);
                if (v == null || v <= 0 || selectedId == null) return;
                if (budget.monthlyTotal > 0) {
                  final currentTotal = budget.categoryBudgets.values
                      .fold(0.0, (s, a) => s + a);
                  if (currentTotal + v > budget.monthlyTotal) {
                    Navigator.pop(context);
                    _showExceedWarning(context, v, currentTotal + v,
                        budget.monthlyTotal, selectedId!, sym);
                    return;
                  }
                }
                context.read<BudgetProvider>()
                    .setCategoryBudget(selectedId!, v);
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

  void _showExceedWarning(BuildContext context, double v, double newTotal,
      double monthlyTotal, String selectedId, String sym) {
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
        icon: Icon(Icons.warning_amber_rounded,
            color: kWarning, size: 40),
        title: Text('Budget Exceeded!',
          style: TextStyle(
            color: t.textPrimary, fontWeight: FontWeight.bold)),
        content: Text(
          'Adding $sym ${v.toStringAsFixed(0)} brings category budgets to '
          '$sym ${newTotal.toStringAsFixed(0)}, exceeding your monthly budget of '
          '$sym ${monthlyTotal.toStringAsFixed(0)}.',
          style: TextStyle(color: t.textSecond)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel Adding',
                style: TextStyle(color: t.textSecond))),
          FilledButton.icon(
            icon:  const Icon(Icons.edit, size: 16),
            label: const Text('Reset Monthly Budget'),
            onPressed: () {
              Navigator.pop(context);
              context.read<BudgetProvider>()
                  .setCategoryBudget(selectedId, v);
              _editMonthlyBudget(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: t.accentGlow,
              foregroundColor: kAccent,
              side: const BorderSide(color: kAccent))),
        ],
      );},
    );
  }

  void _editCatBudget(BuildContext context, String catId, double current) {
    final t = EzzeTheme.of(context);
    final ctrl = TextEditingController(text: current.toStringAsFixed(0));
    final sym  = context.read<SettingsProvider>().currencySymbol;
    _showDialog(context,
      title: '✏️  Edit Category Budget',
      child: TextField(
        controller:   ctrl,
        keyboardType: TextInputType.number,
        style:        TextStyle(color: t.textPrimary),
        decoration:   InputDecoration(labelText: 'Amount', prefixText: '$sym '),
        autofocus:    true,
      ),
      onSave: () {
        final v = double.tryParse(ctrl.text);
        if (v != null && v > 0)
          context.read<BudgetProvider>().setCategoryBudget(catId, v);
      },
    );
  }

  void _showDialog(BuildContext context,
      {required String title, required Widget child,
       required VoidCallback onSave}) {
    showDialog(
      context: context,
      builder: (_) {
          final t = EzzeTheme.of(context);
          return AlertDialog(
        backgroundColor: t.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: t.border)),
        title: Text(title,
          style: TextStyle(color: t.textPrimary, fontSize: 17)),
        content: child,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: t.textSecond))),
          FilledButton(
            onPressed: () { onSave(); Navigator.pop(context); },
            style: FilledButton.styleFrom(
              backgroundColor: t.accentGlow,
              foregroundColor: kAccent,
              side: const BorderSide(color: kAccent)),
            child: const Text('Save')),
        ],
      );},
    );
  }
}
