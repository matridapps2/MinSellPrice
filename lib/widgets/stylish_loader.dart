import 'package:flutter/material.dart';
import 'dart:math' as math;

class StylishLoader extends StatefulWidget {
  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;
  final Duration duration;
  final LoaderType type;
  final String? text;
  final TextStyle? textStyle;

  const StylishLoader({
    super.key,
    this.size = 55.0,
    this.primaryColor,
    this.secondaryColor,
    this.duration = const Duration(milliseconds: 1500),
    this.type = LoaderType.wave,
    this.text,
    this.textStyle,
  });

  @override
  State<StylishLoader> createState() => _StylishLoaderState();
}

class _StylishLoaderState extends State<StylishLoader>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _startAnimations();
  }

  void _startAnimations() {
    _controller.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor ?? Theme.of(context).primaryColor;
    final secondaryColor =
        widget.secondaryColor ?? primaryColor.withOpacity(0.3);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: _buildLoader(primaryColor, secondaryColor),
        ),
        if (widget.text != null) ...[
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: 0.6 + (_pulseAnimation.value * 0.4),
                child: Text(
                  widget.text!,
                  style: widget.textStyle ??
                      TextStyle(
                        fontSize: 14,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildLoader(Color primaryColor, Color secondaryColor) {
    switch (widget.type) {
      case LoaderType.wave:
        return _buildWaveLoader(primaryColor, secondaryColor);
    }
  }

  Widget _buildWaveLoader(Color primaryColor, Color secondaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final animationValue = (_controller.value + delay) % 1.0;
            final height = 0.3 + (animationValue * 0.7);

            return Container(
              width: widget.size * 0.15,
              height: widget.size * height,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(widget.size * 0.075),
              ),
            );
          },
        );
      }),
    );
  }
}

class SpinPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  SpinPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw spinning arc
    final arcPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 2),
      0,
      math.pi * 1.5,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum LoaderType {
  wave,
}

// Convenience widgets for common use cases

class WaveLoader extends StatelessWidget {
  final double size;
  final Color? color;
  final String? text;

  const WaveLoader({
    super.key,
    this.size = 60.0,
    this.color,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return StylishLoader(
      size: size,
      type: LoaderType.wave,
      primaryColor: color,
      text: text,
    );
  }
}