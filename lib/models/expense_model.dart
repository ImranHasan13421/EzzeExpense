// ============================================================
//  models/expense_model.dart
// ============================================================

import 'package:uuid/uuid.dart';

class ExpenseModel {
  final String id;
  String title;
  double amount;
  String categoryId;
  DateTime date;
  String notes;
  /// Stores subcategory for Bills/Other, or person name for Friendly Loan
  String subCategory;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.notes = '',
    this.subCategory = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'amount': amount,
    'categoryId': categoryId,
    'date': date.toIso8601String(),
    'notes': notes,
    'subCategory': subCategory,
  };

  factory ExpenseModel.fromMap(Map<dynamic, dynamic> map) => ExpenseModel(
    id: map['id'] ?? const Uuid().v4(),
    title: map['title'] ?? '',
    amount: (map['amount'] ?? 0).toDouble(),
    categoryId: map['categoryId'] ?? '',
    date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    notes: map['notes'] ?? '',
    subCategory: map['subCategory'] ?? '',
  );
}
