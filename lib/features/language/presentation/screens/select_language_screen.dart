import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hena_masr/core/constants/asset_paths.dart';
import 'package:hena_masr/core/localization/locale_controller.dart';
import 'package:hena_masr/core/localization/supported_locales.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  DATA
// ─────────────────────────────────────────────────────────────────────────────

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

/// Screen copy that morphs live to the language being previewed/selected.
class _LangCopy {
  final String title;
  final String subtitle;
  final String cont;
  const _LangCopy(this.title, this.subtitle, this.cont);
}

const Map<String, _LangCopy> _kCopy = {
  'en': _LangCopy(
    'Choose your language',
    'Select your preferred language to explore Egypt your way.',
    'Continue',
  ),
  'ar': _LangCopy(
    'اختر لغتك',
    'اختر لغتك المفضلة لتستكشف مصر بطريقتك الخاصة.',
    'متابعة',
  ),
  'fr': _LangCopy(
    'Choisissez votre langue',
    'Sélectionnez votre langue préférée pour explorer l’Égypte à votre façon.',
    'Continuer',
  ),
  'de': _LangCopy(
    'Wähle deine Sprache',
    'Wähle deine bevorzugte Sprache, um Ägypten auf deine Art zu entdecken.',
    'Weiter',
  ),
  'es': _LangCopy(
    'Elige tu idioma',
    'Selecciona tu idioma preferido para explorar Egipto a tu manera.',
    'Continuar',
  ),
  'it': _LangCopy(
    'Scegli la tua lingua',
    'Seleziona la lingua che preferisci per esplorare l’Egitto a modo tuo.',
    'Continua',
  ),
  'ru': _LangCopy(
    'Выберите язык',
    'Выберите предпочтительный язык, чтобы открыть Египет по-своему.',
    'Продолжить',
  ),
  'zh': _LangCopy(
    '选择您的语言',
    '选择您偏好的语言,以您自己的方式探索埃及。',
    '继续',
  ),
  'ja': _LangCopy(
    '言語を選択',
    'お好みの言語を選んで、あなたらしくエジプトを探索しましょう。',
    '続ける',
  ),
  'pl': _LangCopy(
    'Wybierz swój język',
    'Wybierz preferowany język, aby odkrywać Egipt po swojemu.',
    'Kontynuuj',
  ),
  'nl': _LangCopy(
    'Kies je taal',
    'Kies je voorkeurstaal om Egypte op jouw manier te ontdekken.',
    'Doorgaan',
  ),
  'uk': _LangCopy(
    'Оберіть мову',
    'Оберіть бажану мову, щоб відкрити Єгипет по-своєму.',
    'Продовжити',
  ),
  'cs': _LangCopy(
    'Vyberte jazyk',
    'Vyberte preferovaný jazyk a objevte Egypt po svém.',
    'Pokračovat',
  ),
  'tr': _LangCopy(
    'Dilinizi seçin',
    'Mısır’ı kendi tarzınızda keşfetmek için tercih ettiğiniz dili seçin.',
    'Devam',
  ),
  'sr': _LangCopy(
    'Изаберите језик',
    'Изаберите жељени језик да истражите Египат на свој начин.',
    'Настави',
  ),
};

LanguageItem _itemOf(String code) => kLanguageItems.firstWhere(
      (e) => e.code == code,
      orElse: () => kLanguageItems.first,
    );

// ─────────────────────────────────────────────────────────────────────────────
//  PALETTE
// ─────────────────────────────────────────────────────────────────────────────

class _P {
  static const bg = Color(0xFF080D14);
  static const gold = Color(0xFFE9C46A);
  static const goldLight = Color(0xFFF7DE98);
  static const goldDeep = Color(0xFFC9973A);
  static const ink = Color(0xFF17120A);
}

