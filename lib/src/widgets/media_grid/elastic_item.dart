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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: cs.surfaceContainerHighest,
          ),
        );
      },
    );
  }
}
