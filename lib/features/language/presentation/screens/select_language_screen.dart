import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hena_masr/core/constants/asset_paths.dart';
import 'package:hena_masr/core/localization/locale_controller.dart';
import 'package:hena_masr/core/localization/supported_locales.dart';

/// Data model representing a supported language option.
class LanguageItem {
  final String code;
  final String nativeName;
  final String englishName;
  final String flagAsset;
  final bool isRtl;

  const LanguageItem({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.flagAsset,
    this.isRtl = false,
  });
}

/// The 15 officially supported languages with UK English as default.
const List<LanguageItem> kLanguageItems = [
  LanguageItem(
    code: 'en',
    nativeName: 'English',
    englishName: 'English',
    flagAsset: AssetPaths.flagBritain,
  ),
  LanguageItem(
    code: 'ar',
    nativeName: 'العربية',
    englishName: 'Arabic',
    flagAsset: AssetPaths.flagEgypt,
    isRtl: true,
  ),
  LanguageItem(
    code: 'fr',
    nativeName: 'Français',
    englishName: 'French',
    flagAsset: AssetPaths.flagFrance,
  ),
  LanguageItem(
    code: 'de',
    nativeName: 'Deutsch',
    englishName: 'German',
    flagAsset: AssetPaths.flagGermany,
  ),
  LanguageItem(
    code: 'es',
    nativeName: 'Español',
    englishName: 'Spanish',
    flagAsset: AssetPaths.flagSpain,
  ),
  LanguageItem(
    code: 'it',
    nativeName: 'Italiano',
    englishName: 'Italian',
    flagAsset: AssetPaths.flagItaly,
  ),
  LanguageItem(
    code: 'ru',
    nativeName: 'Русский',
    englishName: 'Russian',
    flagAsset: AssetPaths.flagRussia,
  ),
  LanguageItem(
    code: 'zh',
    nativeName: '中文',
    englishName: 'Chinese',
    flagAsset: AssetPaths.flagChina,
  ),
  LanguageItem(
    code: 'ja',
    nativeName: '日本語',
    englishName: 'Japanese',
    flagAsset: AssetPaths.flagJapan,
  ),
  LanguageItem(
    code: 'pl',
    nativeName: 'Polski',
    englishName: 'Polish',
    flagAsset: AssetPaths.flagPoland,
  ),
  LanguageItem(
    code: 'nl',
    nativeName: 'Nederlands',
    englishName: 'Dutch',
    flagAsset: AssetPaths.flagNetherlands,
  ),
  LanguageItem(
    code: 'uk',
    nativeName: 'Українська',
    englishName: 'Ukrainian',
    flagAsset: AssetPaths.flagUkraine,
  ),
  LanguageItem(
    code: 'cs',
    nativeName: 'Čeština',
    englishName: 'Czech',
    flagAsset: AssetPaths.flagCzech,
  ),
  LanguageItem(
    code: 'tr',
    nativeName: 'Türkçe',
    englishName: 'Turkish',
    flagAsset: AssetPaths.flagTurkey,
  ),
  LanguageItem(
    code: 'sr',
    nativeName: 'Српски',
    englishName: 'Serbian',
    flagAsset: AssetPaths.flagSerbia,
  ),
];

class SelectLanguageScreen extends ConsumerStatefulWidget {
  const SelectLanguageScreen({
    super.key,
    this.onContinue,
  });

  final VoidCallback? onContinue;

