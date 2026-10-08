import 'package:flutter/material.dart';

class ShimmerBlock extends StatefulWidget {
  const ShimmerBlock({
    super.key,
    required this.height,
    this.width = double.infinity,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
  });

  final double height;
  final double width;
  final BorderRadius borderRadius;

  @override
  State<ShimmerBlock> createState() => _ShimmerBlockState();
}

class _ShimmerBlockState extends State<ShimmerBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) => DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        gradient: LinearGradient(
          begin: Alignment(-1.4 + (_controller.value * 2.8), 0),
          end: Alignment(-0.4 + (_controller.value * 2.8), 0),
          colors: const [
            Color(0xFFE6E8E4),
            Color(0xFFF8FAF7),
            Color(0xFFE6E8E4),
          ],
        ),
      ),
      child: SizedBox(width: widget.width, height: widget.height),
    ),
  );
}
