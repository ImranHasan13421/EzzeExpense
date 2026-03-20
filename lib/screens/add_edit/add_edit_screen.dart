// ============================================================
//  screens/add_edit/add_edit_screen.dart — Dark Vault edition
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
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

  String _catName(List<CategoryModel> cats) {
    try { return cats.firstWhere((c) => c.id == _selectedCategoryId).name; }
    catch (_) { return ''; }
  }

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _titleCtrl       = TextEditingController(text: e?.title ?? '');
    _amountCtrl      = TextEditingController(
        text: e != null ? e.amount.toStringAsFixed(0) : '');
    _notesCtrl       = TextEditingController(text: e?.notes ?? '');
    _loanPersonCtrl  = TextEditingController(text: e?.subCategory ?? '');
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
    _titleCtrl.dispose(); _amountCtrl.dispose();
    _notesCtrl.dispose(); _loanPersonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = EzzeTheme.of(context);
    final categories = context.watch<CategoryProvider>().categories;
    final settings   = context.read<SettingsProvider>();
    final catName    = _catName(categories);
    final isBills    = catName == kCatBills;
    final isOther    = catName == kCatOther;
    final isLoan     = catName == kCatFriendlyLoan;

    return Scaffold(
      backgroundColor: t.bgBase,
      appBar: AppBar(
        backgroundColor: t.bgBase,
        title: Row(children: [
          Text(isEdit ? '✏️  Edit Expense' : '➕  New Expense',
            style: TextStyle(
              color: t.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
        ]),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              color: t.textSecond, size: 18),
        ),
        actions: [
          if (isEdit)
            GestureDetector(
              onTap: _delete,
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:        kDanger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9),
                  border:       Border.all(color: kDanger.withOpacity(0.3)),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: kDanger, size: 18),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Title ───────────────────────────────────────
            _label(context, '📝  Title'),
            SizedBox(height: 8),
            TextFormField(
              controller:         _titleCtrl,
              style:              TextStyle(color: t.textPrimary),
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText:   'e.g. Lunch at Dhaba',
                prefixIcon: Icon(Icons.title_rounded, size: 20),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 18),

            // ── Amount ──────────────────────────────────────
            _label(context, '💵  Amount'),
            const SizedBox(height: 8),
            TextFormField(
              controller:  _amountCtrl,
              style:       const TextStyle(
                color: kAccent, fontSize: 18, fontWeight: FontWeight.w700),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
              ],
              decoration: InputDecoration(
                hintText:  '0',
                hintStyle: TextStyle(color: t.textHint, fontSize: 18),
                prefixText: '${settings.currencySymbol}  ',
                prefixStyle: const TextStyle(
                    color: kAccent, fontSize: 16, fontWeight: FontWeight.w600),
                prefixIcon: const Icon(Icons.payments_outlined, size: 20),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter an amount';
                if (double.tryParse(v) == null) return 'Invalid amount';
                if (double.parse(v) <= 0) return 'Must be greater than 0';
                return null;
              },
            ),
            const SizedBox(height: 18),

            // ── Category ─────────────────────────────────────
            _label(context, '🏷️  Category'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: categories.map((cat) {
                final selected = _selectedCategoryId == cat.id;
                final color    = Color(cat.colorValue);
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedCategoryId  = cat.id;
                    _selectedSubCategory = '';
                    _loanPersonCtrl.clear();
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? color.withOpacity(0.15) : t.bgCardAlt,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? color.withOpacity(0.6) : t.border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(cat.icon,
                          style: TextStyle(fontSize: 15)),
                      SizedBox(width: 6),
                      Text(cat.name,
                        style: TextStyle(
                          color:      selected ? color : t.textSecond,
                          fontSize:   12,
                          fontWeight: selected
                              ? FontWeight.w600 : FontWeight.w400,
                        )),
                    ]),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // ── Bills dropdown ───────────────────────────────
            if (isBills) ...[
              _label(context, '⚡  Bill Type'),
              const SizedBox(height: 8),
              _styledDropdown(context,
                value: kBillsSubCategories.contains(_selectedSubCategory)
                    ? _selectedSubCategory : kBillsSubCategories.first,
                items: kBillsSubCategories,
                icon:  Icons.receipt_outlined,
                hint:  'Select bill type',
                onChanged: (v) =>
                    setState(() => _selectedSubCategory = v ?? ''),
              ),
              const SizedBox(height: 18),
            ],

            // ── Other dropdown ───────────────────────────────
            if (isOther) ...[
              _label(context, '📂  Sub-Category'),
              const SizedBox(height: 8),
              _styledDropdown(context,
                value: kOtherSubCategories.contains(_selectedSubCategory)
                    ? _selectedSubCategory : kOtherSubCategories.first,
                items: kOtherSubCategories,
                icon:  Icons.folder_outlined,
                hint:  'Select sub-category',
                onChanged: (v) =>
                    setState(() => _selectedSubCategory = v ?? ''),
              ),
              const SizedBox(height: 18),
            ],

            // ── Friendly Loan ────────────────────────────────
            if (isLoan) ...[
              _label(context, '🤝  Person Name'),
              SizedBox(height: 8),
              TextFormField(
                controller:         _loanPersonCtrl,
                style:              TextStyle(color: t.textPrimary),
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText:   'Who did you lend to?',
                  prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                ),
                validator: (v) =>
                    (isLoan && (v == null || v.trim().isEmpty))
                        ? "Please enter the person's name" : null,
              ),
              const SizedBox(height: 18),
            ],

            // ── Date picker ──────────────────────────────────
            _label(context, '📅  Date'),
            SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color:        t.bgInput,
                  borderRadius: BorderRadius.circular(12),
                  border:       Border.all(color: t.border),
                ),
                child: Row(children: [
                  Icon(Icons.calendar_today_rounded,
                      color: t.textSecond, size: 18),
                  SizedBox(width: 12),
                  Text(_formatDate(_selectedDate),
                    style: TextStyle(
                        color: t.textPrimary, fontSize: 14)),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded,
                      color: t.textHint, size: 18),
                ]),
              ),
            ),
            SizedBox(height: 18),

            // ── Notes ────────────────────────────────────────
            _label(context, '📌  Notes  (optional)'),
            SizedBox(height: 8),
            TextFormField(
              controller:         _notesCtrl,
              style:              TextStyle(color: t.textPrimary),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:           'Add a note...',
                prefixIcon:         Icon(Icons.notes_rounded, size: 20),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 28),

            // ── Save button ──────────────────────────────────
            GestureDetector(
              onTap: _save,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient:     kAccentGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color:      Color(0x4400C9A7),
                      blurRadius: 16,
                      offset:     Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isEdit ? Icons.save_rounded : Icons.add_rounded,
                          color: t.bgDeep, size: 20),
                      SizedBox(width: 8),
                      Text(
                        isEdit ? 'Update Expense' : '💾  Save Expense',
                        style: TextStyle(
                          color:      t.bgDeep,
                          fontSize:   16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    final t = EzzeTheme.of(context);
    return Text(text,
      style: TextStyle(
        color:      t.textSecond,
        fontSize:   13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ));
  }

  Widget _styledDropdown(BuildContext context, {
    required String value,
    required List<String> items,
    required IconData icon,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    final t = EzzeTheme.of(context);
    return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color:        t.bgInput,
      borderRadius: BorderRadius.circular(12),
      border:       Border.all(color: t.border),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value:    value,
        isExpanded: true,
        dropdownColor: t.bgCard,
        icon: Icon(Icons.keyboard_arrow_down_rounded,
            color: t.textSecond),
        style: TextStyle(color: t.textPrimary, fontSize: 14),
        items: items.map((s) => DropdownMenuItem(
          value: s,
          child: Row(children: [
            Icon(icon, color: t.textSecond, size: 16),
            const SizedBox(width: 10),
            Text(s),
          ]),
        )).toList(),
        onChanged: onChanged,
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
      builder: (ctx, child) {
        final t = EzzeTheme.of(ctx);
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.dark(
              primary:   kAccent,
              onPrimary: t.bgDeep,
              surface:   t.bgCard,
              onSurface: t.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️  Please select a category')));
      return;
    }
    final cats   = context.read<CategoryProvider>().categories;
    final catName = _catName(cats);
    final subCat  = catName == kCatFriendlyLoan
        ? _loanPersonCtrl.text.trim() : _selectedSubCategory;

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
    if (isEdit) ep.updateExpense(expense);
    else        ep.addExpense(expense);
    Navigator.pop(context);
  }

  void _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
          final t = EzzeTheme.of(context);
          return AlertDialog(
        backgroundColor: t.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: t.border)),
        title: Row(children: [
          Icon(Icons.delete_outline, color: kDanger, size: 22),
          SizedBox(width: 8),
          Text('Delete Expense',
              style: TextStyle(color: t.textPrimary, fontSize: 17)),
        ]),
        content: Text('This cannot be undone.',
            style: TextStyle(color: t.textSecond)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: TextStyle(color: t.textSecond))),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: kDanger.withOpacity(0.15),
              foregroundColor: kDanger,
              side: const BorderSide(color: kDanger)),
            child: const Text('Delete')),
        ],
      );},
    );
    if (confirm == true && mounted) {
      context.read<ExpenseProvider>().deleteExpense(widget.expense!.id);
      Navigator.pop(context);
    }
  }

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
