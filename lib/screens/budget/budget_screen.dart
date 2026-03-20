// ============================================================
//  screens/budget/budget_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../widgets/budget_progress_bar.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budget     = context.watch<BudgetProvider>().budget;
    final expenses   = context.watch<ExpenseProvider>();
    final categories = context.watch<CategoryProvider>();
    final settings   = context.read<SettingsProvider>();
    final sym        = settings.currencySymbol;
    final monthSpent = expenses.totalThisMonth;
    final catTotals  = expenses.categoryTotals(expenses.thisMonthExpenses);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        actions: [
          IconButton(
            icon:      const Icon(Icons.edit),
            onPressed: () => _editMonthlyBudget(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Monthly overview card ──────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Monthly Budget',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (budget.monthlyTotal <= 0)
                    OutlinedButton.icon(
                      onPressed: () => _editMonthlyBudget(context),
                      icon:  const Icon(Icons.add),
                      label: const Text('Set Monthly Budget'),
                    )
                  else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$sym ${monthSpent.toStringAsFixed(0)} spent',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        Text('of $sym ${budget.monthlyTotal.toStringAsFixed(0)}',
                            style: TextStyle(
                                color: Colors.grey.shade600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    BudgetProgressBar(
                        spent: monthSpent, total: budget.monthlyTotal),
                    if (monthSpent >= budget.monthlyTotal * 0.8)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(
                              monthSpent > budget.monthlyTotal
                                  ? Icons.cancel
                                  : monthSpent >= budget.monthlyTotal
                                      ? Icons.check_circle
                                      : Icons.warning_amber,
                              color: monthSpent > budget.monthlyTotal
                                  ? Colors.red
                                  : Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                monthSpent > budget.monthlyTotal
                                    ? '❌ You are overspending! $sym ${(monthSpent - budget.monthlyTotal).toStringAsFixed(0)} over budget'
                                    : monthSpent >= budget.monthlyTotal
                                        ? '✅ You have used all your budget!'
                                        : '⚠️ 80% of budget used',
                                style: TextStyle(
                                  color: monthSpent > budget.monthlyTotal
                                      ? Colors.red
                                      : Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Category budgets header ────────────────────────
          Row(
            children: [
              Text('Category Budgets',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _addCategoryBudget(context),
                icon:  const Icon(Icons.add, size: 16),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Category budget cards ──────────────────────────
          if (budget.categoryBudgets.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      const Text('🎯',
                          style: TextStyle(fontSize: 36)),
                      const SizedBox(height: 8),
                      Text('No category budgets set',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text('Tap "Add" to set limits per category',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            )
          else
            ...budget.categoryBudgets.entries.map((entry) {
              final cat        = categories.getById(entry.key);
              final spent      = catTotals[entry.key] ?? 0;
              final pct        = entry.value > 0 ? spent / entry.value : 0.0;
              final isLoanCat  = cat?.name == kCatFriendlyLoan;
              final hasSubCats = cat?.name == kCatBills ||
                  cat?.name == kCatOther ||
                  isLoanCat;

              final subTotals = <String, double>{};
              if (hasSubCats) {
                for (final e in expenses.thisMonthExpenses.where((e) =>
                    e.categoryId == entry.key &&
                    e.subCategory.isNotEmpty)) {
                  subTotals[e.subCategory] =
                      (subTotals[e.subCategory] ?? 0) + e.amount;
                }
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(cat?.icon ?? '📦',
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(cat?.name ?? '?',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    Row(
                                      children: [
                                        Text(
                                          '$sym ${spent.toStringAsFixed(0)} / $sym ${entry.value.toStringAsFixed(0)}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(width: 4),
                                        InkWell(
                                          onTap: () => _editCatBudget(
                                              context, entry.key, entry.value),
                                          child: const Icon(Icons.edit,
                                              size: 14, color: Colors.grey),
                                        ),
                                        const SizedBox(width: 4),
                                        InkWell(
                                          onTap: () => context
                                              .read<BudgetProvider>()
                                              .removeCategoryBudget(entry.key),
                                          child: const Icon(Icons.close,
                                              size: 14, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                BudgetProgressBar(
                                    spent: spent, total: entry.value),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Sub-breakdown rows
                      if (subTotals.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        ...subTotals.entries.map((s) => Padding(
                          padding:
                              const EdgeInsets.only(left: 32, top: 2),
                          child: Row(
                            children: [
                              Text(
                                isLoanCat ? '🤝' : '›',
                                style: TextStyle(
                                  fontSize: isLoanCat ? 13 : 16,
                                  color:    Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(s.key,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color:    Colors.grey.shade700)),
                              ),
                              Text(
                                '$sym ${s.value.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontSize:   12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        )),
                      ],
                      // Warning message
                      if (pct >= 0.8)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(
                                spent > entry.value
                                    ? Icons.cancel
                                    : pct >= 1
                                        ? Icons.check_circle
                                        : Icons.warning_amber,
                                color: spent > entry.value
                                    ? Colors.red
                                    : Colors.orange,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  spent > entry.value
                                      ? 'You are overspending on ${cat?.name}! $sym ${(spent - entry.value).toStringAsFixed(0)} over budget'
                                      : pct >= 1
                                          ? 'You have used all your budget!'
                                          : 'Almost at budget limit for ${cat?.name}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: spent > entry.value
                                        ? Colors.red
                                        : Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  // ── Dialogs ────────────────────────────────────────────────
  void _editMonthlyBudget(BuildContext context) {
    final ctrl = TextEditingController(
      text: context.read<BudgetProvider>().budget.monthlyTotal > 0
          ? context
              .read<BudgetProvider>()
              .budget
              .monthlyTotal
              .toStringAsFixed(0)
          : '',
    );
    final sym = context.read<SettingsProvider>().currencySymbol;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:   const Text('Set Monthly Budget'),
        content: TextField(
          controller:   ctrl,
          keyboardType: TextInputType.number,
          decoration:   InputDecoration(
              labelText: 'Amount', prefixText: '$sym '),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text);
              if (v != null && v > 0) {
                context.read<BudgetProvider>().setMonthlyBudget(v);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addCategoryBudget(BuildContext context) {
    final cats   = context.read<CategoryProvider>().categories;
    final budget = context.read<BudgetProvider>().budget;
    final sym    = context.read<SettingsProvider>().currencySymbol;

    final available =
        cats.where((c) => !budget.categoryBudgets.containsKey(c.id)).toList();
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All categories have budgets')),
      );
      return;
    }

    String? selectedId = available.first.id;
    final ctrl         = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title:   const Text('Category Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedId,
                items: available
                    .map((c) => DropdownMenuItem(
                        value: c.id, child: Text('${c.icon} ${c.name}')))
                    .toList(),
                onChanged: (v) => set(() => selectedId = v),
                decoration:
                    const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller:   ctrl,
                keyboardType: TextInputType.number,
                decoration:   InputDecoration(
                  labelText:  'Budget amount',
                  prefixText: '$sym ',
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final v = double.tryParse(ctrl.text);
                if (v == null || v <= 0 || selectedId == null) return;

                if (budget.monthlyTotal > 0) {
                  final currentCatTotal = budget.categoryBudgets.values
                      .fold(0.0, (sum, amt) => sum + amt);
                  final newTotal = currentCatTotal + v;

                  if (newTotal > budget.monthlyTotal) {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        icon: const Icon(Icons.warning_amber_rounded,
                            color: Colors.orange, size: 40),
                        title: const Text('Budget Exceeded!',
                            style:
                                TextStyle(fontWeight: FontWeight.bold)),
                        content: Text(
                          'Adding $sym ${v.toStringAsFixed(0)} would bring category budgets to '
                          '$sym ${newTotal.toStringAsFixed(0)}, which exceeds your monthly budget of '
                          '$sym ${budget.monthlyTotal.toStringAsFixed(0)}. '
                          'Would you like to reset your monthly budget to fit, or cancel?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel Adding'),
                          ),
                          FilledButton.icon(
                            icon:  const Icon(Icons.edit),
                            label: const Text('Reset Monthly Budget'),
                            onPressed: () {
                              Navigator.pop(context);
                              context
                                  .read<BudgetProvider>()
                                  .setCategoryBudget(selectedId!, v);
                              _editMonthlyBudget(context);
                            },
                          ),
                        ],
                      ),
                    );
                    return;
                  }
                }

                context
                    .read<BudgetProvider>()
                    .setCategoryBudget(selectedId!, v);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _editCatBudget(
      BuildContext context, String catId, double current) {
    final ctrl = TextEditingController(text: current.toStringAsFixed(0));
    final sym  = context.read<SettingsProvider>().currencySymbol;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:   const Text('Edit Category Budget'),
        content: TextField(
          controller:   ctrl,
          keyboardType: TextInputType.number,
          decoration:
              InputDecoration(labelText: 'Amount', prefixText: '$sym '),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text);
              if (v != null && v > 0) {
                context.read<BudgetProvider>().setCategoryBudget(catId, v);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
