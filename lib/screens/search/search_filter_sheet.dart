// ============================================================
//  screens/search/search_filter_sheet.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
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
    _searchCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;
    final expenses   = context.watch<ExpenseProvider>();
    final settings   = context.read<SettingsProvider>();

    DateTime? from;
    DateTime? to;
    final now = DateTime.now();
    switch (_dateFilter) {
      case 'today':
        from = DateTime(now.year, now.month, now.day);
        to   = now;
        break;
      case 'week':
        from = now.subtract(const Duration(days: 7));
        to   = now;
        break;
      case 'month':
        from = DateTime(now.year, now.month, 1);
        to   = now;
        break;
      case 'custom':
        from = _customFrom;
        to   = _customTo;
        break;
    }

    final results = expenses.filter(
      query:      _query,
      categoryId: _categoryId,
      from:       from,
      to:         to,
      minAmount:  _minAmount,
      maxAmount:  _maxAmount,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize:     0.5,
      maxChildSize:     0.95,
      expand:           false,
      builder: (_, ctrl) => Column(
        children: [
          Container(
            width:  40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color:        Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Search & Filter',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(onPressed: _reset, child: const Text('Reset')),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: ctrl,
              padding:    const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Search
                TextField(
                  controller: _searchCtrl,
                  onChanged:  (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    hintText:   'Search by title or note...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 16),

                // Date filters
                Text('Date Range',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _dateChip('All',        'all'),
                    _dateChip('Today',      'today'),
                    _dateChip('This Week',  'week'),
                    _dateChip('This Month', 'month'),
                    _dateChip('Custom',     'custom'),
                  ],
                ),
                if (_dateFilter == 'custom') ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon:  const Icon(Icons.calendar_today, size: 16),
                          label: Text(_customFrom != null
                              ? _fmt(_customFrom!)
                              : 'From'),
                          onPressed: () async {
                            final d = await showDatePicker(
                              context:     context,
                              initialDate: _customFrom ?? DateTime.now(),
                              firstDate:   DateTime(2020),
                              lastDate:    DateTime.now(),
                            );
                            if (d != null)
                              setState(() => _customFrom = d);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon:  const Icon(Icons.calendar_today, size: 16),
                          label: Text(_customTo != null
                              ? _fmt(_customTo!)
                              : 'To'),
                          onPressed: () async {
                            final d = await showDatePicker(
                              context:     context,
                              initialDate: _customTo ?? DateTime.now(),
                              firstDate:   DateTime(2020),
                              lastDate:    DateTime.now(),
                            );
                            if (d != null)
                              setState(() => _customTo = d);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),

                // Category filter
                Text('Category',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing:    8,
                  runSpacing: 4,
                  children: [
                    FilterChip(
                      label:      const Text('All'),
                      selected:   _categoryId.isEmpty,
                      onSelected: (_) =>
                          setState(() => _categoryId = ''),
                    ),
                    ...categories.map((c) => FilterChip(
                      avatar:        Text(c.icon),
                      label:         Text(c.name),
                      selected:      _categoryId == c.id,
                      selectedColor: c.color.withOpacity(0.2),
                      onSelected:    (_) => setState(() =>
                          _categoryId =
                              _categoryId == c.id ? '' : c.id),
                    )),
                  ],
                ),
                const SizedBox(height: 16),

                // Amount range
                Text('Amount Range',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller:  _minCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText:  'Min',
                          prefixText: '${settings.currencySymbol} ',
                        ),
                        onChanged: (v) => setState(
                            () => _minAmount = double.tryParse(v)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller:  _maxCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText:  'Max',
                          prefixText: '${settings.currencySymbol} ',
                        ),
                        onChanged: (v) => setState(
                            () => _maxAmount = double.tryParse(v)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Results
                Text('${results.length} results',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                ...results.map((e) {
                  final cat = context
                      .read<CategoryProvider>()
                      .getById(e.categoryId);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Text(cat?.icon ?? '📦',
                          style: const TextStyle(fontSize: 24)),
                      title:    Text(e.title),
                      subtitle: Text(_buildSearchSubtitle(cat, e)),
                      trailing: Text(
                        '${settings.currencySymbol} ${e.amount.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddEditExpenseScreen(expense: e),
                          ),
                        );
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
    );
  }

  String _buildSearchSubtitle(CategoryModel? cat, ExpenseModel e) {
    final catName = cat?.name ?? 'Unknown';
    if (e.subCategory.isEmpty) return '$catName • ${_fmt(e.date)}';
    if (catName == kCatFriendlyLoan)
      return '$catName • 🤝 ${e.subCategory} • ${_fmt(e.date)}';
    return '$catName • ${e.subCategory} • ${_fmt(e.date)}';
  }

  Widget _dateChip(String label, String value) => FilterChip(
    label:      Text(label),
    selected:   _dateFilter == value,
    onSelected: (_) => setState(() => _dateFilter = value),
  );

  void _reset() {
    _searchCtrl.clear();
    _minCtrl.clear();
    _maxCtrl.clear();
    setState(() {
      _query      = '';
      _categoryId = '';
      _dateFilter = 'all';
      _customFrom = null;
      _customTo   = null;
      _minAmount  = null;
      _maxAmount  = null;
    });
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
