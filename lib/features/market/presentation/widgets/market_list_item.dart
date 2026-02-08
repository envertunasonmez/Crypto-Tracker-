import 'package:flutter/material.dart';

import 'package:trade_app/core/utils/format_utils.dart';
import 'package:trade_app/features/market/data/models/ticker.dart';

class MarketListItem extends StatelessWidget {
  final Ticker ticker;
  final VoidCallback onTap;

  const MarketListItem({
    super.key,
    required this.ticker,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = ticker.isPositive;

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Material(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _SymbolAvatar(symbol: ticker.symbol),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticker.symbol,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _ChangePercentChip(
                          priceChangePercent: ticker.priceChangePercent,
                          isPositive: isPositive,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        FormatUtils.formatPrice(ticker.lastPrice),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SymbolAvatar extends StatelessWidget {
  final String symbol;

  const _SymbolAvatar({required this.symbol});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          symbol.length >= 2 ? symbol.substring(0, 2).toUpperCase() : symbol.toUpperCase(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _ChangePercentChip extends StatelessWidget {
  final String priceChangePercent;
  final bool isPositive;

  const _ChangePercentChip({
    required this.priceChangePercent,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prefix = priceChangePercent.startsWith('-') ? '' : '+';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPositive
            ? const Color(0xFF22C55E).withOpacity(0.12)
            : const Color(0xFFEF4444).withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$prefix$priceChangePercent%',
        style: theme.textTheme.labelMedium?.copyWith(
          color: isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
