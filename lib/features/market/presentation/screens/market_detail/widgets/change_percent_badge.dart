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

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (value * 0.1),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isPositive
                      ? [
                          const Color(0xFF22C55E).withOpacity(0.2),
                          const Color(0xFF16A34A).withOpacity(0.15),
                        ]
                      : [
                          const Color(0xFFEF4444).withOpacity(0.2),
                          const Color(0xFFDC2626).withOpacity(0.15),
                        ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isPositive
                      ? const Color(0xFF22C55E).withOpacity(0.4)
                      : const Color(0xFFEF4444).withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isPositive
                        ? const Color(0xFF22C55E).withOpacity(0.2)
                        : const Color(0xFFEF4444).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                    size: 20,
                    color: isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$prefix$priceChangePercent%',
                    style: TextStyle(
                      color: isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}