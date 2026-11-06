import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hena_masr/core/theme/theme_context.dart';
import 'package:hena_masr/features/zones/presentation/providers/zone_providers.dart';
import 'package:hena_masr/features/zones/presentation/widgets/zone_picker_sheet.dart';

/// Appears conditionally when the GPS fix is near a border or has lower accuracy,
/// allowing the user to confirm or adjust their zone.
class ZoneConfirmationBanner extends ConsumerWidget {
  const ZoneConfirmationBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(currentZoneProvider).valueOrNull;
    if (state == null || !state.shouldConfirm) return const SizedBox.shrink();

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final match = state.match!;
    final name = isArabic
        ? (match.highlight?.nameAr ?? match.district?.nameAr ?? match.governorate.nameAr)
        : (match.highlight?.nameEn ?? match.district?.nameEn ?? match.governorate.nameEn);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.hena.carnelian.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.hena.carnelian.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: context.hena.carnelianText, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isArabic
                  ? 'هل أنت حالياً في $name؟'
                  : 'Are you currently in $name?',
              style: context.text.bodyMedium?.copyWith(
                color: context.hena.carnelianText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => ZonePickerSheet.show(context),
            child: Text(
              isArabic ? 'تأكيد / تغيير' : 'Confirm',
              style: TextStyle(color: context.hena.carnelianText, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
