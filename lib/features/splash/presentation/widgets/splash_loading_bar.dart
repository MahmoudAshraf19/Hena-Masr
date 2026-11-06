import 'package:flutter/material.dart';

class SplashLoadingBar extends StatelessWidget {
  const SplashLoadingBar({
    super.key,
    required this.progress,
    this.width = 180,
    this.height = 4.5,
  });

  /// Progress value between 0.0 and 1.0.
  final double progress;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(height),
      ),
      child: Stack(
        children: [
          // Filled Bar with Gold Gradient & Glow
          FractionallySizedBox(
            widthFactor: clamped,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFC107).withValues(alpha: 0.75),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFC67D00),
                    Color(0xFFFFC107),
                    Color(0xFFFFF59D),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

