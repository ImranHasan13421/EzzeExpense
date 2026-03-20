// ============================================================
//  screens/search/search_filter_sheet.dart — Dark Vault edition
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../models/expense_model.dart';
import '../../models/category_model.dart';
import '../add_edit/add_edit_screen.dart';

class SearchFilterSheet extends StatefulWidget {
  const SearchFilterSheet({super.key});
  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  final _searchCtrl = TextEditingController();
  final _minCtrl    = TextEditingController();
  final _maxCtrl    = TextEditingController();
  String    _query      = '';
  String    _categoryId = '';
  String    _dateFilter = 'all';
  DateTime? _customFrom;
  DateTime? _customTo;
  double?   _minAmount;
  double?   _maxAmount;

  @override
  void dispose() {
    _searchCtrl.dispose(); _minCtrl.dispose(); _maxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = EzzeTheme.of(context);
    final categories = context.watch<CategoryProvider>().categories;
    final expenses   = context.watch<ExpenseProvider>();
    final settings   = context.read<SettingsProvider>();
    final now        = DateTime.now();

    DateTime? from, to;
    switch (_dateFilter) {
      case 'today': from = DateTime(now.year, now.month, now.day); to = now; break;
      case 'week':  from = now.subtract(const Duration(days: 7));  to = now; break;
      case 'month': from = DateTime(now.year, now.month, 1);       to = now; break;
      case 'custom': from = _customFrom; to = _customTo; break;
    }

    final results = expenses.filter(
      query: _query, categoryId: _categoryId,
      from: from, to: to, minAmount: _minAmount, maxAmount: _maxAmount,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize:     0.5,
      maxChildSize:     0.97,
      expand:           false,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color:        t.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border:       Border(top: BorderSide(color: t.border)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 36, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: t.border, borderRadius: BorderRadius.circular(2)),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Text('🔍 ', style: TextStyle(fontSize: 16)),
                Text('Search & Filter',
                  style: TextStyle(
                    color: t.textPrimary, fontSize: 17,
                    fontWeight: FontWeight.w700)),
                const Spacer(),
                GestureDetector(
                  onTap: _reset,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color:        t.bgCardAlt,
                      borderRadius: BorderRadius.circular(8),
                      border:       Border.all(color: t.border),
                    ),
                    child: Text('Reset',
                      style: TextStyle(color: t.textSecond, fontSize: 12)),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Search
                  TextField(
                    controller: _searchCtrl,
                    style:      TextStyle(color: t.textPrimary),
                    onChanged:  (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText:   'Search by title or note...',
                      prefixIcon: Icon(Icons.search_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date range
                  _sectionLabel(context, '📅  Date Range'),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _dateChip(context, '🔄 All', 'all'),
                    _dateChip(context, '☀️ Today', 'today'),
                    _dateChip(context, '📆 Week', 'week'),
                    _dateChip(context, '🗓️ Month', 'month'),
                    _dateChip(context, '✦ Custom', 'custom'),
                  ]),
                  if (_dateFilter == 'custom') ...[
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(child: _datePicker(context,
                        label: _customFrom != null ? '📅 ${_fmt(_customFrom!)}' : '📅 From',
                        onTap: () async {
                          final d = await _pickDate(_customFrom);
                          if (d != null) setState(() => _customFrom = d);
                        },
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _datePicker(context,
                        label: _customTo != null ? '📅 ${_fmt(_customTo!)}' : '📅 To',
                        onTap: () async {
                          final d = await _pickDate(_customTo);
                          if (d != null) setState(() => _customTo = d);
                        },
                      )),
                    ]),
                  ],
                  const SizedBox(height: 16),

                  // Category
                  _sectionLabel(context, '🏷️  Category'),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _filterChip(context, 'All', null),
                    ...categories.map((c) => GestureDetector(
                      onTap: () => setState(() =>
                          _categoryId = _categoryId == c.id ? '' : c.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: _categoryId == c.id
                              ? Color(c.colorValue).withOpacity(0.15)
                              : t.bgCardAlt,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: _categoryId == c.id
                                ? Color(c.colorValue).withOpacity(0.5)
                                : t.border),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(c.icon, style: TextStyle(fontSize: 13)),
                          SizedBox(width: 5),
                          Text(c.name,
                            style: TextStyle(
                              color: _categoryId == c.id
                                  ? Color(c.colorValue) : t.textSecond,
                              fontSize: 12,
                              fontWeight: _categoryId == c.id
                                  ? FontWeight.w600 : FontWeight.w400,
                            )),
                        ]),
                      ),
                    )),
                  ]),
                  const SizedBox(height: 16),

                  // Amount range
                  _sectionLabel(context, '💰  Amount Range'),
                  SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: TextField(
                      controller:   _minCtrl,
                      style:        TextStyle(color: t.textPrimary),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText:  'Min',
                        prefixText: '${settings.currencySymbol} ',
                      ),
                      onChanged: (v) =>
                          setState(() => _minAmount = double.tryParse(v)),
                    )),
                    SizedBox(width: 10),
                    Expanded(child: TextField(
                      controller:   _maxCtrl,
                      style:        TextStyle(color: t.textPrimary),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText:  'Max',
                        prefixText: '${settings.currencySymbol} ',
                      ),
                      onChanged: (v) =>
                          setState(() => _maxAmount = double.tryParse(v)),
                    )),
                  ]),
                  const SizedBox(height: 16),

                  // Results
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color:        t.accentGlow,
                        borderRadius: BorderRadius.circular(8),
                        border:       Border.all(
                            color: kAccent.withOpacity(0.3)),
                      ),
                      child: Text('${results.length} results',
                        style: const TextStyle(
                          color: kAccent, fontSize: 12,
                          fontWeight: FontWeight.w600)),
                    ),
                  ]),
                  SizedBox(height: 10),
                  ...results.map((e) {
                    final cat = context.read<CategoryProvider>()
                        .getById(e.categoryId);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: t.glowCard(radius: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        leading: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: cat != null
                                ? Color(cat.colorValue).withOpacity(0.12)
                                : t.bgCardAlt,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(cat?.icon ?? '📦',
                                style: TextStyle(fontSize: 18)),
                          ),
                        ),
                        title: Text(e.title,
                          style: TextStyle(
                            color: t.textPrimary, fontSize: 14,
                            fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          _buildSubtitle(cat, e),
                          style: TextStyle(
                              color: t.textSecond, fontSize: 12)),
                        trailing: Text(
                          '${settings.currencySymbol} ${e.amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: kAccent, fontWeight: FontWeight.w700,
                            fontSize: 13)),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(
                              builder: (_) => AddEditExpenseScreen(expense: e)));
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    final t = EzzeTheme.of(context);
    return Text(text,
    style: TextStyle(
      color: t.textSecond, fontSize: 13, fontWeight: FontWeight.w600));
  }

  Widget _dateChip(BuildContext context, String label, String value) {
    final t = EzzeTheme.of(context);
    return GestureDetector(
    onTap: () => setState(() => _dateFilter = value),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _dateFilter == value ? t.accentGlow : t.bgCardAlt,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: _dateFilter == value
              ? kAccent.withOpacity(0.5) : t.border),
      ),
      child: Text(label,
        style: TextStyle(
          color:      _dateFilter == value ? kAccent : t.textSecond,
          fontSize:   12,
          fontWeight: _dateFilter == value
              ? FontWeight.w600 : FontWeight.w400)),
    ),
  );
  }

  Widget _filterChip(BuildContext context, String label, String? catId) {
    final t = EzzeTheme.of(context);
    return GestureDetector(
    onTap: () => setState(() => _categoryId = catId ?? ''),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _categoryId.isEmpty && catId == null
            ? t.accentGlow : t.bgCardAlt,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: _categoryId.isEmpty && catId == null
              ? kAccent.withOpacity(0.5) : t.border),
      ),
      child: Text(label,
        style: TextStyle(
          color: _categoryId.isEmpty && catId == null
              ? kAccent : t.textSecond,
          fontSize: 12)),
    ),
  );
  }

  Widget _datePicker(BuildContext context, {required String label, required VoidCallback onTap}) {
    final t = EzzeTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: t.bgInput,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: t.border),
        ),
        child: Row(children: [
          Icon(Icons.calendar_today_outlined,
              color: t.textSecond, size: 14),
          SizedBox(width: 6),
          Text(label, style: TextStyle(color: t.textSecond, fontSize: 13)),
        ]),
      ),
    );
  }

  String _buildSubtitle(CategoryModel? cat, ExpenseModel e) {
    final n = cat?.name ?? 'Unknown';
    if (e.subCategory.isEmpty) return '$n  ·  ${_fmt(e.date)}';
    if (n == kCatFriendlyLoan)
      return '$n  ·  🤝 ${e.subCategory}  ·  ${_fmt(e.date)}';
    return '$n  ·  ${e.subCategory}  ·  ${_fmt(e.date)}';
  }

  Future<DateTime?> _pickDate(DateTime? initial) => showDatePicker(
    context: context,
    initialDate: initial ?? DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
    builder: (ctx, child) {
      final t = EzzeTheme.of(ctx);
      return Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            primary: kAccent, onPrimary: t.bgDeep,
            surface: t.bgCard, onSurface: t.textPrimary),
        ),
        child: child!,
      );
    },
  );

  void _reset() {
    _searchCtrl.clear(); _minCtrl.clear(); _maxCtrl.clear();
    setState(() {
      _query = ''; _categoryId = ''; _dateFilter = 'all';
      _customFrom = null; _customTo = null;
      _minAmount = null; _maxAmount = null;
    });
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
