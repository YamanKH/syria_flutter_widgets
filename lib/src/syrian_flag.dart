import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Rectangular Syrian flag (green-white-black with three red stars) built with CustomPainter.
class SyrianFlag extends StatelessWidget {
  const SyrianFlag({
    super.key,
    this.width = 240,
    this.height = 140,
    this.borderRadius = 16,
    this.elevation = 8,
    this.shadowColor = const Color(0x55000000),
    this.waveAmplitude = 0,
    this.waveFrequency = 1.5,
    this.wavePhase = 0,
  });

  final double width;
  final double height;
  final double borderRadius;
  final double elevation;
  final Color shadowColor;
  final double waveAmplitude; // Fraction of height.
  final double waveFrequency; // Number of waves across the width.
  final double wavePhase;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final hasWave = waveAmplitude.abs() > 0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: elevation * 1.5,
            offset: Offset(0, elevation * 0.4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: CustomPaint(
          size: Size(width, height),
          painter: _SyrianFlagPainter(
            wavePhase: wavePhase,
            waveAmplitude: waveAmplitude,
            waveFrequency: waveFrequency,
          ),
          isComplex: hasWave,
          willChange: hasWave,
        ),
      ),
    );
  }
}

/// Circular badge version of the Syrian flag.
class SyrianFlagBadge extends StatelessWidget {
  const SyrianFlagBadge({
    super.key,
    this.diameter = 140,
    this.elevation = 6,
    this.shadowColor = const Color(0x55000000),
    this.waveAmplitude = 0,
    this.waveFrequency = 1.5,
    this.wavePhase = 0,
  });

  final double diameter;
  final double elevation;
  final Color shadowColor;
  final double waveAmplitude;
  final double waveFrequency;
  final double wavePhase;

  @override
  Widget build(BuildContext context) {
    final hasWave = waveAmplitude.abs() > 0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: elevation * 1.5,
            offset: Offset(0, elevation * 0.4),
          ),
        ],
      ),
      child: ClipOval(
        child: CustomPaint(
          size: Size(diameter, diameter),
          painter: _SyrianFlagCirclePainter(
            wavePhase: wavePhase,
            waveAmplitude: waveAmplitude,
            waveFrequency: waveFrequency,
          ),
          isComplex: hasWave,
          willChange: hasWave,
        ),
      ),
    );
  }
}

class _SyrianFlagPainter extends CustomPainter {
  const _SyrianFlagPainter({
    this.wavePhase = 0,
    this.waveAmplitude = 0,
    this.waveFrequency = 1.5,
  });

  final double wavePhase;
  final double waveAmplitude;
  final double waveFrequency;

  bool get _hasWave => waveAmplitude.abs() > 1e-4;

