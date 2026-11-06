import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'package:hena_masr/core/theme/theme_context.dart';

/// Royal Ankh loader: polished 24K gold body, lapis-lazuli outline,
/// turquoise jewel and a travelling light sweep, spinning in 3D.
class AnkhLoader extends StatefulWidget {
  const AnkhLoader({
    super.key,
    this.size = 64,
    this.color,
    this.dotColor,
    this.duration = const Duration(milliseconds: 2200),
    this.semanticLabel,
    this.enableGlow = true,
  });

  final double size;
  final Color? color;
  final Color? dotColor;
  final Duration duration;
  final String? semanticLabel;
  final bool enableGlow;

  @override
  State<AnkhLoader> createState() => _AnkhLoaderState();
}

class _AnkhLoaderState extends State<AnkhLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);

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

    final w = widget.size * AnkhPainter.aspect;
    final h = widget.size;

    final ankh = SizedBox(
      width: w,
      height: h,
      child: CustomPaint(
        painter: AnkhPainter(
          color: color,
          dotColor: dot,
          enableGlow: widget.enableGlow,
          shine: _controller, // light sweep driven by the same controller
        ),
      ),
    );

    return Semantics(
      label: widget.semanticLabel ?? 'Loading',
      child: ExcludeSemantics(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Static dark-warm halo behind the ankh: makes the gold pop
            // against the bright desert sand without washing it out.
            if (widget.enableGlow)
              Positioned(
                left: -w * 0.9,
                right: -w * 0.9,
                top: -h * 0.25,
                bottom: -h * 0.25,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.42),
                          const Color(0xFF5A2A00).withValues(alpha: 0.22),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _turn,
                child: ankh,
                builder: (context, child) => Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0015)
                    ..rotateY(_turn.value * 2 * math.pi),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints the Ankh (Key of Life) as an inlaid royal jewel.
class AnkhPainter extends CustomPainter {
  AnkhPainter({
    required this.color,
    this.dotColor,
    this.enableGlow = false,
    this.shine,
  }) : super(repaint: shine);

  final Color color;
  final Color? dotColor;
  final bool enableGlow;

  /// 0..1 animation used to move the specular light sweep.
  final Animation<double>? shine;

  static const double _w = 48;
  static const double _h = 76;
  static const double aspect = _w / _h;

  static const Color _lapis = Color(0xFF0A1F52); // deep lapis outline
  static const Color _lapisSoft = Color(0xFF14398F);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / _w, size.height / _h);
    canvas
      ..translate((size.width - _w * scale) / 2, (size.height - _h * scale) / 2)
      ..scale(scale);

    final ankh = Path()
      ..addOval(Rect.fromCenter(
          center: const Offset(24, 21), width: 28, height: 34))
      ..moveTo(24, 38)
      ..lineTo(24, 71)
      ..moveTo(8, 49)
      ..lineTo(40, 49);

    Paint strokePaint(double width) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 1. Soft drop shadow (lift off the background)
    canvas.drawPath(
      ankh.shift(const Offset(0, 2.2)),
      strokePaint(12.5)
        ..color = Colors.black.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.2),
    );

    // 2. Subtle warm gold aura (tight, not washed out)
    if (enableGlow) {
      canvas.drawPath(
        ankh,
        strokePaint(11)
          ..color = const Color(0xFFFFB300).withValues(alpha: 0.38)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    // 3. Lapis-lazuli outline: the contrast that makes it pop
    canvas.drawPath(
      ankh,
      strokePaint(12.5)
        ..shader = ui.Gradient.linear(
          const Offset(8, 0),
          const Offset(40, 76),
          const [_lapisSoft, _lapis, _lapis],
          const [0.0, 0.45, 1.0],
        ),
    );

    // 4. Bright champagne rim (bevel)
    canvas.drawPath(
      ankh,
      strokePaint(10)
        ..shader = ui.Gradient.linear(
          const Offset(8, 0),
          const Offset(40, 76),
          const [Color(0xFFFFF8D6), Color(0xFFFFE082), Color(0xFFE6A100)],
          const [0.0, 0.5, 1.0],
        ),
    );

    // 5. Polished metallic gold body (banded reflections like real gold)
    Color tone(Color to, double t) => Color.lerp(color, to, t)!;
    canvas.drawPath(
      ankh,
      strokePaint(7.6)
        ..shader = ui.Gradient.linear(
          const Offset(10, 2),
          const Offset(38, 74),
          [
            tone(Colors.white, 0.75), // glare
            tone(Colors.white, 0.30),
            color, // 24K
            tone(const Color(0xFF9A5B00), 0.60), // deep reflection band
            tone(Colors.white, 0.20),
            color,
            tone(const Color(0xFF7A4500), 0.65), // antique rim
          ],
          const [0.0, 0.16, 0.34, 0.50, 0.64, 0.82, 1.0],
        ),
    );

    // 6. Engraved centre groove (inlaid look)
    canvas.drawPath(
      ankh,
      strokePaint(1.3)..color = const Color(0xFF8A5200).withValues(alpha: 0.55),
    );

    // 7. Specular gleam on the loop
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(23.5, 20.5), width: 26.5, height: 32),
      math.pi * 1.02,
      math.pi * 0.62,
      false,
      strokePaint(1.7)..color = Colors.white.withValues(alpha: 0.8),
    );

    // 8. Travelling light sweep across the gold
    if (shine != null) {
      final t = shine!.value;
      final c = Offset(-14 + 76 * t, -14 + 104 * t);
      canvas.drawPath(
        ankh,
        strokePaint(7.6)
          ..shader = ui.Gradient.linear(
            c - const Offset(9, 9),
            c + const Offset(9, 9),
            [
              Colors.white.withValues(alpha: 0.0),
              Colors.white.withValues(alpha: 0.95),
              Colors.white.withValues(alpha: 0.0),
            ],
            const [0.0, 0.5, 1.0],
          ),
      );
    }

    // 9. Jewel in the loop: gold bezel + lapis ring + turquoise gem
    if (dotColor != null) {
      const centre = Offset(24, 21);

      canvas.drawCircle(
        centre,
        7.6,
        Paint()
          ..shader = ui.Gradient.linear(
            const Offset(17, 14),
            const Offset(31, 28),
            const [Color(0xFFFFF3B0), Color(0xFFFFC107), Color(0xFF9A5B00)],
            const [0.0, 0.5, 1.0],
          ),
      );
      canvas.drawCircle(centre, 6.4, Paint()..color = _lapis);

      canvas.drawCircle(
        centre,
        5.3,
        Paint()
          ..shader = ui.Gradient.radial(
            const Offset(22.8, 19.2),
            6,
            [
              const Color(0xFFB2FFFF),
              dotColor!,
              const Color(0xFF00695C),
            ],
            const [0.0, 0.55, 1.0],
          ),
      );

      canvas.drawCircle(
          const Offset(22.4, 19), 1.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(AnkhPainter old) =>
      old.color != color ||
      old.dotColor != dotColor ||
      old.enableGlow != enableGlow ||
      old.shine != shine;
}