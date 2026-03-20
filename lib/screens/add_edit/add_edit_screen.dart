// ============================================================
//  screens/add_edit/add_edit_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../models/expense_model.dart';
import '../../models/category_model.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final ExpenseModel? expense;
  const AddEditExpenseScreen({super.key, this.expense});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _loanPersonCtrl;
  late DateTime _selectedDate;
  String _selectedCategoryId  = '';
  String _selectedSubCategory = '';

  bool get isEdit => widget.expense != null;

  String _selectedCatName(List<CategoryModel> cats) {
    try { return cats.firstWhere((c) => c.id == _selectedCategoryId).name; }
    catch (_) { return ''; }
  }

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _titleCtrl      = TextEditingController(text: e?.title ?? '');
    _amountCtrl     = TextEditingController(
        text: e != null ? e.amount.toStringAsFixed(0) : '');
    _notesCtrl      = TextEditingController(text: e?.notes ?? '');
    _loanPersonCtrl = TextEditingController(text: e?.subCategory ?? '');
    _selectedDate        = e?.date ?? DateTime.now();
    _selectedCategoryId  = e?.categoryId ?? '';
    _selectedSubCategory = e?.subCategory ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedCategoryId.isEmpty) {
      final cats = context.read<CategoryProvider>().categories;
      if (cats.isNotEmpty) _selectedCategoryId = cats.first.id;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    _loanPersonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;
    final settings   = context.read<SettingsProvider>();
    final catName    = _selectedCatName(categories);
    final isBills    = catName == kCatBills;
    final isOther    = catName == kCatOther;
    final isLoan     = catName == kCatFriendlyLoan;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Expense' : 'Add Expense'),
        actions: [
          if (isEdit)
            IconButton(
              icon:      const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Title ───────────────────────────────────────
            TextFormField(
              controller:           _titleCtrl,
              decoration:           const InputDecoration(
                labelText:  'Title',
                prefixIcon: Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),

            // ── Amount ──────────────────────────────────────
            TextFormField(
              controller: _amountCtrl,
              decoration: InputDecoration(
                labelText:  'Amount',
                prefixIcon: const Icon(Icons.payments_outlined),
                prefixText: '${settings.currencySymbol} ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
              ],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter an amount';
                if (double.tryParse(v) == null) return 'Invalid amount';
                if (double.parse(v) <= 0)
                  return 'Amount must be greater than 0';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Category chips ───────────────────────────────
            Text('Category',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing:    8,
              runSpacing: 8,
              children: categories.map((cat) {
                final selected = _selectedCategoryId == cat.id;
                return ChoiceChip(
                  selected: selected,
                  onSelected: (_) => setState(() {
                    _selectedCategoryId  = cat.id;
                    _selectedSubCategory = '';
                    _loanPersonCtrl.clear();
                  }),
                  avatar: Text(cat.icon,
                      style: const TextStyle(fontSize: 14)),
                  label:         Text(cat.name),
                  selectedColor: cat.color.withOpacity(0.25),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // ── Bills subcategory dropdown ───────────────────
            if (isBills) ...[
              Text('Bill Type',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: kBillsSubCategories.contains(_selectedSubCategory)
                    ? _selectedSubCategory
                    : kBillsSubCategories.first,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.receipt_outlined),
                  labelText:  'Select bill type',
                ),
                items: kBillsSubCategories
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedSubCategory = v ?? ''),
              ),
              const SizedBox(height: 16),
            ],

            // ── Other subcategory dropdown ───────────────────
            if (isOther) ...[
              Text('Sub-Category',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: kOtherSubCategories.contains(_selectedSubCategory)
                    ? _selectedSubCategory
                    : kOtherSubCategories.first,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.folder_outlined),
                  labelText:  'Select sub-category',
                ),
                items: kOtherSubCategories
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedSubCategory = v ?? ''),
              ),
              const SizedBox(height: 16),
            ],

            // ── Friendly Loan: person name ───────────────────
            if (isLoan) ...[
              TextFormField(
                controller: _loanPersonCtrl,
                decoration: const InputDecoration(
                  labelText:  'Person Name',
                  prefixIcon: Icon(Icons.person_outline),
                  hintText:   'Who did you lend to?',
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (isLoan && (v == null || v.trim().isEmpty))
                        ? "Please enter the person's name"
                        : null,
              ),
              const SizedBox(height: 16),
            ],

            // ── Date picker ──────────────────────────────────
            InkWell(
              onTap:        _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText:  'Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(_formatDate(_selectedDate)),
              ),
            ),
            const SizedBox(height: 16),

            // ── Notes ────────────────────────────────────────
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText:          'Notes (optional)',
                prefixIcon:         Icon(Icons.note_outlined),
                alignLabelWithHint: true,
              ),
              maxLines:           3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // ── Save button ──────────────────────────────────
            FilledButton.icon(
              onPressed: _save,
              icon:      Icon(isEdit ? Icons.save : Icons.add),
              label:     Text(isEdit ? 'Update Expense' : 'Save Expense'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context:     context,
      initialDate: _selectedDate,
      firstDate:   DateTime(2020),
      lastDate:    DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final cats    = context.read<CategoryProvider>().categories;
    final catName = _selectedCatName(cats);
    final subCat  = catName == kCatFriendlyLoan
        ? _loanPersonCtrl.text.trim()
        : _selectedSubCategory;

    final ep = context.read<ExpenseProvider>();
    final expense = ExpenseModel(
      id:          widget.expense?.id ?? const Uuid().v4(),
      title:       _titleCtrl.text.trim(),
      amount:      double.parse(_amountCtrl.text),
      categoryId:  _selectedCategoryId,
      date:        _selectedDate,
      notes:       _notesCtrl.text.trim(),
      subCategory: subCat,
    );

    if (isEdit) {
      ep.updateExpense(expense);
    } else {
      ep.addExpense(expense);
    }
    Navigator.pop(context);
  }

  void _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:   const Text('Delete Expense'),
        content: const Text('Are you sure?'),
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
    if (confirm == true && mounted) {
      context.read<ExpenseProvider>().deleteExpense(widget.expense!.id);
      Navigator.pop(context);
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
