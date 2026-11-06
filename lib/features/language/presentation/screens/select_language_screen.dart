import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hena_masr/core/constants/asset_paths.dart';
import 'package:hena_masr/core/localization/locale_controller.dart';
import 'package:hena_masr/core/theme/app_colors.dart';
import 'package:hena_masr/core/theme/app_typography.dart';


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

/// The 15 supported languages. Arabic first in list, English is default selected.
const List<LanguageItem> kLanguageItems = [
  LanguageItem(
    code: 'ar',
    nativeName: 'العربية',
    englishName: 'Arabic',
    flagAsset: AssetPaths.flagEgypt,
    isRtl: true,
  ),
  LanguageItem(
    code: 'en',
    nativeName: 'English',
    englishName: 'English',
    flagAsset: AssetPaths.flagBritain,
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

/// Screen copy that follows the language currently selected.
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
//  SCREEN
// ─────────────────────────────────────────────────────────────────────────────

/// First screen after the splash.
///
/// Layout: the Giza artwork on top, a calm basalt sheet below with the
/// language list. Motion is deliberately restrained: one slow entrance,
/// one very slow background drift, and soft state changes on selection.
class SelectLanguageScreen extends ConsumerStatefulWidget {
  const SelectLanguageScreen({super.key, this.onContinue});

  final VoidCallback? onContinue;

  @override
  ConsumerState<SelectLanguageScreen> createState() =>
      _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends ConsumerState<SelectLanguageScreen>
    with TickerProviderStateMixin {
  static const _sheetRadius = 32.0;

  late String _selectedCode;
  bool _busy = false;
  bool _started = false;

  late final AnimationController _enter; // one-shot entrance
  late final AnimationController _ambient; // very slow background drift
  final ScrollController _scroll = ScrollController();
  final Map<String, GlobalKey> _keys = {
    for (final l in kLanguageItems) l.code: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    // Default selected language is English
    _selectedCode = 'en';

    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 36),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    // Respect the system "reduce motion" setting.
    if (MediaQuery.disableAnimationsOf(context)) {
      _enter.value = 1;
    } else {
      _enter.forward();
      _ambient.repeat(reverse: true);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _revealSelected());
  }

  @override
  void dispose() {
    _enter.dispose();
    _ambient.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// If the preselected language is further down the list, bring it into view.
  void _revealSelected() {
    final index = kLanguageItems.indexWhere((e) => e.code == _selectedCode);
    if (index < 4) return;
    final ctx = _keys[_selectedCode]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.3,
      duration: Duration.zero,
    );
  }

  void _onSelect(String code) {
    if (code == _selectedCode) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedCode = code);
  }

  Future<void> _handleContinue() async {
    if (_busy) return;
    HapticFeedback.lightImpact();
    setState(() => _busy = true);
    try {
      await ref.read(localeProvider.notifier).setLocale(Locale(_selectedCode));
      widget.onContinue?.call();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ───────────────────────────── build ─────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final selected = _itemOf(_selectedCode);

    final sheetH = (size.height * 0.64).clamp(420.0, 600.0);
    final heroH = size.height - sheetH + _sheetRadius;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.basalt,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.basalt,
        body: Stack(
          children: [
            // Artwork
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: heroH,
              child: _buildHero(),
            ),

            // Sheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: sheetH,
              child: _Reveal(
                parent: _enter,
                begin: 0.20,
                end: 0.80,
                dy: 28,
                child: _buildSheet(selected, bottomInset),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────── hero ─────────────────────────────

  Widget _buildHero() {
    return ClipRect(
      child: AnimatedBuilder(
        animation: Listenable.merge([_enter, _ambient]),
        child: Image.asset(
          AssetPaths.selectLanguageBg,
          fit: BoxFit.cover,
          alignment: const Alignment(0, 0.6), // keeps the pyramids framed
          width: double.infinity,
          height: double.infinity,
        ),
        builder: (context, child) {
          final e = Curves.easeOutCubic.transform(_enter.value);
          final t = Curves.easeInOut.transform(_ambient.value);
          // Settles from 1.06 → 1.0 on entry, then drifts a few pixels.
          final scale = (1.0 + 0.06 * (1 - e)) * (1.05 + 0.02 * t);
          return Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: e,
                child: Transform.translate(
                  offset: Offset(-6 * t, 0),
                  child: Transform.scale(scale: scale, child: child),
                ),
              ),
              // Soft top shade for the brand mark & status bar.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.basalt.withValues(alpha: 0.55),
                      AppColors.basalt.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.40],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ───────────────────────────── sheet ─────────────────────────────

  Widget _buildSheet(LanguageItem selected, double bottomInset) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.basalt,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(_sheetRadius)),
        border: Border(
          top: BorderSide(color: AppColors.gold.withValues(alpha: 0.35)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 14),
          _Reveal(
            parent: _enter,
            begin: 0.35,
            end: 0.70,
            dy: 0,
            child: const _Ornament(),
          ),
          const SizedBox(height: 14),
          _Reveal(
            parent: _enter,
            begin: 0.35,
            end: 0.75,
            dy: 8,
            child: _buildHeader(selected),
          ),
          const SizedBox(height: 6),
          Expanded(child: _buildList()),
          _buildFooter(selected, bottomInset),
        ],
      ),
    );
  }

  /// Title + subtitle, following the selected language. Fixed height so the
  /// list never shifts when the text changes.
  Widget _buildHeader(LanguageItem item) {
    final copy = _kCopy[item.code] ?? _kCopy['en']!;
    final family = item.code == 'ar'
        ? AppTypography.arabicFontFamily
        : AppTypography.latinFontFamily;

    return SizedBox(
      height: 78,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.10),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.topCenter,
          children: [...previous, if (current != null) current],
        ),
        child: Padding(
          key: ValueKey(item.code),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: Directionality(
              textDirection: item.isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      copy.title,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: family,
                        fontSize: 26,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        // Letter-spacing breaks Arabic letter joining.
                        letterSpacing: item.isRtl ? 0 : -0.3,
                        color: AppColors.papyrus,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    copy.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: family,
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.mutedDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.black,
          Colors.black,
          Colors.transparent,
        ],
        stops: [0.0, 0.04, 0.94, 1.0],
      ).createShader(rect),
      child: SingleChildScrollView(
        controller: _scroll,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
        child: Column(
          children: [
            for (var i = 0; i < kLanguageItems.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _Reveal(
                  parent: _enter,
                  // Gentle stagger: ~25ms per row.
                  begin: (0.40 + i * 0.025).clamp(0.0, 0.75),
                  end: (0.40 + i * 0.025 + 0.30).clamp(0.0, 1.0),
                  dy: 10,
                  child: _LanguageRow(
                    key: _keys[kLanguageItems[i].code],
                    item: kLanguageItems[i],
                    selected: kLanguageItems[i].code == _selectedCode,
                    onTap: () => _onSelect(kLanguageItems[i].code),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(LanguageItem selected, double bottomInset) {
    final copy = _kCopy[selected.code] ?? _kCopy['en']!;
    final rtl = selected.isRtl;

    return _Reveal(
      parent: _enter,
      begin: 0.55,
      end: 1.0,
      dy: 12,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 6, 20, 16 + bottomInset),
        child: FilledButton(
          onPressed: _handleContinue,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.basalt,
            minimumSize: const Size.fromHeight(56),
            shape: const StadiumBorder(),
            elevation: 0,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _busy
                ? const SizedBox(
                    key: ValueKey('busy'),
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation(AppColors.basalt),
                    ),
                  )
                : Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      key: ValueKey(selected.code),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          copy.cont,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: selected.code == 'ar'
                                ? AppTypography.arabicFontFamily
                                : AppTypography.latinFontFamily,
                            letterSpacing: rtl ? 0 : 0.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PIECES
// ─────────────────────────────────────────────────────────────────────────────

/// Fade + small upward drift, driven by a window of the entrance controller.
class _Reveal extends StatelessWidget {
  const _Reveal({
    required this.parent,
    required this.begin,
    required this.end,
    required this.child,
    this.dy = 12,
  });

  final Animation<double> parent;
  final double begin;
  final double end;
  final double dy;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final anim = parent.drive(
      CurveTween(curve: Interval(begin, end, curve: Curves.easeOutCubic)),
    );
    return AnimatedBuilder(
      animation: anim,
      child: child,
      builder: (context, c) => Opacity(
        opacity: anim.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, dy * (1 - anim.value)),
          child: c,
        ),
      ),
    );
  }
}


/// Thin gold rule with a centred diamond — a quiet Egyptian-inspired accent.
class _Ornament extends StatelessWidget {
  const _Ornament();

  @override
  Widget build(BuildContext context) {
    final line = Container(
      width: 34,
      height: 1,
      color: AppColors.gold.withValues(alpha: 0.55),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        line,
        const SizedBox(width: 10),
        Transform.rotate(
          angle: math.pi / 4,
          child: Container(width: 6, height: 6, color: AppColors.gold),
        ),
        const SizedBox(width: 10),
        line,
      ],
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final LanguageItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: item.nativeName,
      child: _PressScale(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: selected
                ? AppColors.gold.withValues(alpha: 0.10)
                : Colors.white.withValues(alpha: 0.035),
            border: Border.all(
              color: selected
                  ? AppColors.gold.withValues(alpha: 0.70)
                  : Colors.white.withValues(alpha: 0.07),
              width: selected ? 1.3 : 1.0,
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                _Flag(asset: item.flagAsset, code: item.code),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.nativeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: item.code == 'ar'
                          ? AppTypography.arabicFontFamily
                          : AppTypography.latinFontFamily,
                      color: AppColors.papyrus,
                    ),
                  ),
                ),
                _RadioDot(selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Flag extends StatelessWidget {
  const _Flag({required this.asset, required this.code});

  final String asset;
  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: ClipOval(
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
          cacheWidth: 108,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.white.withValues(alpha: 0.08),
            alignment: Alignment.center,
            child: Text(
              code.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.gold : Colors.transparent,
        border: Border.all(
          color: selected
              ? AppColors.gold
              : Colors.white.withValues(alpha: 0.28),
          width: 1.5,
        ),
      ),
      child: AnimatedScale(
        scale: selected ? 1 : 0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: const Icon(
          Icons.check_rounded,
          size: 15,
          color: AppColors.basalt,
        ),
      ),
    );
  }
}

/// Soft press feedback (tiny scale down on touch).
class _PressScale extends StatefulWidget {
  const _PressScale({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

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
        scale: _pressed ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
