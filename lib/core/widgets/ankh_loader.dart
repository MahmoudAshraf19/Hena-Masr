import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'package:hena_masr/core/theme/theme_context.dart';

/// Ankh loading indicator that spins around its vertical axis with 3D perspective.
///
/// Drawn with [CustomPaint] using the exact proportions and coordinates
/// of ancient Egyptian Key of Life (assets/icons/ankh.svg).
class AnkhLoader extends StatefulWidget {
  const AnkhLoader({
    super.key,
    this.size = 64,
    this.color,
    this.dotColor,
    this.duration = const Duration(milliseconds: 1800),
    this.semanticLabel,
    this.enableGlow = true,
  });

  /// Height of the ankh. Width follows the symbol's proportions.
  final double size;

  /// Ankh color. Default: Royal Egyptian 24K Gold.
  final Color? color;

  /// Center dot color. Default: Faience Turquoise (#00E5FF).
  final Color? dotColor;

  /// Time for one full turn.
  final Duration duration;

  /// Screen-reader label.
  final String? semanticLabel;

  /// Whether to add a soft gold aura/glow behind the ankh.
  final bool enableGlow;

  @override
  State<AnkhLoader> createState() => _AnkhLoaderState();
}

class _AnkhLoaderState extends State<AnkhLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);

  // Ease in/out: the ankh lingers face-on, then whips around.
  late final Animation<double> _turn =
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);

  @override
  void initState() {
    super.initState();
    _controller.repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect the system "reduce motion" setting.
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hena = context.hena;
    final color = widget.color ?? hena.gold;
    final dot = widget.dotColor ?? hena.turquoise;

    final ankh = SizedBox(
      width: widget.size * AnkhPainter.aspect,
      height: widget.size,
      child: CustomPaint(
        painter: AnkhPainter(
          color: color,
          dotColor: dot,
          enableGlow: widget.enableGlow,
        ),
      ),
    );

    return Semantics(
      label: widget.semanticLabel ?? 'Loading',
      child: ExcludeSemantics(
        child: Container(
          decoration: widget.enableGlow
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: const Color(0xFFFFD54F).withValues(alpha: 0.3),
                      blurRadius: 32,
                      spreadRadius: 6,
                    ),
                  ],
                )
              : null,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _turn,
              child: ankh,
              builder: (context, child) => Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0015) // perspective
                  ..rotateY(_turn.value * 2 * math.pi),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints the Egyptian Ankh (Key of Life) with metallic royal gold luster and deep contrast.
class AnkhPainter extends CustomPainter {
  const AnkhPainter({
    required this.color,
    this.dotColor,
    this.enableGlow = false,
  });

  final Color color;
  final Color? dotColor;
  final bool enableGlow;

  // Design box is 48 x 76 units (matching ankh.svg).
  static const double _w = 48;
  static const double _h = 76;
  static const double aspect = _w / _h;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / _w, size.height / _h);
    canvas
      ..translate((size.width - _w * scale) / 2, (size.height - _h * scale) / 2)
      ..scale(scale);

    const loopRect = Rect.fromCenter(center: Offset(24, 21), width: 28, height: 34);
    const stemStart = Offset(24, 38);
    const stemEnd = Offset(24, 71);
    const armsStart = Offset(8, 49);
    const armsEnd = Offset(40, 49);

    // 1. Dark Drop-Shadow outline pass (guarantees contrast on bright sand)
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.65)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;

    canvas.drawOval(loopRect.translate(0, 1.5), shadowPaint);
    canvas.drawLine(stemStart.translate(0, 1.5), stemEnd.translate(0, 1.5), shadowPaint);
    canvas.drawLine(armsStart.translate(0, 1.5), armsEnd.translate(0, 1.5), shadowPaint);

    // 2. Radiant Golden Aura Glow
    if (enableGlow) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;

      canvas.drawOval(loopRect, glowPaint);
      canvas.drawLine(stemStart, stemEnd, glowPaint);
      canvas.drawLine(armsStart, armsEnd, glowPaint);
    }

    // 3. Luxurious Metallic Royal Gold Gradient Stroke
    final metallicShader = ui.Gradient.linear(
      const Offset(16, 4),
      const Offset(32, 72),
      const [
        Color(0xFFFFFDE7), // Luminous pale gold highlight
        Color(0xFFFFE082), // Brilliant champagne gold
        Color(0xFFFFC107), // Royal Egyptian 24K gold
        Color(0xFFFF8F00), // Rich amber gold
        Color(0xFFC67D00), // Deep antique gold rim
      ],
      const [0.0, 0.25, 0.55, 0.82, 1.0],
    );

    final stroke = Paint()
      ..shader = metallicShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.5
      ..strokeCap = StrokeCap.round;

    canvas.drawOval(loopRect, stroke);
    canvas.drawLine(stemStart, stemEnd, stroke);
    canvas.drawLine(armsStart, armsEnd, stroke);

    // 4. Subtle Inner Specular Gleam along the top-left loop
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final gleamRect = Rect.fromCenter(center: const Offset(23.5, 20.5), width: 26, height: 32);
    canvas.drawArc(gleamRect, math.pi * 1.0, math.pi * 0.7, false, highlightPaint);

    // 5. Center Turquoise Gemstone (Scarab / Faience jewel) with bezel & gleam
    if (dotColor != null) {
      // Golden bezel collar
      final bezelPaint = Paint()..color = const Color(0xFF8C5C00);
      canvas.drawCircle(const Offset(24, 21), 6.5, bezelPaint);

      // Turquoise gemstone with gradient luster
      final jewelShader = ui.Gradient.radial(
        const Offset(23, 19.5),
        5.5,
        [
          const Color(0xFF84FFFF), // Luminous turquoise highlight
          dotColor!,               // Core turquoise
          const Color(0xFF00695C), // Deep teal rim
        ],
        const [0.0, 0.6, 1.0],
      );
      final dotPaint = Paint()..shader = jewelShader;
      canvas.drawCircle(const Offset(24, 21), 5.2, dotPaint);

      // Sparkling white specular gleam on the jewel
      final innerGleam = Paint()..color = Colors.white;
      canvas.drawCircle(const Offset(22.6, 19.3), 1.6, innerGleam);
    }
  }

  @override
  bool shouldRepaint(AnkhPainter old) =>
      old.color != color ||
      old.dotColor != dotColor ||
      old.enableGlow != enableGlow;
}

