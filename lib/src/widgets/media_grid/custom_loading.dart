import 'package:flutter/material.dart';
import 'elastic_item.dart';

class CustomLoading extends StatefulWidget {
  const CustomLoading({super.key});

  @override
  State<CustomLoading> createState() => _CustomLoadingState();
}

class _CustomLoadingState extends State<CustomLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _itemCount = 16;
  static const _columns = 4;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columns,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _itemCount,
      itemBuilder: (_, index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final scale = 0.5 + 0.5 * (_controller.value);
            return Transform.scale(
              scale: scale,
              child: ElasticItem(index: index, totalLoadingItems: _itemCount),
            );
          },
        );
      },
    );
  }
}
