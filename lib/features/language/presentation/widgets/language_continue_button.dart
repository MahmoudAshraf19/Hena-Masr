import 'package:flutter/material.dart';

import 'package:hena_masr/core/theme/app_colors.dart';
import 'package:hena_masr/core/theme/app_typography.dart';
import 'package:hena_masr/features/language/domain/models/language_item.dart';
import 'package:hena_masr/l10n/generated/app_localizations.dart';

/// Primary action button to confirm language selection and proceed.
class LanguageContinueButton extends StatelessWidget {
  const LanguageContinueButton({
    super.key,
    required this.selected,
    required this.isSubmitting,
    required this.onPressed,
    required this.bottomInset,
  });

  final LanguageItem selected;
  final bool isSubmitting;
  final VoidCallback onPressed;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final l10n = lookupAppLocalizations(Locale(selected.code));
    final continueText = l10n.continueAction;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 6, 20, 16 + bottomInset),
      child: FilledButton(
        onPressed: isSubmitting ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.basalt,
          disabledBackgroundColor: AppColors.gold.withValues(alpha: 0.6),
          minimumSize: const Size.fromHeight(56),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: isSubmitting
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
                        continueText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: selected.code == 'ar'
                              ? AppTypography.arabicFontFamily
                              : AppTypography.latinFontFamily,
                          letterSpacing: selected.isRtl ? 0 : 0.2,
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
    );
  }
}

