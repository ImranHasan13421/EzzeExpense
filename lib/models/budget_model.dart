// ============================================================
//  models/budget_model.dart
// ============================================================

class BudgetModel {
  double monthlyTotal;
  Map<String, double> categoryBudgets;

  BudgetModel({
    this.monthlyTotal = 0,
    Map<String, double>? categoryBudgets,
  }) : categoryBudgets = categoryBudgets ?? {};

  Map<String, dynamic> toMap() => {
    'monthlyTotal': monthlyTotal,
    'categoryBudgets': categoryBudgets,
  };

  factory BudgetModel.fromMap(Map<dynamic, dynamic> map) => BudgetModel(
    monthlyTotal: (map['monthlyTotal'] ?? 0).toDouble(),
    categoryBudgets: Map<String, double>.from(
      (map['categoryBudgets'] as Map? ?? {}).map(
        (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
      ),
    ),
  );
}
