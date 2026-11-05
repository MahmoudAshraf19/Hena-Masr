import 'dart:math' as math;
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

  /// Ankh color. Default: Egyptian Gold (#D4A24C).
  final Color? color;

  /// Center dot color. Default: Faience Turquoise (#2BA39B).
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
    );
  }
}

/// Paints the Egyptian Ankh (Key of Life).
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

    if (enableGlow) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round;

      // Glow Loop
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(24, 21), width: 28, height: 34),
        glowPaint,
      );
      // Glow Stem & Arms
      canvas.drawLine(const Offset(24, 38), const Offset(24, 71), glowPaint);
      canvas.drawLine(const Offset(8, 49), const Offset(40, 49), glowPaint);
    }

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    // Loop
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(24, 21), width: 28, height: 34),
      stroke,
    );
    // Stem
    canvas.drawLine(const Offset(24, 38), const Offset(24, 71), stroke);
    // Arms
    canvas.drawLine(const Offset(8, 49), const Offset(40, 49), stroke);

    // Inner turquoise jewel/dot
    if (dotColor != null) {
      final dotPaint = Paint()..color = dotColor!;
      canvas.drawCircle(const Offset(24, 21), 5, dotPaint);

      final innerGleam = Paint()..color = Colors.white.withValues(alpha: 0.7);
      canvas.drawCircle(const Offset(23, 19), 1.5, innerGleam);
    }
  }

  @override
  bool shouldRepaint(AnkhPainter old) =>
      old.color != color ||
      old.dotColor != dotColor ||
      old.enableGlow != enableGlow;
}