  @override
  void paint(Canvas canvas, Size size) {
    final stripeHeight = size.height / 3;
    const green = Color(0xFF007A3D);
    const red = Color(0xFFCE1126);
    const black = Colors.black;
    final greenPaint = Paint()..color = green;
    final whitePaint = Paint()..color = Colors.white;
    final blackPaint = Paint()..color = black;
    final redPaint = Paint()..color = red;

    if (_hasWave) {
      _drawWavyStripe(
        canvas: canvas,
        size: size,
        topBase: 0,
        bottomBase: stripeHeight,
        paint: greenPaint,
      );
      _drawWavyStripe(
        canvas: canvas,
        size: size,
        topBase: stripeHeight,
        bottomBase: stripeHeight * 2,
        paint: whitePaint,
      );
      _drawWavyStripe(
        canvas: canvas,
        size: size,
        topBase: stripeHeight * 2,
        bottomBase: stripeHeight * 3,
        paint: blackPaint,
      );
    } else {
      // Stripes: green, white, black.
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, stripeHeight), greenPaint);
      canvas.drawRect(
        Rect.fromLTWH(0, stripeHeight, size.width, stripeHeight),
        whitePaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(0, stripeHeight * 2, size.width, stripeHeight),
        blackPaint,
      );
    }

    // Three red stars centered in the white band.
    final starPaint = redPaint;
    final starRadius = stripeHeight * 0.25;
    final baseStarY = stripeHeight * 1.5;
    final starY = _hasWave ? _waveY(size.width * 0.5, baseStarY, size) : baseStarY;
    final leftStar = Offset(size.width * 0.28, starY);
    final middleStar = Offset(size.width * 0.5, starY);
    final rightStar = Offset(size.width * 0.72, starY);

    _drawStar(canvas, _withWave(leftStar, size), starRadius, starPaint);
    _drawStar(canvas, _withWave(middleStar, size), starRadius, starPaint);
    _drawStar(canvas, _withWave(rightStar, size), starRadius, starPaint);
  }

  Offset _withWave(Offset offset, Size size) {
    if (!_hasWave) return offset;
    return Offset(offset.dx, _waveY(offset.dx, offset.dy, size));
  }

  void _drawWavyStripe({
    required Canvas canvas,
    required Size size,
    required double topBase,
    required double bottomBase,
    required Paint paint,
  }) {
    final path = Path();
    final step = size.width / 40;

    path.moveTo(0, _waveY(0, topBase, size));
    for (double x = step; x <= size.width; x += step) {
      path.lineTo(x, _waveY(x, topBase, size));
    }

    path.lineTo(size.width, _waveY(size.width, bottomBase, size));
    for (double x = size.width - step; x >= 0; x -= step) {
      path.lineTo(x, _waveY(x, bottomBase, size));
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  double _waveY(double x, double baseY, Size size) {
    // Softer, layered wave: primary + a light harmonic for natural motion.
    final relativeY = (baseY / size.height).clamp(0.0, 1.0);
    final falloff = 0.55 + 0.45 * (1 - (relativeY - 0.5).abs() * 2); // less motion at edges.
    final amplitudePx = size.height * waveAmplitude * falloff;
    final basePhase = (x / size.width * waveFrequency * 2 * math.pi) + wavePhase;
    final primary = math.sin(basePhase);
    final harmonic = 0.35 * math.sin(basePhase * 1.7 + math.pi / 3);
    final wave = (primary + harmonic) * 0.7;
    return baseY + wave * amplitudePx;
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    const points = 5;
    final path = Path();
    for (int i = 0; i <= points * 2; i++) {
      final isEven = i.isEven;
      final r = isEven ? radius : radius * 0.45;
      final angle = (i * 36 - 90) * (math.pi / 180);
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SyrianFlagPainter oldDelegate) {
    return wavePhase != oldDelegate.wavePhase ||
        waveAmplitude != oldDelegate.waveAmplitude ||
        waveFrequency != oldDelegate.waveFrequency;
  }
}

class _SyrianFlagCirclePainter extends _SyrianFlagPainter {
  const _SyrianFlagCirclePainter({
    super.wavePhase,
    super.waveAmplitude,
    super.waveFrequency,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final clipPath = Path()..addOval(Rect.fromCircle(center: Offset(radius, radius), radius: radius));
    canvas.save();
    canvas.clipPath(clipPath);
    super.paint(canvas, size);
    canvas.restore();
  }
}


/// Animated waving version of the rectangular flag with shadow and rounded edges.
class AnimatedSyrianFlag extends StatefulWidget {
  const AnimatedSyrianFlag({
    super.key,
    this.width = 240,
    this.height = 140,
    this.borderRadius = 16,
    this.elevation = 8,
    this.shadowColor = const Color(0x55000000),
    this.waveAmplitude = 0.02,
    this.waveFrequency = 1.2,
    this.duration = const Duration(seconds: 4),
  });

  final double width;
  final double height;
  final double borderRadius;
  final double elevation;
  final Color shadowColor;
  final double waveAmplitude;
  final double waveFrequency;
  final Duration duration;

  @override
  State<AnimatedSyrianFlag> createState() => _AnimatedSyrianFlagState();
}

class _AnimatedSyrianFlagState extends State<AnimatedSyrianFlag> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)..repeat();
  }

  @override
  void didUpdateWidget(covariant AnimatedSyrianFlag oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller
        ..duration = widget.duration
        ..reset()
        ..repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final phase = _controller.value * 2 * math.pi;
        return SyrianFlag(
          width: widget.width,
          height: widget.height,
          borderRadius: widget.borderRadius,
          elevation: widget.elevation,
          shadowColor: widget.shadowColor,
          waveAmplitude: widget.waveAmplitude,
          waveFrequency: widget.waveFrequency,
          wavePhase: phase,
        );
      },
    );
  }
}
