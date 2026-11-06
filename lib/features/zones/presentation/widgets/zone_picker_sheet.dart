import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hena_masr/core/theme/theme_context.dart';
import 'package:hena_masr/features/zones/domain/entities/zone.dart';
import 'package:hena_masr/features/zones/presentation/providers/zone_providers.dart';

/// Modal bottom sheet allowing the traveler to switch between automatic GPS
/// detection and manual selection across 42 tourist highlights, 403 districts,
/// and 27 governorates (Schema v2).
class ZonePickerSheet extends ConsumerStatefulWidget {
  const ZonePickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ZonePickerSheet(),
    );
  }

  @override
  ConsumerState<ZonePickerSheet> createState() => _ZonePickerSheetState();
}

class _ZonePickerSheetState extends ConsumerState<ZonePickerSheet> {
  String _searchQuery = '';
  int _selectedTab = 0; // 0 = Highlights (42), 1 = Districts (403), 2 = Governorates (27)

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(zoneCatalogProvider);
    final zoneState = ref.watch(currentZoneProvider).value;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.88,
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 16),

          // Sheet Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.near_me_rounded, color: context.hena.gold, size: 26),
                const SizedBox(width: 10),
                Text(
                  isArabic ? 'تحديد منطقتك في مصر' : 'Select Your Zone in Egypt',
                  style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(),

          // GPS Auto-detect card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Card(
              color: zoneState?.source == ZoneSource.gps
                  ? context.hena.heroSurface
                  : context.colors.surfaceContainerHighest.withValues(alpha: 0.45),
              child: ListTile(
                leading: Icon(
                  Icons.gps_fixed_rounded,
                  color: zoneState?.source == ZoneSource.gps
                      ? context.hena.onHeroSurface
                      : context.hena.gold,
                ),
                title: Text(
                  isArabic ? 'تحديد تلقائي عبر GPS' : 'Automatic GPS Detection',
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: zoneState?.source == ZoneSource.gps
                        ? context.hena.onHeroSurface
                        : null,
                  ),
                ),
                subtitle: Text(
                  zoneState?.status == ZoneStatus.detecting
                      ? (isArabic ? 'جاري تحديد موقعك...' : 'Locating your position...')
                      : (isArabic
                          ? 'استخدام إحداثيات الأقمار الصناعية لتحديث المنطقة'
                          : 'Use live satellite coordinates to track your zone'),
                  style: context.text.bodySmall?.copyWith(
                    color: zoneState?.source == ZoneSource.gps
                        ? context.hena.onHeroSurface.withValues(alpha: 0.8)
                        : null,
                  ),
                ),
                trailing: zoneState?.source == ZoneSource.gps
                    ? Icon(Icons.check_circle_rounded, color: context.hena.onHeroSurface)
                    : OutlinedButton(
                        onPressed: () {
                          ref.read(currentZoneProvider.notifier).useAutomatic();
                          Navigator.of(context).pop();
                        },
                        child: Text(isArabic ? 'تفعيل' : 'Activate'),
                      ),
                onTap: () {
                  ref.read(currentZoneProvider.notifier).useAutomatic();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: isArabic
                    ? 'ابحث عن وجهة، قسم، مركز، أو محافظة...'
                    : 'Search highlight, district, or governorate...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
            ),
          ),

          // 3-way Segmented Control
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(
                  value: 0,
                  label: Text(isArabic ? 'الوجهات (42)' : 'Destinations (42)'),
                  icon: const Icon(Icons.star_outline_rounded, size: 18),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text(isArabic ? 'المراكز (403)' : 'Districts (403)'),
                  icon: const Icon(Icons.map_outlined, size: 18),
                ),
                ButtonSegment(
                  value: 2,
                  label: Text(isArabic ? 'المحافظات (27)' : 'Govs (27)'),
                  icon: const Icon(Icons.location_city_outlined, size: 18),
                ),
              ],
              selected: {_selectedTab},
              onSelectionChanged: (set) => setState(() => _selectedTab = set.first),
            ),
          ),

          // Content List
          Expanded(
            child: catalogAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading zones: $err')),
              data: (catalog) {
                if (_selectedTab == 0) {
                  // 1) Tourist Highlights (42)
                  final list = catalog.highlights.where((h) {
                    if (_searchQuery.isEmpty) return true;
                    return h.nameAr.toLowerCase().contains(_searchQuery) ||
                        h.nameEn.toLowerCase().contains(_searchQuery);
                  }).toList();

                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 64),
                    itemBuilder: (context, i) {
                      final h = list[i];
                      final isSelected = zoneState?.match?.highlight?.id == h.id;
                      final gov = catalog.governorate(h.governorateCode);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? context.hena.gold
                              : context.hena.gold.withValues(alpha: 0.15),
                          child: Icon(
                            Icons.star_rounded,
                            color: isSelected ? context.colors.surface : context.hena.gold,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          isArabic ? h.nameAr : h.nameEn,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          gov != null ? (isArabic ? gov.nameAr : gov.nameEn) : '',
                          style: context.text.bodySmall,
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_rounded, color: context.hena.gold)
                            : null,
                        onTap: () {
                          ref.read(currentZoneProvider.notifier).selectManually(h.id);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  );
                } else if (_selectedTab == 1) {
                  // 2) Districts (403)
                  final list = catalog.districts.where((d) {
                    if (d.isTechnical) return false;
                    if (_searchQuery.isEmpty) return true;
                    return d.nameAr.toLowerCase().contains(_searchQuery) ||
                        d.nameEn.toLowerCase().contains(_searchQuery) ||
                        d.labelEn.toLowerCase().contains(_searchQuery);
                  }).toList();

                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 64),
                    itemBuilder: (context, i) {
                      final d = list[i];
                      final isSelected = zoneState?.match?.district?.id == d.id;
                      final gov = catalog.governorate(d.governorateCode);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? context.hena.turquoise
                              : context.hena.turquoise.withValues(alpha: 0.12),
                          child: Icon(
                            Icons.place_rounded,
                            color: isSelected
                                ? context.colors.surface
                                : context.hena.turquoiseText,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          isArabic ? d.nameArFull : d.labelEn,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          gov != null ? (isArabic ? gov.nameAr : gov.nameEn) : '',
                          style: context.text.bodySmall,
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_rounded, color: context.hena.turquoiseText)
                            : null,
                        onTap: () {
                          ref.read(currentZoneProvider.notifier).selectManually(d.id);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  );
                } else {
                  // 3) Governorates (27)
                  final list = catalog.governorates.where((g) {
                    if (_searchQuery.isEmpty) return true;
                    return g.nameAr.toLowerCase().contains(_searchQuery) ||
                        g.nameEn.toLowerCase().contains(_searchQuery);
                  }).toList();

                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 64),
                    itemBuilder: (context, i) {
                      final gov = list[i];
                      final isSelected = zoneState?.match?.district == null &&
                          zoneState?.match?.highlight == null &&
                          zoneState?.match?.governorate.code == gov.code;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? context.colors.primary
                              : context.colors.primary.withValues(alpha: 0.12),
                          child: Icon(
                            Icons.location_city_rounded,
                            color: isSelected
                                ? context.colors.onPrimary
                                : context.colors.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          isArabic ? gov.nameAr : gov.nameEn,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          '${gov.iso} • ${gov.areaKm2.toStringAsFixed(0)} km²',
                          style: context.text.bodySmall,
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_rounded, color: context.colors.primary)
                            : null,
                        onTap: () {
                          ref.read(currentZoneProvider.notifier).selectManually(gov.code);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
