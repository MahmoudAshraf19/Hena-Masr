import 'package:flutter/material.dart';

import 'package:hena_masr/core/theme/app_colors.dart';
import 'package:hena_masr/core/theme/app_typography.dart';
import 'package:hena_masr/features/language/domain/models/language_item.dart';
import 'package:hena_masr/l10n/generated/app_localizations.dart';

/// Title + subtitle reflecting the currently hovered or selected language.
class LanguageHeader extends StatelessWidget {
  const LanguageHeader({super.key, required this.item});

  final LanguageItem item;

  @override
  Widget build(BuildContext context) {
    // Look up localized text directly from generated AppLocalizations
    final l10n = lookupAppLocalizations(Locale(item.code));
    final title = l10n.chooseLanguageTitle;
    final subtitle = l10n.chooseLanguageSubtitle;

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
                      title,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: family,
                        fontSize: 26,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        letterSpacing: item.isRtl ? 0 : -0.3,
                        color: AppColors.papyrus,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
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
}

