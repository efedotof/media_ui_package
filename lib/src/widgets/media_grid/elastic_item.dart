import 'package:flutter/material.dart';

class ElasticItem extends StatefulWidget {
  final int index;
  final int totalLoadingItems;

  const ElasticItem({
    super.key,
    required this.index,
    required this.totalLoadingItems,
  });

  @override
  State<ElasticItem> createState() => _ElasticItemState();
}

class _ElasticItemState extends State<ElasticItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    Future.delayed(Duration(milliseconds: widget.index * 150), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary.withAlpha(6);
    final baseColor = Colors.grey[300]!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [
                    baseColor,
                    color.withAlpha((0.7 + 0.3 * _controller.value).toInt()),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.8],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha((0.2 * _controller.value).toInt()),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: _buildPulseAnimation(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPulseAnimation() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: RadialGradient(
          colors: [
            Colors.white.withAlpha((0.8 * _controller.value).toInt()),
            Colors.transparent,
          ],
          stops: const [0.1, 0.9],
        ),
      ),
    );
  }
}
