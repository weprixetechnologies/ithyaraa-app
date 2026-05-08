import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A premium UI wrapper for flash sale cart items.
/// 
/// Adds:
/// 1. Subtle pulsing gradient background (soft gold to white).
/// 2. Animated flickering "Fire" badge.
class FlashSaleCartItemWrapper extends StatefulWidget {
  final Widget child;
  final bool isFlashSale;

  const FlashSaleCartItemWrapper({
    super.key,
    required this.child,
    required this.isFlashSale,
  });

  @override
  State<FlashSaleCartItemWrapper> createState() => _FlashSaleCartItemWrapperState();
}

class _FlashSaleCartItemWrapperState extends State<FlashSaleCartItemWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    if (widget.isFlashSale) {
      _controller.repeat(reverse: true);
    }

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(FlashSaleCartItemWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlashSale && !oldWidget.isFlashSale) {
      _controller.repeat(reverse: true);
    } else if (!widget.isFlashSale && oldWidget.isFlashSale) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isFlashSale) return widget.child;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Stack(
        children: [
          // 1. Animated Background Layer
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(
                        const Color(0xFFFFF9E6), // Very soft gold
                        const Color(0xFFFFFAF2), // Slightly more orange tint
                        _animation.value,
                      )!,
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.08 + (0.04 * _animation.value)),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: widget.child,
          ),

          // 2. Animated Flame Badge (Top Right)
          const Positioned(
            top: 12,
            right: 45, // Adjusted to avoid overlapping delete button
            child: _FlameBadge(),
          ),
        ],
      ),
    );
  }
}

class _FlameBadge extends StatelessWidget {
  const _FlameBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _FlickeringFlame(),
          const SizedBox(width: 4),
          Text(
            'FLASH SALE',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: Colors.orange.shade800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlickeringFlame extends StatefulWidget {
  const _FlickeringFlame();

  @override
  State<_FlickeringFlame> createState() => _FlickeringFlameState();
}

class _FlickeringFlameState extends State<_FlickeringFlame> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 14,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          _FlamePart(controller: _controller, color: Colors.orange.shade300, scale: 1.0, offset: 0.1),
          _FlamePart(controller: _controller, color: Colors.orange.shade600, scale: 0.8, offset: 0.2),
          _FlamePart(controller: _controller, color: Colors.red.shade600, scale: 0.6, offset: 0.3),
        ],
      ),
    );
  }
}

class _FlamePart extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  final double scale;
  final double offset;

  const _FlamePart({
    required this.controller,
    required this.color,
    required this.scale,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final val = (controller.value + offset) % 1.0;
        final wobble = math.sin(val * math.pi * 2) * 0.1;
        return Transform.translate(
          offset: Offset(wobble * 5, -val * 2),
          child: Transform.scale(
            scale: scale * (0.9 + (0.2 * val)),
            child: Opacity(
              opacity: 0.8 - (0.4 * val),
              child: child,
            ),
          ),
        );
      },
      child: CustomPaint(
        size: const Size(10, 12),
        painter: _FlamePainter(color),
      ),
    );
  }
}

class _FlamePainter extends CustomPainter {
  final Color color;
  _FlamePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0); // Tip
    path.quadraticBezierTo(size.width, size.height * 0.5, size.width * 0.8, size.height);
    path.lineTo(size.width * 0.2, size.height);
    path.quadraticBezierTo(0, size.height * 0.5, size.width / 2, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