// ─────────────────────────────────────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class SelectLanguageScreen extends ConsumerStatefulWidget {
  const SelectLanguageScreen({
    super.key,
    this.onContinue,
  });

  final VoidCallback? onContinue;

  @override
  ConsumerState<SelectLanguageScreen> createState() =>
      _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends ConsumerState<SelectLanguageScreen>
    with TickerProviderStateMixin {
  late String _selectedCode;

  /// Language used for the headline. Cycles automatically until the user
  /// interacts, then follows the selection.
  String _headlineCode = 'en';
  bool _userInteracted = false;
  bool _busy = false;

  late final AnimationController _enter; // one-shot entrance choreography
  late final AnimationController _ambient; // slow background motion
  late final AnimationController _shine; // button light sweep
  final ScrollController _scroll = ScrollController();

  Timer? _ticker;
  int _tickIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedCode = 'en';

    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat(reverse: true);

    _shine = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    // Headline "greets" the visitor in every language until they choose.
    _ticker = Timer.periodic(const Duration(milliseconds: 2800), (_) {
      if (!mounted || _userInteracted) return;
      _tickIndex = (_tickIndex + 1) % kLanguageItems.length;
      setState(() => _headlineCode = kLanguageItems[_tickIndex].code);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _enter.dispose();
    _ambient.dispose();
    _shine.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onSelectLanguage(String code) {
    if (code == _selectedCode && _userInteracted) return;
    HapticFeedback.selectionClick();
    setState(() {
      _userInteracted = true;
      _selectedCode = code;
      _headlineCode = code;
    });
  }

  Future<void> _handleContinue() async {
    if (_busy) return;
    HapticFeedback.mediumImpact();
    setState(() => _busy = true);
    try {
      await ref.read(localeProvider.notifier).setLocale(Locale(_selectedCode));
      widget.onContinue?.call();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ───────────────────────────── helpers ─────────────────────────────

  /// Fade + slide-up reveal driven by the entrance controller.
  Widget _reveal({
    required double begin,
    required double end,
    required Widget child,
    double dy = 24,
    double scaleFrom = 1.0,
  }) {
    final anim = _enter.drive(
      CurveTween(curve: Interval(begin, end, curve: Curves.easeOutCubic)),
    );
    return AnimatedBuilder(
      animation: anim,
      child: child,
      builder: (context, c) {
        final v = anim.value;
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, dy * (1 - v)),
            child: Transform.scale(
              scale: scaleFrom + (1 - scaleFrom) * v,
              child: c,
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────────── build ─────────────────────────────

  @override
  Widget build(BuildContext context) {
    final selected = _itemOf(_selectedCode);
    final headline = _itemOf(_headlineCode);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _P.bg,
        body: Stack(
          fit: StackFit.expand,
          children: [
            _buildBackground(),
            SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _reveal(
                          begin: 0.0,
                          end: 0.4,
                          child: _buildTopBar(),
                        ),
                        const SizedBox(height: 26),
                        _reveal(
                          begin: 0.08,
                          end: 0.55,
                          dy: 30,
                          child: _buildHeadline(headline),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _buildGrid(bottomInset)),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 14 + bottomInset,
              child: _reveal(
                begin: 0.45,
                end: 1.0,
                dy: 70,
                child: _buildDock(selected),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────── background ─────────────────────────────

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: Listenable.merge([_ambient, _scroll]),
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_ambient.value);
        final scrollY = _scroll.hasClients
            ? _scroll.offset.clamp(0.0, 400.0).toDouble()
            : 0.0;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Slow Ken-Burns drift + scroll parallax on the artwork.
            Transform.translate(
              offset: Offset(-16 * t, -scrollY * 0.06),
              child: Transform.scale(
                scale: 1.12 + 0.06 * t,
                child: Image.asset(
                  AssetPaths.selectLanguageBg,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),

            // Depth gradient: keeps the photo visible at the top, deep at the bottom.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _P.bg.withValues(alpha: 0.62),
                    _P.bg.withValues(alpha: 0.78),
                    _P.bg.withValues(alpha: 0.96),
                  ],
                  stops: const [0.0, 0.42, 1.0],
                ),
              ),
            ),

            // Drifting golden aurora.
            Align(
              alignment: Alignment(0.9 - 1.8 * t, -1.05),
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _P.gold.withValues(alpha: 0.20),
                      _P.gold.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ───────────────────────────── header ─────────────────────────────

  Widget _buildTopBar() {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_P.goldLight, _P.gold, _P.goldDeep],
            ),
          ),
          child: const Icon(
            Icons.location_on_rounded,
            size: 21,
            color: _P.ink,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'HENA MASR',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.6,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Explore Egypt · Your Way',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.6,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language_rounded, size: 15, color: _P.gold),
              const SizedBox(width: 6),
              Text(
                '${kLanguageItems.length}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Headline that morphs into the language currently being previewed.
  Widget _buildHeadline(LanguageItem item) {
    final copy = _kCopy[item.code] ?? _kCopy['en']!;

    return SizedBox(
      height: 168,
      width: double.infinity,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 650),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, anim) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.12),
            end: Offset.zero,
          ).animate(anim);
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(position: slide, child: child),
          );
        },
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.topLeft,
          children: [...previous, if (current != null) current],
        ),
        child: SizedBox(
          key: ValueKey(item.code),
          width: double.infinity,
          child: Directionality(
            textDirection: item.isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: const LinearGradient(
                      colors: [_P.goldLight, _P.goldDeep],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  copy.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 31,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    // Letter-spacing breaks Arabic letter joining → keep 0.
                    letterSpacing: item.isRtl ? 0 : -0.6,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  copy.subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.68),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────────── grid ─────────────────────────────

  Widget _buildGrid(double bottomInset) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Colors.black],
        stops: [0.0, 0.035],
      ).createShader(rect),
      child: GridView.builder(
        controller: _scroll,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, 10, 20, 132 + bottomInset),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: 116,
        ),
        itemCount: kLanguageItems.length,
        itemBuilder: (context, index) {
          final item = kLanguageItems[index];
          final row = index ~/ 2;
          final col = index % 2;
          final begin = (0.14 + row * 0.07 + col * 0.03).clamp(0.0, 0.62);
          final end = (begin + 0.36).clamp(0.0, 1.0);

          return _reveal(
            begin: begin,
            end: end,
            dy: 40,
            scaleFrom: 0.9,
            child: _LanguageTile(
              item: item,
              selected: item.code == _selectedCode,
              onTap: () => _onSelectLanguage(item.code),
            ),
          );
        },
      ),
    );
  }

  // ───────────────────────────── dock ─────────────────────────────

  Widget _buildDock(LanguageItem selected) {
    final copy = _kCopy[selected.code] ?? _kCopy['en']!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF101823).withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              // Current selection summary
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 380),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.85, end: 1).animate(anim),
                      child: child,
                    ),
                  ),
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.centerLeft,
                    children: [...previous, if (current != null) current],
                  ),
                  child: Row(
                    key: ValueKey(selected.code),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _FlagCircle(
                        item: selected,
                        size: 46,
                        ring: true,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selected.nativeName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              selected.englishName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _buildContinueButton(copy.cont, selected.isRtl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(String label, bool rtl) {
    return _PressScale(
      onTap: _handleContinue,
      pressedScale: 0.95,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_P.goldLight, _P.gold, _P.goldDeep],
          ),
          boxShadow: [
            BoxShadow(
              color: _P.gold.withValues(alpha: 0.38),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Light sweep
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _shine,
                    builder: (context, _) {
                      final p = (_shine.value / 0.5).clamp(0.0, 1.0);
                      final slide = -1.0 + 2.0 * Curves.easeInOut.transform(p);
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.38),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                            stops: const [0.35, 0.5, 0.65],
                            transform: _SlideGradient(slide),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: _busy
                    ? const SizedBox(
                        key: ValueKey('busy'),
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.6,
                          valueColor: AlwaysStoppedAnimation(_P.ink),
                        ),
                      )
                    : Row(
                        key: ValueKey(label),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: rtl ? 0 : 0.3,
                              color: _P.ink,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            rtl
                                ? Icons.arrow_back_rounded
                                : Icons.arrow_forward_rounded,
                            size: 20,
                            color: _P.ink,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  LANGUAGE TILE
// ─────────────────────────────────────────────────────────────────────────────

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final LanguageItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: selected
                ? [
                    _P.gold.withValues(alpha: 0.22),
                    _P.gold.withValues(alpha: 0.06),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.075),
                    Colors.white.withValues(alpha: 0.03),
                  ],
          ),
          border: Border.all(
            color: selected
                ? _P.gold.withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.10),
            width: selected ? 1.4 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _P.gold.withValues(alpha: selected ? 0.22 : 0.0),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Directionality(
          textDirection: item.isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _FlagCircle(item: item, size: 40, ring: selected),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.nativeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 12,
                          color: selected
                              ? _P.gold
                              : Colors.white.withValues(alpha: 0.5),
                        ),
                        child: Text(item.englishName),
                      ),
                    ],
                  ),
                ],
              ),
              PositionedDirectional(
                top: 0,
                end: 0,
                child: _CheckBadge(selected: selected),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckBadge extends StatelessWidget {
  const _CheckBadge({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? _P.gold : Colors.transparent,
        border: Border.all(
          color: selected ? _P.gold : Colors.white.withValues(alpha: 0.28),
          width: 1.5,
        ),
      ),
      child: AnimatedScale(
        scale: selected ? 1 : 0,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutBack,
        child: const Icon(Icons.check_rounded, size: 14, color: _P.ink),
      ),
    );
  }
}

class _FlagCircle extends StatelessWidget {
  const _FlagCircle({
    required this.item,
    required this.size,
    required this.ring,
  });

  final LanguageItem item;
  final double size;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size + 6,
      height: size + 6,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: ring ? _P.gold : Colors.white.withValues(alpha: 0.14),
          width: ring ? 1.6 : 1.0,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          item.flagAsset,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.white.withValues(alpha: 0.1),
            alignment: Alignment.center,
            child: Text(
              item.code.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  UTILITIES
// ─────────────────────────────────────────────────────────────────────────────

/// Tactile press feedback (scale down on touch, spring back on release).
class _PressScale extends StatefulWidget {
  const _PressScale({
    required this.child,
    required this.onTap,
    this.pressedScale = 0.96,
  });

  final Widget child;
  final VoidCallback onTap;
  final double pressedScale;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _pressed = false;

  void _set(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: Duration(milliseconds: _pressed ? 110 : 280),
        curve: _pressed ? Curves.easeOut : Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}

/// Slides a gradient horizontally (used for the button light sweep).
class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.percent);
  final double percent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * percent, 0.0, 0.0);
  }
}
