import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/duration_constants.dart';
import '../theme/app_colors.dart';
import 'countdown_progress_painter.dart';
import 'dashed_ring_painter.dart';

enum GlowCircleVariant { water, dust, sonic }

class GlowCircleButton extends StatefulWidget {
  const GlowCircleButton({
    super.key,
    required this.variant,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPlaying = false,
    this.progress = 0,
    this.countdownText,
    this.size,
  });

  final GlowCircleVariant variant;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPlaying;
  final double progress;
  final String? countdownText;
  final double? size;

  @override
  State<GlowCircleButton> createState() => _GlowCircleButtonState();
}

class _GlowCircleButtonState extends State<GlowCircleButton>
    with TickerProviderStateMixin {
  late final AnimationController _slowRingController;
  late final AnimationController _fastRingController;
  late final AnimationController _shakeController;
  double _glowTarget = 1;

  @override
  void initState() {
    super.initState();
    _slowRingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 200),
    )..repeat();
    _fastRingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    )..repeat();
    _shakeController = AnimationController(
      vsync: this,
      duration: DurationConstants.dustShake,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _slowRingController.dispose();
    _fastRingController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size ??
        (widget.variant == GlowCircleVariant.dust
            ? AppConstants.dustGlowButtonSize
            : AppConstants.glowButtonSize);
    final accent = widget.variant == GlowCircleVariant.dust
        ? AppColors.lime
        : AppColors.water;

    return Semantics(
      button: true,
      label: widget.label,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
            begin: 0.2, end: widget.isPlaying ? _glowTarget : 0.2),
        duration: const Duration(milliseconds: 400),
        onEnd: widget.isPlaying
            ? () => setState(() {
                  _glowTarget = _glowTarget == 1 ? 0.2 : 1;
                })
            : null,
        builder: (context, glowValue, child) {
          return GestureDetector(
            onTap: widget.onPressed,
            child: SizedBox.square(
              dimension: size + 62,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.variant == GlowCircleVariant.dust)
                    _DustRings(
                      size: size + 92,
                      slowController: _slowRingController,
                      fastController: _fastRingController,
                    ),
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _gradientForVariant(widget.variant),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(
                            widget.isPlaying ? 0.2 + (0.6 * glowValue) : 0.2,
                          ),
                          blurRadius:
                              widget.isPlaying ? 20 + (60 * glowValue) : 40,
                          spreadRadius: widget.isPlaying ? 6 : 2,
                        ),
                      ],
                    ),
                  ),
                  SizedBox.square(
                    dimension: size,
                    child: CustomPaint(
                      painter: widget.isPlaying
                          ? CountdownProgressPainter(
                              progress: widget.progress,
                              color: accent,
                            )
                          : null,
                    ),
                  ),
                  child!,
                ],
              ),
            ),
          );
        },
        child: _ButtonContent(
          variant: widget.variant,
          icon: widget.icon,
          label: widget.countdownText ?? widget.label,
          shakeController: _shakeController,
        ),
      ),
    );
  }

  Gradient _gradientForVariant(GlowCircleVariant variant) {
    return switch (variant) {
      GlowCircleVariant.water => const RadialGradient(
          colors: [Color(0xFF6EF6FF), AppColors.waterBase, AppColors.water],
        ),
      GlowCircleVariant.dust => const RadialGradient(
          colors: [Color(0xFF292A36), Color(0xFF20202A), Color(0xFF1E1E1E)],
        ),
      GlowCircleVariant.sonic => const RadialGradient(
          colors: [Color(0xFF54F4FF), AppColors.water, AppColors.waterBase],
        ),
    };
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.variant,
    required this.icon,
    required this.label,
    required this.shakeController,
  });

  final GlowCircleVariant variant;
  final IconData icon;
  final String label;
  final AnimationController shakeController;

  @override
  Widget build(BuildContext context) {
    final iconColor = variant == GlowCircleVariant.dust
        ? AppColors.lime
        : AppColors.textPrimary;
    final textColor = variant == GlowCircleVariant.water
        ? AppColors.background
        : AppColors.textPrimary;
    final iconWidget = AnimatedBuilder(
      animation: shakeController,
      builder: (context, child) {
        final offset = variant == GlowCircleVariant.dust
            ? math.sin(shakeController.value * math.pi * 2) * 2
            : 0.0;
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: Icon(icon, color: iconColor, size: 34),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget,
        const SizedBox(height: 16),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (variant == GlowCircleVariant.dust) ...[
          const SizedBox(height: 12),
          const Icon(Icons.graphic_eq, color: AppColors.lime, size: 30),
        ],
      ],
    );
  }
}

class _DustRings extends StatelessWidget {
  const _DustRings({
    required this.size,
    required this.slowController,
    required this.fastController,
  });

  final double size;
  final AnimationController slowController;
  final AnimationController fastController;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotationTransition(
            turns: slowController,
            child: CustomPaint(
              size: Size.square(size),
              painter: DashedRingPainter(
                color: AppColors.lime.withOpacity(0.18),
                strokeWidth: 1.5,
              ),
            ),
          ),
          RotationTransition(
            turns: Tween<double>(begin: 1, end: 0).animate(fastController),
            child: CustomPaint(
              size: Size.square(size - 38),
              painter: DashedRingPainter(
                color: AppColors.lime.withOpacity(0.24),
                strokeWidth: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
