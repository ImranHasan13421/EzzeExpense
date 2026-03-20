// ============================================================
//  screens/stats/stats_screen.dart
// ============================================================

import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../models/expense_model.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  String _period = 'monthly';
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats & Analytics'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'Analytics'),
            Tab(text: 'Monthly Summary'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _AnalyticsTab(
            period:         _period,
            onPeriodChange: (p) => setState(() => _period = p),
          ),
          const _MonthlySummaryTab(),
        ],
      ),
    );
  }
}

// ── Analytics Tab ─────────────────────────────────────────────
class _AnalyticsTab extends StatelessWidget {
  final String _period;
  final ValueChanged<String> onPeriodChange;

  const _AnalyticsTab({
    required String period,
    required this.onPeriodChange,
  }) : _period = period;

  @override
  Widget build(BuildContext context) {
    final expenses   = context.watch<ExpenseProvider>();
    final categories = context.watch<CategoryProvider>();
    final settings   = context.read<SettingsProvider>();
    final sym        = settings.currencySymbol;
    final now        = DateTime.now();

    List<ExpenseModel> periodExpenses;
    if (_period == 'weekly') {
      final from = now.subtract(const Duration(days: 7));
      periodExpenses = expenses.filter(from: from, to: now);
    } else if (_period == 'yearly') {
      periodExpenses =
          expenses.filter(from: DateTime(now.year, 1, 1), to: now);
    } else {
      periodExpenses = expenses.thisMonthExpenses;
    }

    final catTotals  = expenses.categoryTotals(periodExpenses);
    final totalSpent = periodExpenses.fold(0.0, (s, e) => s + e.amount);
    final avgDaily   = periodExpenses.isEmpty
        ? 0.0
        : totalSpent /
            (_period == 'weekly' ? 7 : _period == 'monthly' ? 30 : 365);

    String topCatName = '—';
    if (catTotals.isNotEmpty) {
      final topId  =
          catTotals.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      final topCat = categories.getById(topId);
      topCatName   = topCat?.name ?? '—';
      if (topCat != null &&
          (topCat.name == kCatBills || topCat.name == kCatOther)) {
        final subCounts = <String, double>{};
        for (final e in periodExpenses.where(
            (e) => e.categoryId == topId && e.subCategory.isNotEmpty)) {
          subCounts[e.subCategory] =
              (subCounts[e.subCategory] ?? 0) + e.amount;
        }
        if (subCounts.isNotEmpty) {
          final topSub = subCounts.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key;
          topCatName = '${topCat.name} • $topSub';
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Period selector
        Row(
          children: [
            _periodBtn(context, 'weekly',  'Weekly'),
            const SizedBox(width: 8),
            _periodBtn(context, 'monthly', 'Monthly'),
            const SizedBox(width: 8),
            _periodBtn(context, 'yearly',  'Yearly'),
          ],
        ),
        const SizedBox(height: 16),

        // Insight cards
        Row(
          children: [
            Expanded(
              child: _InsightCard(
                title: 'Top Category',
                value: topCatName,
                icon:  Icons.category,
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _InsightCard(
                title: 'Daily Average',
                value: '$sym ${avgDaily.toStringAsFixed(0)}',
                icon:  Icons.show_chart,
                color: Colors.teal,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _InsightCard(
                title: 'Transactions',
                value: '${periodExpenses.length}',
                icon:  Icons.receipt_long,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Pie chart
        if (catTotals.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('By Category',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sections: catTotals.entries.map((entry) {
                          final cat = categories.getById(entry.key);
                          final pct = totalSpent > 0
                              ? (entry.value / totalSpent * 100)
                              : 0.0;
                          return PieChartSectionData(
                            value: entry.value,
                            title: '${pct.toStringAsFixed(0)}%',
                            color: cat != null
                                ? Color(cat.colorValue)
                                : Colors.grey,
                            radius: 80,
                            titleStyle: const TextStyle(
                              color:      Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize:   12,
                            ),
                          );
                        }).toList(),
                        sectionsSpace:    2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing:    12,
                    runSpacing: 4,
                    children: catTotals.entries.map((entry) {
                      final cat = categories.getById(entry.key);
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width:  12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: cat != null
                                  ? Color(cat.colorValue)
                                  : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${cat?.name ?? '?'}: $sym ${entry.value.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Bar chart
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _period == 'weekly' ? 'Last 7 Days' : 'Last 6 Months',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: _buildBarChart(context, expenses, _period, sym),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _periodBtn(BuildContext context, String value, String label) {
    final selected = _period == value;
    return Expanded(
      child: FilledButton.tonal(
        onPressed: () => onPeriodChange(value),
        style: FilledButton.styleFrom(
          backgroundColor: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundColor: selected ? Colors.white : null,
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildBarChart(
      BuildContext context, ExpenseProvider ep, String p, String sym) {
    final data     = p == 'weekly' ? ep.weeklyTotals() : ep.monthlyTotals();
    final maxY     = data.reduce(max);
    final now      = DateTime.now();
    const weekDays = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    const months   = ['Jan','Feb','Mar','Apr','May','Jun',
                      'Jul','Aug','Sep','Oct','Nov','Dec'];

    return BarChart(
      BarChartData(
        maxY: maxY == 0 ? 100 : maxY * 1.2,
        barGroups: data.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY:          e.value,
                color:        Theme.of(context).colorScheme.primary,
                width:        18,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles:  const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles:   const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                String label;
                if (p == 'weekly') {
                  final day = now.subtract(Duration(days: 6 - i));
                  label = weekDays[day.weekday - 1];
                } else {
                  final month =
                      DateTime(now.year, now.month - (5 - i));
                  label = months[month.month - 1];
                }
                return Text(label,
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
        ),
        gridData:   const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (_, __, rod, ___) => BarTooltipItem(
              '$sym ${rod.toY.toStringAsFixed(0)}',
              const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Insight Card ──────────────────────────────────────────────
class _InsightCard extends StatelessWidget {
  final String  title;
  final String  value;
  final IconData icon;
  final Color   color;

  const _InsightCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(title,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ── Monthly Summary Tab ───────────────────────────────────────
class _MonthlySummaryTab extends StatefulWidget {
  const _MonthlySummaryTab();

  @override
  State<_MonthlySummaryTab> createState() => _MonthlySummaryTabState();
}

class _MonthlySummaryTabState extends State<_MonthlySummaryTab> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final expenses   = context.watch<ExpenseProvider>();
    final categories = context.watch<CategoryProvider>();
    final settings   = context.read<SettingsProvider>();
    final sym        = settings.currencySymbol;

    final current = expenses.filter(
      from: DateTime(_selectedMonth.year, _selectedMonth.month, 1),
      to:   DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0),
    );
    final prevMonth = DateTime(
        _selectedMonth.year, _selectedMonth.month - 1);
    final previous = expenses.filter(
      from: DateTime(prevMonth.year, prevMonth.month, 1),
      to:   DateTime(prevMonth.year, prevMonth.month + 1, 0),
    );

    final total     = current.fold(0.0, (s, e) => s + e.amount);
    final prevTotal = previous.fold(0.0, (s, e) => s + e.amount);
    final diff      = total - prevTotal;
    final catTotals = expenses.categoryTotals(current);

    String topCat = '—';
    if (catTotals.isNotEmpty) {
      final topId = catTotals.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      topCat = categories.getById(topId)?.name ?? '—';
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Month navigator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => setState(() => _selectedMonth =
                  DateTime(_selectedMonth.year, _selectedMonth.month - 1)),
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              _monthName(_selectedMonth),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: _selectedMonth.month == DateTime.now().month &&
                      _selectedMonth.year == DateTime.now().year
                  ? null
                  : () => setState(() => _selectedMonth = DateTime(
                      _selectedMonth.year, _selectedMonth.month + 1)),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Summary row
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Total Spent',
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text('$sym ${total.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:   20)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('vs Last Month',
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            diff > 0
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: diff > 0 ? Colors.red : Colors.green,
                            size:  16,
                          ),
                          Text(
                            '$sym ${diff.abs().toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:   20,
                              color: diff > 0 ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Card(
          child: ListTile(
            leading: const Icon(Icons.emoji_events, color: Colors.amber),
            title:   const Text('Top Spending Category'),
            trailing: Text(topCat,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.receipt_long, color: Colors.blue),
            title:   const Text('Total Transactions'),
            trailing: Text('${current.length}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),

        // Category breakdown
        if (catTotals.isNotEmpty) ...[
          Text('Category Breakdown',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...catTotals.entries.map((entry) {
            final cat    = categories.getById(entry.key);
            final pct    = total > 0 ? entry.value / total : 0.0;
            final isLoan = cat?.name == kCatFriendlyLoan;
            final hasSub = cat?.name == kCatBills ||
                cat?.name == kCatOther ||
                isLoan;

            final subTotals = <String, double>{};
            if (hasSub) {
              for (final e in current.where((e) =>
                  e.categoryId == entry.key &&
                  e.subCategory.isNotEmpty)) {
                subTotals[e.subCategory] =
                    (subTotals[e.subCategory] ?? 0) + e.amount;
              }
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(cat?.icon ?? '📦',
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
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
                                  Text(
                                    '$sym ${entry.value.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: pct,
                                backgroundColor:
                                    Colors.grey.withOpacity(0.2),
                                color: cat != null
                                    ? Color(cat.colorValue)
                                    : Colors.blue,
                                borderRadius:
                                    BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (subTotals.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      ...subTotals.entries.map((s) => Padding(
                        padding:
                            const EdgeInsets.only(left: 34, top: 2),
                        child: Row(
                          children: [
                            Text(
                              isLoan ? '🤝' : '›',
                              style: TextStyle(
                                fontSize: isLoan ? 13 : 16,
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
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  String _monthName(DateTime d) {
    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}
