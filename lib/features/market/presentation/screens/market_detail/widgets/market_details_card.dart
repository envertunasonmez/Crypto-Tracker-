import 'package:flutter/material.dart';

import 'package:trade_app/core/utils/format_utils.dart';
import 'package:trade_app/features/market/data/models/ticker.dart';
import 'package:trade_app/features/market/presentation/screens/market_detail/widgets/detail_row.dart';

class MarketDetailsCard extends StatefulWidget {
  final Ticker ticker;

  const MarketDetailsCard({super.key, required this.ticker});

  @override
  State<MarketDetailsCard> createState() => _MarketDetailsCardState();
}

class _MarketDetailsCardState extends State<MarketDetailsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _itemAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create staggered animations for each detail row
    _itemAnimations = List.generate(
      7,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.1,
            (index * 0.1) + 0.4,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = widget.ticker.isPositive;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.insights_rounded,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '24-Hour Statistics',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _AnimatedDetailRow(
                    animation: _itemAnimations[0],
                    label: 'Price Change',
                    value: FormatUtils.formatPrice(widget.ticker.priceChange),
                    isPositive: isPositive,
                    isNegative: !isPositive,
                  ),
                  _AnimatedDetailRow(
                    animation: _itemAnimations[1],
                    label: '24h Change %',
                    value: '${widget.ticker.priceChangePercent}%',
                    isPositive: isPositive,
                    isNegative: !isPositive,
                  ),
                  _AnimatedDetailRow(
                    animation: _itemAnimations[2],
                    label: '24h Highest',
                    value: FormatUtils.formatPrice(widget.ticker.highPrice),
                  ),
                  _AnimatedDetailRow(
                    animation: _itemAnimations[3],
                    label: '24h Lowest',
                    value: FormatUtils.formatPrice(widget.ticker.lowPrice),
                  ),
                  _AnimatedDetailRow(
                    animation: _itemAnimations[4],
                    label: '24h Volume',
                    value: FormatUtils.formatVolume(widget.ticker.volume),
                  ),
                  _AnimatedDetailRow(
                    animation: _itemAnimations[5],
                    label: 'Best Buy',
                    value: FormatUtils.formatPrice(widget.ticker.bidPrice),
                  ),
                  _AnimatedDetailRow(
                    animation: _itemAnimations[6],
                    label: 'Best Sell',
                    value: FormatUtils.formatPrice(widget.ticker.askPrice),
                    isLast: true,
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

class _AnimatedDetailRow extends StatelessWidget {
  final Animation<double> animation;
  final String label;
  final String value;
  final bool isPositive;
  final bool isNegative;
  final bool isLast;

  const _AnimatedDetailRow({
    required this.animation,
    required this.label,
    required this.value,
    this.isPositive = false,
    this.isNegative = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - animation.value), 0),
          child: Opacity(
            opacity: animation.value,
            child: Column(
              children: [
                DetailRow(
                  label: label,
                  value: value,
                  isPositive: isPositive,
                  isNegative: isNegative,
                ),
                if (!isLast)
                  Divider(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.1),
                    height: 1,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
