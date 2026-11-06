import 'package:flutter/material.dart';

import 'package:hena_masr/core/theme/app_colors.dart';
import 'package:hena_masr/core/theme/app_typography.dart';
import 'package:hena_masr/features/language/domain/models/language_item.dart';

class LanguageCard extends StatelessWidget {
  const LanguageCard({
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
                ? AppColors.gold.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.035),
            border: Border.all(
              color: selected
                  ? AppColors.gold.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.08),
              width: selected ? 1.4 : 1.0,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.18),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
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

