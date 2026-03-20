// ============================================================
//  screens/home/home_screen.dart — Dark Vault edition
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
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
  final _searchCtrl = TextEditingController();

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = EzzeTheme.of(context);
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
        ? kAccent
        : remaining < 0 ? kDanger : remaining == 0 ? kWarning : kAccent;

    final filtered = expenses.filter(
      query: _searchQuery, categoryId: _selectedCategoryId);

    return Scaffold(
      backgroundColor: t.bgBase,
      body: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: t.headerGradient(),
              padding: EdgeInsets.only(
                top:    MediaQuery.of(context).padding.top + 12,
                left:   16, right: 16, bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: title + actions
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('💰 EzzeExpense',
                            style: TextStyle(
                              color:      t.textPrimary,
                              fontSize:   22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            )),
                          SizedBox(height: 2),
                          Text(_greeting(),
                            style: TextStyle(
                              color: t.textSecond, fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      _headerBtn(context, Icons.search_rounded,
                          () => _openSearch(context)),
                      const SizedBox(width: 8),
                      _headerBtn(context, Icons.tune_rounded,
                          () => _openFilter(context)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Summary cards row 1
                  Row(children: [
                    Expanded(
                      child: SummaryCard(
                        label:  '📅 This Month',
                        amount: '$sym ${expenses.totalThisMonth.toStringAsFixed(0)}',
                        icon:   Icons.calendar_month_rounded,
                        color:  kBlue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SummaryCard(
                        label:  '🌤️ Today',
                        amount: '$sym ${expenses.totalToday.toStringAsFixed(0)}',
                        icon:   Icons.today_rounded,
                        color:  kWarning,
                      ),
                    ),
                  ]),

                  // Summary cards row 2 — only when budget set
                  if (budgetSet && remaining != null) ...[
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                        child: SummaryCard(
                          label:    '💳 Monthly Budget',
                          amount:   '$sym ${budget.monthlyTotal.toStringAsFixed(0)}',
                          icon:     Icons.account_balance_wallet_rounded,
                          color:    kPurple,
                          isAccent: false,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SummaryCard(
                          label:    remaining < 0 ? '🔴 Over Budget' : '✅ Remaining',
                          amount:   '$sym ${remaining.abs().toStringAsFixed(0)}',
                          icon:     remaining < 0
                              ? Icons.trending_up_rounded
                              : Icons.savings_rounded,
                          color:    remainingColor,
                          isAccent: remaining >= 0,
                        ),
                      ),
                    ]),
                  ],
                ],
              ),
            ),
          ),

          // ── Search bar ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged:  (v) => setState(() => _searchQuery = v),
                style: TextStyle(color: t.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText:   'Search transactions...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
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
              height: 44,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: [
                  _allChip(context),
                  const SizedBox(width: 8),
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
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ── Transactions header ───────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(children: [
                Text('📋 ', style: TextStyle(fontSize: 14)),
                Text(
                  filtered.isEmpty
                      ? 'No transactions'
                      : '${filtered.length} transactions',
                  style: TextStyle(
                    color:      t.textSecond,
                    fontSize:   13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ]),
            ),
          ),

          // ── Transactions list ─────────────────────────────
          filtered.isEmpty
              ? SliverFillRemaining(child: _emptyState(context))
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => ExpenseTile(
                      expense:  filtered[i],
                      onEdit:   () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) =>
                              AddEditExpenseScreen(expense: filtered[i]))),
                      onDelete: () =>
                          expenses.deleteExpense(filtered[i].id),
                    ),
                    childCount: filtered.length,
                  ),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _headerBtn(BuildContext context, IconData icon, VoidCallback onTap) {
    final t = EzzeTheme.of(context);
    return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color:        t.bgCard,
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: t.border),
      ),
      child: Icon(icon, color: t.textSecond, size: 19),
    ),
  );
  }

  Widget _allChip(BuildContext context) {
    final t = EzzeTheme.of(context);
    return GestureDetector(
    onTap: () => setState(() => _selectedCategoryId = ''),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _selectedCategoryId.isEmpty
            ? t.accentGlow : t.bgCardAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _selectedCategoryId.isEmpty
              ? kAccent.withOpacity(0.5) : t.border,
        ),
      ),
      child: Text('✦ All',
        style: TextStyle(
          color:      _selectedCategoryId.isEmpty ? kAccent : t.textSecond,
          fontSize:   15,
          fontWeight: _selectedCategoryId.isEmpty
              ? FontWeight.w800 : FontWeight.w400,
        )),
    ),
  );
  }

  Widget _emptyState(BuildContext context) {
    final t = EzzeTheme.of(context);
    return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color:        t.bgCard,
            shape:        BoxShape.circle,
            border:       Border.all(color: t.border, width: 1),
          ),
          child: Center(
            child: Text('💸', style: TextStyle(fontSize: 36)),
          ),
        ),
        SizedBox(height: 16),
        Text('No expenses yet',
          style: TextStyle(
            color: t.textPrimary, fontSize: 17, fontWeight: FontWeight.w600)),
        SizedBox(height: 6),
        Text('Tap ✚ below to record your first expense',
          style: TextStyle(color: t.textSecond, fontSize: 13)),
      ],
    ),
  );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning ☀️';
    if (h < 17) return 'Good afternoon 🌤️';
    return 'Good evening 🌙';
  }

  void _openSearch(BuildContext context) => showModalBottomSheet(
    context: context, isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const SearchFilterSheet(),
  );

  void _openFilter(BuildContext context) => showModalBottomSheet(
    context: context, isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const SearchFilterSheet(),
  );
}
