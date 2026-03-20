// ============================================================
//  widgets/budget_progress_bar.dart
// ============================================================

import 'package:flutter/material.dart';

class BudgetProgressBar extends StatelessWidget {
  final double spent;
  final double total;

  const BudgetProgressBar({
    super.key,
    required this.spent,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final pct      = total > 0 ? (spent / total).clamp(0.0, 1.0) : 0.0;
    final rawRatio = total > 0 ? spent / total : 0.0;

    Color color;
    if (rawRatio > 1.0) {
      color = Colors.red;     // actually over budget
    } else if (rawRatio >= 1.0) {
      color = Colors.orange;  // exactly at 100%
    } else if (rawRatio >= 0.8) {
      color = Colors.orange;  // 80–99%
    } else {
      color = Colors.green;   // under 80%
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value:           pct,
        minHeight:       10,
        backgroundColor: Colors.grey.withOpacity(0.2),
        color:           color,
      ),
    );
  }
}
