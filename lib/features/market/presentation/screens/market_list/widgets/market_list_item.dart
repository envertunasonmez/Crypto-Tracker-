import 'package:flutter/material.dart';

import 'package:trade_app/core/utils/format_utils.dart';
import 'package:trade_app/features/market/data/models/ticker.dart';

class MarketListItem extends StatefulWidget {
  final Ticker ticker;
  final VoidCallback onTap;
  final int index;

  const MarketListItem({
    super.key,
    required this.ticker,
    required this.onTap,
    this.index = 0,
  });

  @override
  State<MarketListItem> createState() => _MarketListItemState();
}

class _MarketListItemState extends State<MarketListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Staggered animation effect
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) _controller.forward();
    });
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

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isHovered = true),
                  onExit: (_) => setState(() => _isHovered = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.identity()
                      ..translate(0.0, _isHovered ? -4.0 : 0.0),
                    child: Material(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(_isHovered ? 0.7 : 0.5),
                      borderRadius: BorderRadius.circular(20),
                      elevation: _isHovered ? 8 : 0,
                      shadowColor: theme.colorScheme.primary.withOpacity(0.3),
                      child: InkWell(
                        onTap: widget.onTap,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isHovered
                                  ? theme.colorScheme.primary.withOpacity(0.3)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Hero(
                                  tag: 'avatar_${widget.ticker.symbol}',
                                  child: _SymbolAvatar(
                                    symbol: widget.ticker.symbol,
                                    isHovered: _isHovered,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.ticker.symbol,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      _ChangePercentChip(
                                        priceChangePercent: widget.ticker.priceChangePercent,
                                        isPositive: isPositive,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _PriceText(
                                      price: widget.ticker.lastPrice,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    AnimatedRotation(
                                      turns: _isHovered ? 0.0 : 0.0,
                                      duration: const Duration(milliseconds: 200),
                                      child: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 14,
                                        color: theme.colorScheme.onSurfaceVariant
                                            .withOpacity(_isHovered ? 0.8 : 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PriceText extends StatefulWidget {
  final String price;
  final TextStyle? style;

  const _PriceText({required this.price, this.style});

  @override
  State<_PriceText> createState() => _PriceTextState();
}

class _PriceTextState extends State<_PriceText>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(_PriceText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.price != widget.price) {
      _pulseController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.1),
          child: Opacity(
            opacity: (1.0 - (_pulseController.value * 0.3)).clamp(0.7, 1.0),
            child: Text(
              FormatUtils.formatPrice(widget.price),
              style: widget.style,
            ),
          ),
        );
      },
    );
  }
}

class _SymbolAvatar extends StatelessWidget {
  final String symbol;
  final bool isHovered;

  const _SymbolAvatar({required this.symbol, this.isHovered = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isHovered
              ? [
                  theme.colorScheme.primary.withOpacity(0.3),
                  theme.colorScheme.secondary.withOpacity(0.2),
                ]
              : [
                  theme.colorScheme.primary.withOpacity(0.15),
                  theme.colorScheme.primary.withOpacity(0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: isHovered
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Center(
        child: Text(
          symbol.length >= 2 ? symbol.substring(0, 2).toUpperCase() : symbol.toUpperCase(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            fontSize: isHovered ? 16 : 15,
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

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.8 + (value * 0.2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPositive
                      ? [
                          const Color(0xFF22C55E).withOpacity(0.15),
                          const Color(0xFF16A34A).withOpacity(0.1),
                        ]
                      : [
                          const Color(0xFFEF4444).withOpacity(0.15),
                          const Color(0xFFDC2626).withOpacity(0.1),
                        ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isPositive
                      ? const Color(0xFF22C55E).withOpacity(0.3)
                      : const Color(0xFFEF4444).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    size: 16,
                    color: isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                  ),
                  Text(
                    '$prefix$priceChangePercent%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                      fontWeight: FontWeight.w600,
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