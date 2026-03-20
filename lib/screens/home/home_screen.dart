// ============================================================
//  screens/home/home_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/expense_tile.dart';
import '../../widgets/category_chip.dart';
import '../add_edit/add_edit_screen.dart';
import '../search/search_filter_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategoryId = '';
  String _searchQuery        = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenses   = context.watch<ExpenseProvider>();
    final categories = context.watch<CategoryProvider>();
    final settings   = context.watch<SettingsProvider>();
    final budget     = context.watch<BudgetProvider>().budget;
    final budgetSet  = budget.monthlyTotal > 0;
    final sym        = settings.currencySymbol;

    final remaining = budgetSet
        ? budget.monthlyTotal - expenses.totalThisMonth
        : null;
    final remainingColor = remaining == null
        ? Colors.teal
        : remaining < 0
        ? Colors.red
        : remaining == 0
        ? Colors.orange
        : Colors.teal;

    final filtered = expenses.filter(
      query:      _searchQuery,
      categoryId: _selectedCategoryId,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ───────────────────────────────────────
          SliverAppBar(
            expandedHeight: budgetSet ? 290 : 170,
            floating:       false,
            pinned:         true,
            title: const Text(kAppName,
                style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon:      const Icon(Icons.search),
                onPressed: () => _openSearch(context),
              ),
              IconButton(
                icon:      const Icon(Icons.filter_list),
                onPressed: () => _openFilter(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end:   Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 88, 8, 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Row 1: This Month + Today — always visible
                      Row(
                        children: [
                          Expanded(
                            child: SummaryCard(
                              label:  'This Month',
                              amount: '$sym ${expenses.totalThisMonth.toStringAsFixed(0)}',
                              icon:   Icons.calendar_month,
                              color:  Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SummaryCard(
                              label:  'Today',
                              amount: '$sym ${expenses.totalToday.toStringAsFixed(0)}',
                              icon:   Icons.today,
                              color:  Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      // Row 2: Budget + Remaining — only when budget is set
                      if (budgetSet && remaining != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: SummaryCard(
                                label:  'Monthly Budget',
                                amount: '$sym ${budget.monthlyTotal.toStringAsFixed(0)}',
                                icon:   Icons.account_balance_wallet_outlined,
                                color:  Colors.purple,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SummaryCard(
                                label:  remaining < 0 ? 'Over Budget' : 'Remaining',
                                amount: '$sym ${remaining.abs().toStringAsFixed(0)}',
                                icon:   remaining < 0
                                    ? Icons.trending_up
                                    : Icons.savings_outlined,
                                color:  remainingColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Search bar ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged:  (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText:   'Search expenses...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon:      const Icon(Icons.clear),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                      : null,
                ),
              ),
            ),
          ),

          // ── Category chips ────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView(
                padding:         const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label:      const Text('All'),
                      selected:   _selectedCategoryId.isEmpty,
                      onSelected: (_) =>
                          setState(() => _selectedCategoryId = ''),
                    ),
                  ),
                  ...categories.categories.map((cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CategoryChip(
                      cat:      cat,
                      selected: _selectedCategoryId == cat.id,
                      onTap:    () => setState(() =>
                      _selectedCategoryId =
                      _selectedCategoryId == cat.id ? '' : cat.id),
                    ),
                  )),
                ],
              ),
            ),
          ),

          // ── Transactions header ───────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                filtered.isEmpty
                    ? 'No transactions'
                    : '${filtered.length} transactions',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // ── Transactions list ─────────────────────────────
          filtered.isEmpty
              ? SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('💸',
                      style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text('No expenses yet',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Tap + to add your first expense',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          )
              : SliverList(
            delegate: SliverChildBuilderDelegate(
                  (_, i) => ExpenseTile(
                expense:  filtered[i],
                onEdit:   () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddEditExpenseScreen(expense: filtered[i]),
                  ),
                ),
                onDelete: () =>
                    expenses.deleteExpense(filtered[i].id),
              ),
              childCount: filtered.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  void _openSearch(BuildContext context) {
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const SearchFilterSheet(),
    );
  }

  void _openFilter(BuildContext context) {
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const SearchFilterSheet(),
    );
  }
}