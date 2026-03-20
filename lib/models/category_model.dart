// ============================================================
//  models/category_model.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CategoryModel {
  final String id;
  String name;
  String icon;
  int colorValue;
  bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    this.isDefault = false,
  });

  Color get color => Color(colorValue);

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'icon': icon,
    'colorValue': colorValue,
    'isDefault': isDefault,
  };

  factory CategoryModel.fromMap(Map<dynamic, dynamic> map) => CategoryModel(
    id: map['id'] ?? const Uuid().v4(),
    name: map['name'] ?? '',
    icon: map['icon'] ?? '📦',
    colorValue: map['colorValue'] ?? 0xFF757575,
    isDefault: map['isDefault'] ?? false,
  );
}
