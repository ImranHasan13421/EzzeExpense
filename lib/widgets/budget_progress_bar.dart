import 'package:flutter/material.dart';
import '../core/theme.dart';

class BudgetProgressBar extends StatelessWidget {
  final double spent;
  final double total;
  const BudgetProgressBar({super.key, required this.spent, required this.total});

  @override
  Widget build(BuildContext context) {
    final t = EzzeTheme.of(context);
    final pct      = total > 0 ? (spent / total).clamp(0.0, 1.0) : 0.0;
    final rawRatio = total > 0 ? spent / total : 0.0;

    Color barColor;
    if      (rawRatio > 1.0)  barColor = kDanger;
    else if (rawRatio >= 1.0) barColor = kWarning;
    else if (rawRatio >= 0.8) barColor = kWarning;
    else                      barColor = kAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value:           pct,
            minHeight:       7,
            backgroundColor: t.bgCardAlt,
            valueColor:      AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
        const SizedBox(height: 4),
        Text('${(pct * 100).toStringAsFixed(0)}%',
          style: TextStyle(color: barColor, fontSize: 10,
              fontWeight: FontWeight.w600)),
      ],
    );
  }
}
