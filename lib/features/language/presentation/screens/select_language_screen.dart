import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hena_masr/core/theme/app_colors.dart';
import 'package:hena_masr/features/language/domain/models/language_item.dart';
import 'package:hena_masr/features/language/presentation/controllers/language_selection_controller.dart';
import 'package:hena_masr/features/language/presentation/widgets/language_card.dart';
import 'package:hena_masr/features/language/presentation/widgets/language_continue_button.dart';
import 'package:hena_masr/features/language/presentation/widgets/language_header.dart';
import 'package:hena_masr/features/language/presentation/widgets/language_hero_background.dart';
import 'package:hena_masr/features/language/presentation/widgets/language_ornament.dart';

/// Language selection screen appearing after the splash screen.
/// Follows Clean Architecture with dedicated domain models, repository, controller, and widgets.
class SelectLanguageScreen extends ConsumerStatefulWidget {
  const SelectLanguageScreen({super.key, this.onContinue});

  final VoidCallback? onContinue;

  @override
  ConsumerState<SelectLanguageScreen> createState() =>
      _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends ConsumerState<SelectLanguageScreen>
    with SingleTickerProviderStateMixin {
  static const _sheetRadius = 32.0;

  bool _started = false;
  late final AnimationController _enterController;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    if (MediaQuery.disableAnimationsOf(context)) {
      _enterController.value = 1.0;
    } else {
      _enterController.forward();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _revealSelected());
  }

  @override
  void dispose() {
    _enterController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _revealSelected() {
    final state = ref.read(languageSelectionControllerProvider);
    final index = state.supportedLanguages
        .indexWhere((e) => e.code == state.selectedLanguage.code);
    if (index < 4) return;
    final ctx = _itemKeys[state.selectedLanguage.code]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.3,
      duration: Duration.zero,
    );
  }

  void _onSelect(LanguageItem item) {
    HapticFeedback.selectionClick();
    ref.read(languageSelectionControllerProvider.notifier).selectLanguage(item);
  }

  Future<void> _handleContinue() async {
    HapticFeedback.lightImpact();
    await ref
        .read(languageSelectionControllerProvider.notifier)
        .confirmSelection(onSuccess: widget.onContinue);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final state = ref.watch(languageSelectionControllerProvider);
    final selected = state.selectedLanguage;
    final languages = state.supportedLanguages;

    for (final lang in languages) {
      _itemKeys.putIfAbsent(lang.code, () => GlobalKey());
    }

    final sheetH = (size.height * 0.64).clamp(420.0, 600.0);

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
            // 1. Full-screen background artwork matching splash framing
            const Positioned.fill(
              child: LanguageHeroBackground(),
            ),

            // 2. Language selection sheet sliding up smoothly from the bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: sheetH,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _enterController,
                    curve: const Interval(0.05, 0.95, curve: Curves.easeOutCubic),
                  ),
                ),
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _enterController,
                    curve: const Interval(0.05, 0.45, curve: Curves.easeOut),
                  ),
                  child: _buildSheet(selected, languages, state.isSubmitting, bottomInset),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheet(
    LanguageItem selected,
    List<LanguageItem> languages,
    bool isSubmitting,
    double bottomInset,
  ) {
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
          const LanguageOrnament(),
          const SizedBox(height: 14),
          LanguageHeader(item: selected),
          const SizedBox(height: 6),
          Expanded(child: _buildList(languages, selected)),
          LanguageContinueButton(
            selected: selected,
            isSubmitting: isSubmitting,
            onPressed: _handleContinue,
            bottomInset: bottomInset,
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<LanguageItem> languages, LanguageItem selected) {
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
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
        child: Column(
          children: [
            for (final lang in languages)
              Padding(
                key: _itemKeys[lang.code],
                padding: const EdgeInsets.only(bottom: 8),
                child: LanguageCard(
                  item: lang,
                  selected: lang.code == selected.code,
                  onTap: () => _onSelect(lang),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
