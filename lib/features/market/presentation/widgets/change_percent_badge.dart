import 'package:flutter/material.dart';

class ChangePercentBadge extends StatelessWidget {
  final String priceChangePercent;
  final bool isPositive;

  const ChangePercentBadge({
    super.key,
    required this.priceChangePercent,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final prefix = priceChangePercent.startsWith('-') ? '' : '+';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPositive
            ? const Color(0xFF22C55E).withOpacity(0.15)
            : const Color(0xFFEF4444).withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            size: 18,
            color: isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
          ),
          const SizedBox(width: 6),
          Text(
            '$prefix$priceChangePercent%',
            style: TextStyle(
              color: isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
