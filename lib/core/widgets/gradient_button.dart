import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';

/// A beautiful gradient button with shimmer effect
class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Gradient? gradient;
  final double height;
  final double borderRadius;
  final IconData? icon;
  final bool expanded;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.gradient,
    this.height = 56,
    this.borderRadius = 16,
    this.icon,
    this.expanded = true,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        width: widget.expanded ? double.infinity : null,
        height: widget.height,
        decoration: BoxDecoration(
          gradient: widget.onPressed != null
              ? (widget.gradient ?? AppColors.primaryGradient)
              : LinearGradient(
                  colors: [
                    Colors.grey.shade700,
                    Colors.grey.shade800,
                  ],
                ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: widget.onPressed != null
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isLoading ? null : widget.onPressed,
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            splashColor: Colors.white.withOpacity(0.2),
            highlightColor: Colors.white.withOpacity(0.1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                          ],
                          Text(
                            widget.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outline button with gradient border
class GradientOutlineButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final double height;
  final double borderRadius;
  final IconData? icon;
  final bool expanded;

  const GradientOutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient,
    this.height = 56,
    this.borderRadius = 16,
    this.icon,
    this.expanded = true,
  });

  @override
  State<GradientOutlineButton> createState() => _GradientOutlineButtonState();
}

class _GradientOutlineButtonState extends State<GradientOutlineButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        width: widget.expanded ? double.infinity : null,
        height: widget.height,
        decoration: BoxDecoration(
          gradient: widget.gradient ?? AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(widget.borderRadius - 2),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              borderRadius: BorderRadius.circular(widget.borderRadius - 2),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              (widget.gradient ?? AppColors.primaryGradient)
                                  .createShader(bounds),
                          child: Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            (widget.gradient ?? AppColors.primaryGradient)
                                .createShader(bounds),
                        child: Text(
                          widget.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon button with gradient background
class GradientIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final double size;
  final double iconSize;

  const GradientIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.gradient,
    this.size = 48,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(size / 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 3),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: iconSize,
            ),
          ),
        ),
      ),
    ).animate().scale(
          duration: 200.ms,
          curve: Curves.easeOut,
        );
  }
}
