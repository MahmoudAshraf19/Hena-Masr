import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hena_masr/core/constants/asset_paths.dart';
import 'package:hena_masr/features/zones/domain/entities/zone.dart';
import 'package:hena_masr/features/zones/presentation/providers/zone_providers.dart';
import 'package:hena_masr/features/zones/presentation/widgets/zone_picker_sheet.dart';

/// Single, clean, bilingual screen displaying:
/// 1. GPS Coordinates (Latitude, Longitude, Accuracy)
/// 2. Assigned Zone Hierarchy (Governorate, District, Locality, Highlight)
/// 3. Computed Zone Confidence / Accuracy Percentage (%)
class ZoneResultScreen extends ConsumerWidget {
  const ZoneResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zoneAsync = ref.watch(currentZoneProvider);
    final zoneState = zoneAsync.value;
    final match = zoneState?.match;
    final pos = zoneState?.rawPosition;
    final isDetecting = zoneState?.status == ZoneStatus.detecting;

    debugPrint('📍 [ZoneResultScreen] Rendering: match=${match?.nameAr ?? "None"}, status=${zoneState?.status}');

    return Scaffold(
      backgroundColor: const Color(0xFF0F141C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161E29),
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AssetPaths.appLogo, height: 26, width: 26),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'نتيجة فحص الموقع والزون',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Location & Zone Result',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFFFD700),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: isDetecting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFFFD700),
                    ),
                  )
                : const Icon(Icons.refresh_rounded, color: Color(0xFFFFD700)),
            tooltip: 'إعادة الفحص / Refresh',
            onPressed: isDetecting
                ? null
                : () => ref.read(currentZoneProvider.notifier).detect(),
          ),
        ],
      ),
      body: SafeArea(
        child: zoneAsync.when(
          loading: () => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFFFFD700)),
                SizedBox(height: 16),
                Text(
                  'جاري قراءة الموقع والزون...\nDetecting location and zone...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.amber, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'تعذر قراءة الموقع\nUnable to retrieve location',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    err.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () => ref.read(currentZoneProvider.notifier).detect(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة / Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (_) {
            if (isDetecting && match == null) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFFFD700)),
                    SizedBox(height: 16),
                    Text(
                      'جاري الاتصال بالـ GPS وتحديد الزون...\nAcquiring GPS fix & matching zone...',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              );
            }

            if (zoneState?.status == ZoneStatus.outsideEgypt && match == null) {
              return _buildOutsideEgyptCard(context, ref, pos);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Confidence Percentage Card
                  _buildConfidenceCard(match, isDetecting),
                  const SizedBox(height: 16),

                  // 2. GPS Location Card
                  _buildGpsCard(pos, match),
                  const SizedBox(height: 16),

                  // 3. Assigned Zone Card
                  _buildZoneDetailsCard(match),
                  const SizedBox(height: 24),

                  // 4. Action Buttons (Refresh + Manual Selection)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFFD700)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => ZonePickerSheet.show(context),
                          icon: const Icon(Icons.edit_location_alt_outlined, color: Color(0xFFFFD700), size: 20),
                          label: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'تغيير المنطقة يدوياً',
                                style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                'Select Zone Manually',
                                style: TextStyle(color: Colors.white70, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: const Color(0xFF0F141C),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isDetecting
                              ? null
                              : () => ref.read(currentZoneProvider.notifier).detect(),
                          icon: isDetecting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                              : const Icon(Icons.my_location_rounded, size: 20),
                          label: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'إعادة فحص الموقع',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                'Refresh Live GPS',
                                style: TextStyle(fontSize: 10, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 1. Card: Zone Confidence Percentage (%)
  Widget _buildConfidenceCard(ZoneMatch? match, bool isDetecting) {
    final pct = match?.confidencePercentage ?? 0;
    final labelAr = match?.confidenceLabelAr ?? 'جارِ الحساب...';

    Color statusColor;
    String statusEn;
    if (pct >= 90) {
      statusColor = const Color(0xFF00E676); // Vivid Green
      statusEn = 'Excellent / Highly Accurate';
    } else if (pct >= 75) {
      statusColor = const Color(0xFFFFD700); // Gold
      statusEn = 'Good / High Confidence';
    } else if (pct >= 50) {
      statusColor = const Color(0xFFFF9100); // Orange
      statusEn = 'Moderate / Estimated';
    } else {
      statusColor = const Color(0xFFFF5252); // Red
      statusEn = 'Low Accuracy';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161E29),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'نسبة صحة ودقة الزون',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Zone Match Confidence',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '$labelAr • $statusEn',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0F141C),
                  border: Border.all(color: statusColor, width: 3),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$pct%',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct / 100.0,
              minHeight: 8,
              backgroundColor: const Color(0xFF0F141C),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Card: GPS Location Coordinates
  Widget _buildGpsCard(dynamic pos, ZoneMatch? match) {
    final lat = pos?.latitude ?? match?.lat ?? 0.0;
    final lng = pos?.longitude ?? match?.lng ?? 0.0;
    final accuracy = pos?.accuracy ?? match?.accuracyM ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161E29),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.satellite_alt_rounded, color: Color(0xFFFFD700), size: 20),
              SizedBox(width: 8),
              Text(
                'إحداثيات الموقع (GPS)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 6),
              Text(
                '• GPS Coordinates',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 20),
          _buildBilingualRow(
            titleAr: 'خط العرض',
            titleEn: 'Latitude',
            value: lat == 0.0 ? '--' : lat.toStringAsFixed(6),
            icon: Icons.explore_outlined,
          ),
          const SizedBox(height: 10),
          _buildBilingualRow(
            titleAr: 'خط الطول',
            titleEn: 'Longitude',
            value: lng == 0.0 ? '--' : lng.toStringAsFixed(6),
            icon: Icons.explore_outlined,
          ),
          const SizedBox(height: 10),
          _buildBilingualRow(
            titleAr: 'دقة الإشارة',
            titleEn: 'Signal Accuracy',
            value: accuracy == 0.0 ? 'غير محددة' : '±${accuracy.toStringAsFixed(1)} متر / m',
            icon: Icons.gps_fixed_rounded,
          ),
        ],
      ),
    );
  }

  /// 3. Card: Assigned Zone Hierarchy
  Widget _buildZoneDetailsCard(ZoneMatch? match) {
    if (match == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161E29),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'لم يتم تحديد الزون بعد\nNo Zone Assigned Yet',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    final gov = match.governorate;
    final district = match.district;
    final locality = match.locality;
    final highlight = match.highlight;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161E29),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_city_rounded, color: Color(0xFFFFD700), size: 20),
              SizedBox(width: 8),
              Text(
                'الزون والتقسيم الإداري',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 6),
              Text(
                '• Assigned Zone',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 20),

          // 1. Highlight (if inside a landmark)
          if (highlight != null) ...[
            _buildBilingualRow(
              titleAr: 'الوجهة السياحية',
              titleEn: 'Tourist Highlight',
              value: '${highlight.nameAr} (${highlight.nameEn})',
              icon: Icons.stars_rounded,
              highlightColor: const Color(0xFFFFD700),
            ),
            const SizedBox(height: 10),
          ],

          // 2. Locality (Level 3)
          if (locality != null) ...[
            _buildBilingualRow(
              titleAr: 'المنطقة / الشياخة',
              titleEn: 'Locality (Level 3)',
              value: '${locality.nameAr} (${locality.nameEn})',
              icon: Icons.holiday_village_outlined,
            ),
            const SizedBox(height: 10),
          ],

          // 3. District (Level 2)
          _buildBilingualRow(
            titleAr: 'القسم / المركز',
            titleEn: 'District / Qism',
            value: district != null ? '${district.nameAr} (${district.nameEn})' : 'عام / General',
            icon: Icons.map_outlined,
          ),
          const SizedBox(height: 10),

          // 4. Governorate (Level 1)
          _buildBilingualRow(
            titleAr: 'المحافظة',
            titleEn: 'Governorate',
            value: '${gov.nameAr} (${gov.nameEn})',
            icon: Icons.flag_outlined,
            highlightColor: const Color(0xFF00E5FF),
          ),
        ],
      ),
    );
  }

  Widget _buildBilingualRow({
    required String titleAr,
    required String titleEn,
    required String value,
    required IconData icon,
    Color? highlightColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F141C),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: highlightColor ?? const Color(0xFFFFD700)),
          const SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titleAr,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  titleEn,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: highlightColor ?? Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutsideEgyptCard(BuildContext context, WidgetRef ref, dynamic pos) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.public_off_rounded, color: Colors.orangeAccent, size: 56),
            const SizedBox(height: 16),
            const Text(
              'أنت خارج جمهورية مصر العربية\nYou are outside Egypt',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'الإحداثيات الحالية: (${pos?.latitude ?? 0}, ${pos?.longitude ?? 0})\nيمكنك اختيار أي محافظة أو وجهة مصرية يدوياً للتصفح',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () => ZonePickerSheet.show(context),
              icon: const Icon(Icons.map_rounded),
              label: const Text('اختيار وجهة مصرية / Select Egypt Zone'),
            ),
          ],
        ),
      ),
    );
  }
}
