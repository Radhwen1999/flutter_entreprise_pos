import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _controller2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.background,
            Color(0xFF0A0A10),
            Color(0xFF0D0D18),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animated gradient orbs
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _OrbPainter(
                  animation: _controller.value,
                  animation2: _controller2.value,
                ),
                size: MediaQuery.of(context).size,
              );
            },
          ),

          // Subtle grid pattern
          Opacity(
            opacity: 0.03,
            child: CustomPaint(
              painter: _GridPainter(),
              size: MediaQuery.of(context).size,
            ),
          ),

          // Top gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.05),
                  Colors.transparent,
                  AppColors.secondary.withOpacity(0.03),
                ],
                stops: const [0, 0.5, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double animation;
  final double animation2;

  _OrbPainter({
    required this.animation,
    required this.animation2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Primary orb (cyan)
    final primaryOrb = Offset(
      size.width * 0.8 + sin(animation * 2 * pi) * 50,
      size.height * 0.2 + cos(animation * 2 * pi) * 30,
    );

    final primaryPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primary.withOpacity(0.3),
          AppColors.primary.withOpacity(0.1),
          AppColors.primary.withOpacity(0),
        ],
        stops: const [0, 0.5, 1],
      ).createShader(
        Rect.fromCircle(center: primaryOrb, radius: 200),
      );

    canvas.drawCircle(primaryOrb, 200, primaryPaint);

    // Secondary orb (purple)
    final secondaryOrb = Offset(
      size.width * 0.2 + cos(animation * 2 * pi) * 40,
      size.height * 0.7 + sin(animation * 2 * pi) * 40,
    );

    final secondaryPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.secondary.withOpacity(0.25),
          AppColors.secondary.withOpacity(0.08),
          AppColors.secondary.withOpacity(0),
        ],
        stops: const [0, 0.5, 1],
      ).createShader(
        Rect.fromCircle(center: secondaryOrb, radius: 180),
      );

    canvas.drawCircle(secondaryOrb, 180, secondaryPaint);

    // Accent orb (orange)
    final accentOrb = Offset(
      size.width * 0.5 + sin(animation2 * 2 * pi) * 60,
      size.height * 0.4 + cos(animation2 * 2 * pi) * 50,
    );

    final accentPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.accent.withOpacity(0.15),
          AppColors.accent.withOpacity(0.05),
          AppColors.accent.withOpacity(0),
        ],
        stops: const [0, 0.4, 1],
      ).createShader(
        Rect.fromCircle(center: accentOrb, radius: 150),
      );

    canvas.drawCircle(accentOrb, 150, accentPaint);
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.animation2 != animation2;
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 0.5;

    const spacing = 40.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
