import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hena_masr/core/theme/theme_context.dart';
import 'package:hena_masr/features/zones/domain/entities/zone.dart';
import 'package:hena_masr/features/zones/presentation/providers/zone_providers.dart';
import 'package:hena_masr/features/zones/presentation/widgets/zone_picker_sheet.dart';

/// Interactive Zone Pill displayed in the AppBar or Header.
/// Tapping it opens the ZonePickerSheet for manual or automatic selection.
class ZoneSelectorPill extends ConsumerWidget {
  const ZoneSelectorPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zoneAsync = ref.watch(currentZoneProvider);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final state = zoneAsync.value;
    final match = state?.match;

    String zoneName;
    if (state?.status == ZoneStatus.detecting && match == null) {
      zoneName = isArabic ? 'تحديد الموقع...' : 'Detecting...';
    } else if (state?.status == ZoneStatus.outsideEgypt) {
      zoneName = isArabic ? 'خارج مصر (اختر منطقة)' : 'Outside Egypt';
    } else if (match != null) {
      if (match.highlight != null) {
        zoneName = isArabic ? match.highlight!.nameAr : match.highlight!.nameEn;
      } else if (match.locality != null) {
        zoneName = isArabic ? match.locality!.nameAr : match.locality!.nameEn;
      } else if (match.district != null) {
        zoneName = isArabic ? match.district!.nameAr : match.district!.nameEn;
      } else {
        zoneName = isArabic ? match.governorate.nameAr : match.governorate.nameEn;
      }
    } else {
      zoneName = isArabic ? 'مصر' : 'Egypt';
    }

    final isManual = state?.source == ZoneSource.manual;
    final isDetecting = state?.status == ZoneStatus.detecting;
    final isHighlight = match?.highlight != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ZonePickerSheet.show(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isHighlight
                  ? context.hena.gold.withValues(alpha: 0.7)
                  : isManual
                      ? context.hena.gold.withValues(alpha: 0.5)
                      : context.hena.turquoise.withValues(alpha: 0.4),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isDetecting)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.hena.gold,
                  ),
                )
              else
                Icon(
                  isHighlight
                      ? Icons.star_rounded
                      : isManual
                          ? Icons.edit_location_alt_rounded
                          : Icons.location_on_rounded,
                  size: 16,
                  color: isHighlight || isManual
                      ? context.hena.gold
                      : context.hena.turquoiseText,
                ),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 130),
                child: Text(
                  zoneName,
                  style: context.text.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 3),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: context.colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
