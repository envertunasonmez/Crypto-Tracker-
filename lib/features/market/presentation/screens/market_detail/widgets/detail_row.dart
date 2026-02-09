import 'package:flutter/material.dart';

class DetailRow extends StatefulWidget {
  final String label;
  final String value;
  final bool isPositive;
  final bool isNegative;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.isPositive = false,
    this.isNegative = false,
  });

  @override
  State<DetailRow> createState() => _DetailRowState();
}

class _DetailRowState extends State<DetailRow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(DetailRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.forward(from: 0.0);
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
    Color? valueColor;
    IconData? icon;
    
    if (widget.isPositive) {
      valueColor = Colors.green.shade700;
      icon = Icons.arrow_upward_rounded;
    }
    if (widget.isNegative) {
      valueColor = Colors.red.shade700;
      icon = Icons.arrow_downward_rounded;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        icon,
                        size: 16,
                        color: valueColor,
                      ),
                    ),
                  Transform.scale(
                    scale: 1.0 + (_controller.value * 0.1),
                    child: Container(
                      padding: widget.isPositive || widget.isNegative
                          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
                          : EdgeInsets.zero,
                      decoration: widget.isPositive || widget.isNegative
                          ? BoxDecoration(
                              color: valueColor?.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: valueColor?.withOpacity(0.3) ?? Colors.transparent,
                              ),
                            )
                          : null,
                      child: Text(
                        widget.value,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: valueColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}