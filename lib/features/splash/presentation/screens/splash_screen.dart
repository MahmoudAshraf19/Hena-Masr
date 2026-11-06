import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hena_masr/core/constants/asset_paths.dart';
import 'package:hena_masr/core/widgets/ankh_loader.dart';
import 'package:hena_masr/features/splash/presentation/widgets/splash_loading_bar.dart';
import 'package:hena_masr/features/zones/presentation/providers/zone_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({
    super.key,
    this.onInitialized,
    this.minimumDuration = const Duration(milliseconds: 2800),
  });

  /// Optional callback invoked when the splash loading completes.
  final VoidCallback? onInitialized;

  /// Duration of the splash loading animation.
  final Duration minimumDuration;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    debugPrint('🏺 [HanaMasr Splash] Initializing (duration: ${widget.minimumDuration.inMilliseconds}ms)...');

    // Initiate user location detection and zone resolution in the background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('📍 [HanaMasr Splash] PostFrameCallback: Triggering location detection & zone warmup...');
      ref.read(currentZoneProvider.notifier).detect();
    });

    if (!kIsWeb) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }

    _progressController = AnimationController(
      vsync: this,
      duration: widget.minimumDuration,
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutQuad,
    );

    _progressController.forward().then((_) {
      debugPrint('🏺 [HanaMasr Splash] Animation complete.');
      if (mounted) {
        if (widget.onInitialized != null) {
          widget.onInitialized!();
        } else {
          // Keep a gentle ambient breathing animation if splash is the standalone active screen
          _progressController.repeat(reverse: true);
        }
      }
    });
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
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

          // 2. Cinematic Gradient Overlay at the bottom for high contrast against desert sand
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 250,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.40),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // 3. Loader & Animated Progress at Bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 38 + bottomPadding,
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Spinning Pharaonic Ankh with metallic luster, aura, and drop-shadow
                    const AnkhLoader(
                      size: 54,
                      color: Color(0xFFFFD700), // Royal Egyptian 24K Gold
                      dotColor: Color(0xFF00E5FF), // Radiant Faience Turquoise
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

