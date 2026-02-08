import 'package:flutter/material.dart';

import 'package:trade_app/core/utils/format_utils.dart';
import 'package:trade_app/features/market/data/models/ticker.dart';
import 'package:trade_app/features/market/presentation/widgets/detail_row.dart';

class MarketDetailsCard extends StatelessWidget {
  final Ticker ticker;

  const MarketDetailsCard({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = ticker.isPositive;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '24-Hour Data',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DetailRow(
            label: 'Price Change',
            value: FormatUtils.formatPrice(ticker.priceChange),
            isPositive: isPositive,
            isNegative: !isPositive,
          ),
          DetailRow(
            label: '24h Change %',
            value: '${ticker.priceChangePercent}%',
            isPositive: isPositive,
            isNegative: !isPositive,
          ),
          DetailRow(label: '24h Highest', value: FormatUtils.formatPrice(ticker.highPrice)),
          DetailRow(label: '24h Lowest', value: FormatUtils.formatPrice(ticker.lowPrice)),
          DetailRow(
            label: '24h Volume',
            value: FormatUtils.formatVolume(ticker.volume),
          ),
          DetailRow(label: 'Best Buy', value: FormatUtils.formatPrice(ticker.bidPrice)),
          DetailRow(label: 'Best Sell', value: FormatUtils.formatPrice(ticker.askPrice)),
        ],
      ),
    );
  }
}
