import 'package:flutter/material.dart';
import '../core/theme.dart';

class SummaryCard extends StatelessWidget {
  final String   label;
  final String   amount;
  final IconData icon;
  final Color    color;
  final bool     isAccent;

  const SummaryCard({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = EzzeTheme.of(context);
    return Container(
      decoration: isAccent ? t.accentCard() : t.glowCard(),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color:        color.withOpacity(0.13),
              borderRadius: BorderRadius.circular(9),
              border:       Border.all(color: color.withOpacity(0.25), width: 1),
            ),
            child: Icon(icon, color: color, size: 15),
          ),
          SizedBox(height: 10),
          Text(label,
            style: TextStyle(color: t.textSecond, fontSize: 11,
                fontWeight: FontWeight.w500, letterSpacing: 0.3),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(amount,
              style: TextStyle(
                color:      isAccent ? kAccent : t.textPrimary,
                fontSize:   17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              )),
          ),
        ],
      ),
    );
  }
}
