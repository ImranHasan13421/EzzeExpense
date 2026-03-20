// ============================================================
//  screens/stats/stats_screen.dart — Dark Vault edition
// ============================================================

import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
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
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = EzzeTheme.of(context);
    return Scaffold(
      backgroundColor: t.bgBase,
      appBar: AppBar(
        title: Text('📊 Analytics'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: kAccent,
          indicatorWeight: 2,
          labelColor: kAccent,
          unselectedLabelColor: t.textSecond,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: '📈  Overview'),
            Tab(text: '📅  Monthly'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _AnalyticsTab(
            period: _period,
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
  final String period;
  final ValueChanged<String> onPeriodChange;
  const _AnalyticsTab({required this.period, required this.onPeriodChange});

  @override
  Widget build(BuildContext context) {
    final t = EzzeTheme.of(context);
    final expenses   = context.watch<ExpenseProvider>();
    final categories = context.watch<CategoryProvider>();
    final settings   = context.read<SettingsProvider>();
    final sym        = settings.currencySymbol;
    final now        = DateTime.now();

    List<ExpenseModel> periodExpenses;
    if (period == 'weekly') {
      periodExpenses = expenses.filter(
          from: now.subtract(const Duration(days: 7)), to: now);
    } else if (period == 'yearly') {
      periodExpenses = expenses.filter(
          from: DateTime(now.year, 1, 1), to: now);
    } else {
      periodExpenses = expenses.thisMonthExpenses;
    }

    final catTotals  = expenses.categoryTotals(periodExpenses);
    final totalSpent = periodExpenses.fold(0.0, (s, e) => s + e.amount);
    final avgDaily   = periodExpenses.isEmpty ? 0.0
        : totalSpent / (period == 'weekly' ? 7
            : period == 'monthly' ? 30 : 365);

    String topCatName = '—';
    if (catTotals.isNotEmpty) {
      final topId  = catTotals.entries
          .reduce((a, b) => a.value > b.value ? a : b).key;
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
              .reduce((a, b) => a.value > b.value ? a : b).key;
          topCatName = '${topCat.name} · $topSub';
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Period toggle
        Container(
          decoration: t.glowCard(radius: 12),
          padding:    const EdgeInsets.all(4),
          child: Row(children: [
            _periodBtn(context, 'weekly',  '📆 Week'),
            _periodBtn(context, 'monthly', '🗓️ Month'),
            _periodBtn(context, 'yearly',  '📅 Year'),
          ]),
        ),
        const SizedBox(height: 16),

        // Insight cards
        Row(children: [
          Expanded(child: _InsightCard(
            emoji: '🏆', title: 'Top Category',
            value: topCatName, color: kPurple)),
          const SizedBox(width: 10),
          Expanded(child: _InsightCard(
            emoji: '📉', title: 'Daily Avg',
            value: '$sym ${avgDaily.toStringAsFixed(0)}', color: kAccent)),
          const SizedBox(width: 10),
          Expanded(child: _InsightCard(
            emoji: '🧾', title: 'Transactions',
            value: '${periodExpenses.length}', color: kWarning)),
        ]),
        SizedBox(height: 16),

        // Total spent banner
        Container(
          decoration: t.accentCard(),
          padding:    const EdgeInsets.all(16),
          child: Row(children: [
            Text('💸', style: TextStyle(fontSize: 28)),
            SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Total Spent 💸',
                style: TextStyle(color: t.textSecond, fontSize: 12)),
              Text('$sym ${totalSpent.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: kAccent, fontSize: 26,
                  fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            ]),
          ]),
        ),
        SizedBox(height: 16),

        // Pie chart
        if (catTotals.isNotEmpty) ...[
          Container(
            decoration: t.glowCard(),
            padding:    const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('🥧 ', style: TextStyle(fontSize: 15)),
                  Text('By Category',
                    style: TextStyle(
                      color: t.textPrimary, fontSize: 15,
                      fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(PieChartData(
                    sections: catTotals.entries.map((entry) {
                      final cat = categories.getById(entry.key);
                      final pct = totalSpent > 0
                          ? (entry.value / totalSpent * 100) : 0.0;
                      return PieChartSectionData(
                        value: entry.value,
                        title: '${pct.toStringAsFixed(0)}%',
                        color: cat != null
                            ? Color(cat.colorValue) : Colors.grey,
                        radius: 75,
                        titleStyle: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700,
                          fontSize: 11),
                      );
                    }).toList(),
                    sectionsSpace:     3,
                    centerSpaceRadius: 45,
                    centerSpaceColor:  t.bgCard,
                  )),
                ),
                const SizedBox(height: 14),
                Wrap(spacing: 12, runSpacing: 6,
                  children: catTotals.entries.map((entry) {
                    final cat = categories.getById(entry.key);
                    return Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(
                          color: cat != null
                              ? Color(cat.colorValue) : Colors.grey,
                          shape: BoxShape.circle),
                      ),
                      SizedBox(width: 5),
                      Text(
                        '${cat?.icon ?? ''} ${cat?.name ?? '?'}: $sym ${entry.value.toStringAsFixed(0)}',
                        style: TextStyle(
                            color: t.textSecond, fontSize: 11)),
                    ]);
                  }).toList(),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],

        // Bar chart
        Container(
          decoration: t.glowCard(),
          padding:    const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(period == 'weekly' ? '📆 ' : '🗓️ ',
                    style: TextStyle(fontSize: 15)),
                Text(period == 'weekly' ? '7-Day Trend' : '6-Month Trend',
                  style: TextStyle(
                    color: t.textPrimary, fontSize: 15,
                    fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                height: 175,
                child: _buildBarChart(context, expenses, period, sym),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _periodBtn(BuildContext context, String value, String label) {
    final t = EzzeTheme.of(context);
    final selected = period == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onPeriodChange(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color:        selected ? kAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(child: Text(label,
            style: TextStyle(
              color:      selected ? t.bgDeep : t.textSecond,
              fontSize:   12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            ))),
        ),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, ExpenseProvider ep,
      String p, String sym) {
    final t = EzzeTheme.of(context);
    final data     = p == 'weekly' ? ep.weeklyTotals() : ep.monthlyTotals();
    final maxY     = data.reduce(max);
    final now      = DateTime.now();
    const weekDays = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    const months   = ['Jan','Feb','Mar','Apr','May','Jun',
                      'Jul','Aug','Sep','Oct','Nov','Dec'];

    return BarChart(BarChartData(
      maxY: maxY == 0 ? 100 : maxY * 1.25,
      barGroups: data.asMap().entries.map((e) => BarChartGroupData(
        x: e.key,
        barRods: [BarChartRodData(
          toY:   e.value,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
          gradient: e.value == 0 ? null : const LinearGradient(
            colors: [kAccent, kAccentLight],
            begin:  Alignment.bottomCenter,
            end:    Alignment.topCenter,
          ),
          color: e.value == 0 ? t.bgCardAlt : null,
        )],
      )).toList(),
      titlesData: FlTitlesData(
        leftTitles:   const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
        topTitles:    const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
        rightTitles:  const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (v, _) {
            final i = v.toInt();
            String label;
            if (p == 'weekly') {
              final day = now.subtract(Duration(days: 6 - i));
              label = weekDays[day.weekday - 1];
            } else {
              final month = DateTime(now.year, now.month - (5 - i));
              label = months[month.month - 1];
            }
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(label,
                style: TextStyle(
                    color: t.textHint, fontSize: 10)));
          },
        )),
      ),
      gridData:   FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY == 0 ? 50 : maxY / 3,
        getDrawingHorizontalLine: (_) => FlLine(
          color: t.divider, strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => t.bgCardAlt,
          getTooltipItem: (_, __, rod, ___) => BarTooltipItem(
            '$sym ${rod.toY.toStringAsFixed(0)}',
            const TextStyle(
                color: kAccent, fontWeight: FontWeight.w700,
                fontSize: 12)),
        ),
      ),
    ));
  }
}

// ── Insight Card ──────────────────────────────────────────────
class _InsightCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String value;
  final Color  color;
  const _InsightCard({
    required this.emoji, required this.title,
    required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final t = EzzeTheme.of(context);
    return Container(
      decoration: t.glowCard(),
      padding:    const EdgeInsets.all(12),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 6),
        Text(value,
          style: TextStyle(
            color: color, fontWeight: FontWeight.w700, fontSize: 13),
          textAlign: TextAlign.center,
          maxLines: 2, overflow: TextOverflow.ellipsis),
        SizedBox(height: 2),
        Text(title,
          style: TextStyle(color: t.textSecond, fontSize: 10),
          textAlign: TextAlign.center),
      ]),
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
    final t = EzzeTheme.of(context);
    final expenses   = context.watch<ExpenseProvider>();
    final categories = context.watch<CategoryProvider>();
    final settings   = context.read<SettingsProvider>();
    final sym        = settings.currencySymbol;

    final current = expenses.filter(
      from: DateTime(_selectedMonth.year, _selectedMonth.month, 1),
      to:   DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0),
    );
    final prevMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    final previous  = expenses.filter(
      from: DateTime(prevMonth.year, prevMonth.month, 1),
      to:   DateTime(prevMonth.year, prevMonth.month + 1, 0),
    );
    final total     = current.fold(0.0,  (s, e) => s + e.amount);
    final prevTotal = previous.fold(0.0, (s, e) => s + e.amount);
    final diff      = total - prevTotal;
    final catTotals = expenses.categoryTotals(current);

    String topCat = '—';
    if (catTotals.isNotEmpty) {
      final topId = catTotals.entries
          .reduce((a, b) => a.value > b.value ? a : b).key;
      topCat = '${categories.getById(topId)?.icon ?? ''} '
          '${categories.getById(topId)?.name ?? '—'}';
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Month navigator
        Container(
          decoration: t.glowCard(radius: 12),
          padding:    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => setState(() => _selectedMonth =
                    DateTime(_selectedMonth.year, _selectedMonth.month - 1)),
                icon: Icon(Icons.chevron_left_rounded,
                    color: t.textSecond),
              ),
              Text(_monthName(_selectedMonth),
                style: TextStyle(
                  color: t.textPrimary, fontSize: 16,
                  fontWeight: FontWeight.w700)),
              IconButton(
                onPressed: _selectedMonth.month == DateTime.now().month &&
                        _selectedMonth.year == DateTime.now().year
                    ? null
                    : () => setState(() => _selectedMonth =
                        DateTime(_selectedMonth.year, _selectedMonth.month + 1)),
                icon: Icon(Icons.chevron_right_rounded,
                    color: _selectedMonth.month == DateTime.now().month
                        ? t.textHint : t.textSecond),
              ),
            ],
          ),
        ),
        SizedBox(height: 14),

        // Stats row
        Row(children: [
          Expanded(child: Container(
            decoration: t.accentCard(),
            padding:    const EdgeInsets.all(14),
            child: Column(children: [
              Text('💸', style: TextStyle(fontSize: 24)),
              SizedBox(height: 6),
              Text('Total Spent',
                style: TextStyle(color: t.textSecond, fontSize: 11)),
              const SizedBox(height: 2),
              FittedBox(child: Text('$sym ${total.toStringAsFixed(0)}',
                style: TextStyle(
                  color: kAccent, fontSize: 20,
                  fontWeight: FontWeight.w800))),
            ]),
          )),
          SizedBox(width: 10),
          Expanded(child: Container(
            decoration: t.glowCard(),
            padding:    const EdgeInsets.all(14),
            child: Column(children: [
              Text(diff > 0 ? '📈' : '📉',
                  style: TextStyle(fontSize: 24)),
              SizedBox(height: 6),
              Text('vs Last Month 📊',
                style: TextStyle(color: t.textSecond, fontSize: 11)),
              const SizedBox(height: 2),
              FittedBox(child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    diff > 0 ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: diff > 0 ? kDanger : kAccent, size: 14),
                  const SizedBox(width: 3),
                  Text('$sym ${diff.abs().toStringAsFixed(0)}',
                    style: TextStyle(
                      color:      diff > 0 ? kDanger : kAccent,
                      fontSize:   18, fontWeight: FontWeight.w800)),
                ],
              )),
            ]),
          )),
        ]),
        SizedBox(height: 10),

        // Quick stats
        Container(
          decoration: t.glowCard(),
          child: Column(children: [
            ListTile(
              leading: Text('🏆', style: TextStyle(fontSize: 20)),
              title: Text('Top Spending Category',
                style: TextStyle(color: t.textSecond, fontSize: 13)),
              trailing: Text(topCat,
                style: TextStyle(
                  color: t.textPrimary, fontWeight: FontWeight.w700,
                  fontSize: 13)),
            ),
            Divider(height: 1, color: t.divider),
            ListTile(
              leading: Text('🧾', style: TextStyle(fontSize: 20)),
              title: Text('Total Transactions',
                style: TextStyle(color: t.textSecond, fontSize: 13)),
              trailing: Text('${current.length}',
                style: TextStyle(
                  color: t.textPrimary, fontWeight: FontWeight.w700,
                  fontSize: 13)),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // Category breakdown
        if (catTotals.isNotEmpty) ...[
          Row(children: [
            Text('📋 ', style: TextStyle(fontSize: 14)),
            Text('Category Breakdown',
              style: TextStyle(
                color: t.textPrimary, fontSize: 15,
                fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 10),
          ...catTotals.entries.map((entry) {
            final cat    = categories.getById(entry.key);
            final pct    = total > 0 ? entry.value / total : 0.0;
            final isLoan = cat?.name == kCatFriendlyLoan;
            final hasSub = cat?.name == kCatBills ||
                cat?.name == kCatOther || isLoan;
            final subTotals = <String, double>{};
            if (hasSub) {
              for (final e in current.where((e) =>
                  e.categoryId == entry.key && e.subCategory.isNotEmpty)) {
                subTotals[e.subCategory] =
                    (subTotals[e.subCategory] ?? 0) + e.amount;
              }
            }
            final catColor = cat != null ? Color(cat.colorValue) : kAccent;

            return Container(
              margin:     const EdgeInsets.only(bottom: 8),
              decoration: t.glowCard(),
              padding:    const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color:        catColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                            color: catColor.withOpacity(0.25)),
                      ),
                      child: Center(child: Text(cat?.icon ?? '📦',
                          style: const TextStyle(fontSize: 17))),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(cat?.name ?? '?',
                              style: TextStyle(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                            Text('$sym ${entry.value.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                          ],
                        ),
                        SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value:           pct,
                            minHeight:       5,
                            backgroundColor: t.bgCardAlt,
                            valueColor: AlwaysStoppedAnimation(catColor),
                          ),
                        ),
                      ],
                    )),
                  ]),
                  if (subTotals.isNotEmpty) ...[
                    SizedBox(height: 8),
                    ...subTotals.entries.map((s) => Padding(
                      padding: const EdgeInsets.only(left: 48, top: 3),
                      child: Row(children: [
                        Text(isLoan ? '🤝' : '›',
                          style: TextStyle(
                            fontSize: isLoan ? 12 : 14,
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
                ],
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
