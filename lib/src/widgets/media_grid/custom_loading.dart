import 'package:flutter/material.dart';

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
    final color = Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _columns,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _itemCount,
          itemBuilder: (_, index) {
            final delay = (index % _columns) * 0.1;
            final value = (_controller.value - delay).clamp(0.0, 1.0);
            return _LoadingBlock(progress: value, color: color);
          },
        );
      },
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  final double progress;
  final Color color;
  const _LoadingBlock({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey[300]!;

    final fillColor = color.withAlpha((progress * 255).toInt());

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          colors: [baseColor, fillColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
