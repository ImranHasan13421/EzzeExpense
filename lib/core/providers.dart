// ============================================================
//  core/providers.dart — SettingsProvider, CategoryProvider,
//                        ExpenseProvider, BudgetProvider
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../models/budget_model.dart';
import 'constants.dart';

// ── SettingsProvider ─────────────────────────────────────────
class SettingsProvider extends ChangeNotifier {
  late Box _box;
  bool _isDark = false;
  String _currency = 'BDT';

  bool   get isDark          => _isDark;
  String get currency        => _currency;
  String get currencySymbol  => kCurrencySymbols[_currency] ?? '৳';

  Future<void> init() async {
    _box      = Hive.box(kSettingsBox);
    _isDark   = _box.get('isDark',    defaultValue: false);
    _currency = _box.get('currency',  defaultValue: 'BDT');
  }

  void toggleTheme() {
    _isDark = !_isDark;
    _box.put('isDark', _isDark);
    notifyListeners();
  }

  void setCurrency(String currency) {
    _currency = currency;
    _box.put('currency', currency);
    notifyListeners();
  }
}

// ── CategoryProvider ─────────────────────────────────────────
class CategoryProvider extends ChangeNotifier {
  late Box _box;
  List<CategoryModel> _categories = [];

  List<CategoryModel> get categories => _categories;

  Future<void> init() async {
    _box = Hive.box(kCategoryBox);
    _load();
    if (_categories.isEmpty) _seedDefaults();
  }

  void _load() {
    _categories = _box.values
        .map((e) => CategoryModel.fromMap(e as Map))
        .toList();
  }

  void _seedDefaults() {
    const uuid = Uuid();
    for (final c in kDefaultCategories) {
      final cat = CategoryModel(
        id:         uuid.v4(),
        name:       c['name'],
        icon:       c['icon'],
        colorValue: c['color'],
        isDefault:  true,
      );
      _box.put(cat.id, cat.toMap());
    }
    _load();
    notifyListeners();
  }

  CategoryModel? getById(String id) {
    try { return _categories.firstWhere((c) => c.id == id); }
    catch (_) { return null; }
  }

  Future<void> addCategory(CategoryModel cat) async {
    await _box.put(cat.id, cat.toMap());
    _load();
    notifyListeners();
  }

  Future<void> updateCategory(CategoryModel cat) async {
    await _box.put(cat.id, cat.toMap());
    _load();
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    await _box.delete(id);
    _load();
    notifyListeners();
  }
}

// ── ExpenseProvider ──────────────────────────────────────────
class ExpenseProvider extends ChangeNotifier {
  late Box _box;
  List<ExpenseModel> _expenses = [];

  List<ExpenseModel> get expenses => List.unmodifiable(_expenses);

  List<ExpenseModel> get thisMonthExpenses {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .toList();
  }

  List<ExpenseModel> get todayExpenses {
    final now = DateTime.now();
    return _expenses
        .where((e) =>
            e.date.day   == now.day   &&
            e.date.month == now.month &&
            e.date.year  == now.year)
        .toList();
  }

  double get totalThisMonth =>
      thisMonthExpenses.fold(0, (s, e) => s + e.amount);

  double get totalToday =>
      todayExpenses.fold(0, (s, e) => s + e.amount);

  Future<void> init() async {
    _box = Hive.box(kExpenseBox);
    _load();
  }

  void _load() {
    _expenses = _box.values
        .map((e) => ExpenseModel.fromMap(e as Map))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await _box.put(expense.id, expense.toMap());
    _load();
    notifyListeners();
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await _box.put(expense.id, expense.toMap());
    _load();
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    await _box.delete(id);
    _load();
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _box.clear();
    _load();
    notifyListeners();
  }

  List<ExpenseModel> filter({
    String?   query,
    String?   categoryId,
    DateTime? from,
    DateTime? to,
    double?   minAmount,
    double?   maxAmount,
  }) {
    return _expenses.where((e) {
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        if (!e.title.toLowerCase().contains(q) &&
            !e.notes.toLowerCase().contains(q)) return false;
      }
      if (categoryId != null && categoryId.isNotEmpty &&
          e.categoryId != categoryId) return false;
      if (from != null && e.date.isBefore(from)) return false;
      if (to   != null && e.date.isAfter(to.add(const Duration(days: 1)))) return false;
      if (minAmount != null && e.amount < minAmount) return false;
      if (maxAmount != null && e.amount > maxAmount) return false;
      return true;
    }).toList();
  }

  Map<String, double> categoryTotals(List<ExpenseModel> list) {
    final map = <String, double>{};
    for (final e in list) {
      map[e.categoryId] = (map[e.categoryId] ?? 0) + e.amount;
    }
    return map;
  }

  /// Last 7 days daily totals
  List<double> weeklyTotals() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return _expenses
          .where((e) =>
              e.date.day   == day.day   &&
              e.date.month == day.month &&
              e.date.year  == day.year)
          .fold(0.0, (s, e) => s + e.amount);
    });
  }

  /// Last 6 months monthly totals
  List<double> monthlyTotals() {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final month = DateTime(now.year, now.month - (5 - i));
      return _expenses
          .where((e) =>
              e.date.month == month.month &&
              e.date.year  == month.year)
          .fold(0.0, (s, e) => s + e.amount);
    });
  }

  String exportJson() =>
      jsonEncode(_expenses.map((e) => e.toMap()).toList());

  void importJson(String jsonStr) {
    try {
      final list = jsonDecode(jsonStr) as List;
      _box.clear();
      for (final item in list) {
        final e = ExpenseModel.fromMap(item);
        _box.put(e.id, e.toMap());
      }
      _load();
      notifyListeners();
    } catch (_) {}
  }
}

// ── BudgetProvider ───────────────────────────────────────────
class BudgetProvider extends ChangeNotifier {
  late Box _box;
  BudgetModel _budget = BudgetModel();

  BudgetModel get budget => _budget;

  Future<void> init() async {
    _box = Hive.box(kBudgetBox);
    final raw = _box.get('budget');
    if (raw != null) _budget = BudgetModel.fromMap(raw);
  }

  Future<void> setMonthlyBudget(double amount) async {
    _budget.monthlyTotal = amount;
    await _save();
  }

  Future<void> setCategoryBudget(String catId, double amount) async {
    _budget.categoryBudgets[catId] = amount;
    await _save();
  }

  Future<void> removeCategoryBudget(String catId) async {
    _budget.categoryBudgets.remove(catId);
    await _save();
  }

  Future<void> _save() async {
    await _box.put('budget', _budget.toMap());
    notifyListeners();
  }
}
