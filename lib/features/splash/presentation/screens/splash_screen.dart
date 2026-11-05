import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hena_masr/core/constants/asset_paths.dart';
import 'package:hena_masr/core/widgets/ankh_loader.dart';
import 'package:hena_masr/features/splash/presentation/widgets/splash_loading_bar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.onInitialized,
    this.minimumDuration = const Duration(milliseconds: 2800),
  });

  /// Optional callback invoked when the splash loading completes.
  final VoidCallback? onInitialized;

  /// Minimum time the splash screen displays before transitioning.
  final Duration minimumDuration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Fullscreen immersive experience during splash
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _progressController = AnimationController(
      vsync: this,
      duration: widget.minimumDuration,
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutQuad,
    );

    _progressController.forward().then((_) {
      if (mounted) {
        // Restore system UI overlays
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

        if (widget.onInitialized != null) {
          widget.onInitialized!();
        }
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF17202A), // Basalt brand color
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full Screen Artwork Background
          Image.asset(
            AssetPaths.splashImage,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
          ),

          // 2. Subtle Dark Gradient Overlay at the bottom for high contrast
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 220,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),

          // 3. Loader & Animated Progress at Bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 36 + bottomPadding,
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Spinning Pharaonic Ankh with glow
                    const AnkhLoader(
                      size: 46,
                      color: Color(0xFFD4A24C),
                      dotColor: Color(0xFF2BA39B),
                      enableGlow: true,
                    ),
                    const SizedBox(height: 14),

                    // Sleek Golden Progress Capsule
                    SplashLoadingBar(
                      progress: _progressAnimation.value,
                      width: 170,
                      height: 4.0,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