  @override
  ConsumerState<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends ConsumerState<SelectLanguageScreen>
    with SingleTickerProviderStateMixin {
  late String _selectedCode;
  late final AnimationController _staggerController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Default selected language is English as requested
    _selectedCode = 'en';

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSelectLanguage(String code) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedCode = code;
    });
  }

  Future<void> _handleContinue() async {
    HapticFeedback.mediumImpact();
    // Persist chosen language in Riverpod LocaleController
    await ref.read(localeProvider.notifier).setLocale(Locale(_selectedCode));

    if (widget.onContinue != null) {
      widget.onContinue!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1520),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Photographic Artwork Background
          Image.asset(
            AssetPaths.selectLanguageBg,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
          ),

          // 2. Dual Gradient Overlays for High Legibility
          // Top subtle vignette
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 180,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.70),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Bottom deep vignette covering behind the continue button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 280,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF0B121C).withValues(alpha: 0.85),
                    const Color(0xFF080D15).withValues(alpha: 0.98),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // 3. Foreground Content with Scrollable List
          SafeArea(
            child: Column(
              children: [
                // Header (Logo, Headline, Subtitle, Divider)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Golden Pin & Pyramids Brand Logo
                      _buildHeaderLogo(),

                      const SizedBox(height: 14),

                      // Main Title: "Choose Your Language"
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                            color: Colors.white,
                          ),
                          children: [
                            TextSpan(text: 'Choose Your '),
                            TextSpan(
                              text: 'Language',
                              style: TextStyle(
                                color: Color(0xFFFFD700), // Royal 24K Gold
                                shadows: [
                                  Shadow(
                                    color: Color(0x66FFD700),
                                    blurRadius: 12,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Subtitle
                      const Text(
                        'Select your preferred language\nto explore Egypt your way.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.35,
                          fontWeight: FontWeight.w400,
                          color: Color(0xCCFFFFFF),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Pharaonic Eye of Horus Divider
                      _buildPharaonicDivider(),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                // 4. Scrollable List of 15 Languages with Staggered Entrance
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
                    itemCount: kLanguageItems.length,
                    itemBuilder: (context, index) {
                      final item = kLanguageItems[index];
                      final isSelected = item.code == _selectedCode;

                      // Staggered interval calculation
                      final start = (index * 0.04).clamp(0.0, 0.7);
                      final end = (start + 0.35).clamp(0.0, 1.0);
                      final animation = CurvedAnimation(
                        parent: _staggerController,
                        curve: Interval(start, end, curve: Curves.easeOutCubic),
                      );

                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: animation.value,
                            child: Transform.translate(
                              offset: Offset(0, 32 * (1.0 - animation.value)),
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildLanguageCard(item, isSelected),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 5. Floating Bottom "Continue" Button
          Positioned(
            left: 24,
            right: 24,
            bottom: 22,
            child: SafeArea(
              top: false,
              child: _buildContinueButton(),
            ),
          ),
        ],
      ),
    );
  }

  /// Golden Logo Header matching the design mockup
  Widget _buildHeaderLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pin & Pyramid Badge
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFDF70),
                Color(0xFFD4AF37),
                Color(0xFFB8860B),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.location_on_rounded,
              size: 30,
              color: Color(0xFF131D2A),
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Hena Masr',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: Colors.white,
          ),
        ),
        const Text(
          'Explore Egypt .. Your Way!',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: Color(0xFFFFD700),
          ),
        ),
      ],
    );
  }

  /// Pharaonic Eye of Horus / Ornamental Gold Divider
  Widget _buildPharaonicDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFFFFD700).withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFD700),
                ),
              ),
              const SizedBox(width: 5),
              // Golden ornamental icon
              const Icon(
                Icons.visibility_outlined,
                size: 15,
                color: Color(0xFFFFD700),
              ),
              const SizedBox(width: 5),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFD700),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFD700).withValues(alpha: 0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Individual Language Card with Animated Border and Radio Button
  Widget _buildLanguageCard(LanguageItem item, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF131D2B).withValues(alpha: 0.85)
            : const Color(0xFF0F1824).withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? const Color(0xFFFFD700)
              : Colors.white.withValues(alpha: 0.16),
          width: isSelected ? 1.8 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onSelectLanguage(item.code),
          borderRadius: BorderRadius.circular(16),
          splashColor: const Color(0xFFFFD700).withValues(alpha: 0.15),
          highlightColor: const Color(0xFFFFD700).withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // 1. Flag Thumbnail
                Container(
                  width: 44,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFFD700).withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    item.flagAsset,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(width: 16),

                // 2. Language Name & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.nativeName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.92),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.englishName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: isSelected
                              ? const Color(0xFFFFD700).withValues(alpha: 0.85)
                              : Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Selection Radio Icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? const Color(0xFFFFD700) : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFFD700)
                          : Colors.white.withValues(alpha: 0.38),
                      width: isSelected ? 2.0 : 1.6,
                    ),
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Color(0xFF101924),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Bottom "Continue" Gradient Button
  Widget _buildContinueButton() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFFFE07A),
            Color(0xFFFFD700),
            Color(0xFFE5A93C),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.40),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleContinue,
          borderRadius: BorderRadius.circular(28),
          splashColor: Colors.white.withValues(alpha: 0.25),
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Color(0xFF101924),
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: Color(0xFF101924),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
