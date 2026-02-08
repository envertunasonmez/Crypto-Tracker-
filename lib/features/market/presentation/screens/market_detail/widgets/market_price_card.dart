import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:trade_app/core/utils/format_utils.dart';
import 'package:trade_app/features/market/data/models/ticker.dart';
import 'package:trade_app/features/market/presentation/screens/market_detail/widgets/change_percent_badge.dart';

class MarketPriceCard extends StatefulWidget {
  final Ticker ticker;

  const MarketPriceCard({super.key, required this.ticker});

  @override
  State<MarketPriceCard> createState() => _MarketPriceCardState();
}

class _MarketPriceCardState extends State<MarketPriceCard>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _gradientController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    );

    _scaleController.forward();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedBuilder(
        animation: _gradientController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(
                  math.cos(_gradientController.value * 2 * math.pi),
                  math.sin(_gradientController.value * 2 * math.pi),
                ),
                end: Alignment(
                  -math.cos(_gradientController.value * 2 * math.pi),
                  -math.sin(_gradientController.value * 2 * math.pi),
                ),
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.secondaryContainer.withOpacity(0.6),
                  theme.colorScheme.tertiaryContainer.withOpacity(0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.ticker.symbol,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _AnimatedPrice(price: widget.ticker.lastPrice),
                const SizedBox(height: 16),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (value * 0.2),
                      child: Opacity(
                        opacity: value,
                        child: ChangePercentBadge(
                          priceChangePercent: widget.ticker.priceChangePercent,
                          isPositive: widget.ticker.isPositive,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedPrice extends StatefulWidget {
  final String price;

  const _AnimatedPrice({required this.price});

  @override
  State<_AnimatedPrice> createState() => _AnimatedPriceState();
}

class _AnimatedPriceState extends State<_AnimatedPrice>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(_AnimatedPrice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.price != widget.price) {
      _controller.forward(from: 0.0).then((_) {
        _controller.reverse();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 + (_controller.value * 0.15);
        final color = ColorTween(
          begin: theme.textTheme.headlineMedium?.color,
          end: theme.colorScheme.primary,
        ).evaluate(_controller);

        return Transform.scale(
          scale: scale,
          child: ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [
                  color ?? theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
                stops: [
                  0.5 - _controller.value * 0.5,
                  0.5 + _controller.value * 0.5,
                ],
              ).createShader(bounds);
            },
            child: Text(
              FormatUtils.formatPrice(widget.price),
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                fontSize: 36,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
