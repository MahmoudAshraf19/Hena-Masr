import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hena_masr/core/constants/asset_paths.dart';
import 'package:hena_masr/core/theme/theme_context.dart';
import 'package:hena_masr/features/zones/domain/entities/zone.dart';
import 'package:hena_masr/features/zones/presentation/providers/zone_providers.dart';
import 'package:hena_masr/features/zones/presentation/widgets/zone_picker_sheet.dart';

/// Screen displayed after splash to present:
/// 1. User's exact GPS coordinates & accuracy
/// 2. Assigned Zone hierarchy (Governorate, District, Locality, Highlight)
/// 3. Computed Zone Accuracy / Confidence Percentage (%)
class ZoneVerificationScreen extends ConsumerWidget {
  const ZoneVerificationScreen({
    super.key,
    required this.onConfirmed,
  });

  final VoidCallback onConfirmed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zoneAsync = ref.watch(currentZoneProvider);
    final zoneState = zoneAsync.value;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final colors = context.hena;

    final match = zoneState?.match;
    final pos = zoneState?.rawPosition;
    final isDetecting = zoneState?.status == ZoneStatus.detecting;

    // Computed confidence percentage (e.g. 96%, 92%, etc.)
    final confidencePct = match?.confidencePercentage ?? (isDetecting ? 0 : 75);
    final confidenceLabel = match?.confidenceLabelAr ??
        (isDetecting ? 'جارِ تحديد الموقع...' : 'منطقة قياسية');

    return Scaffold(
      backgroundColor: const Color(0xFF131A22), // Deep basalt background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AssetPaths.appLogo, height: 26, width: 26),
            const SizedBox(width: 8),
            Text(
              isArabic ? 'التحقق من الموقع والمنطقة' : 'Location & Zone Verification',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
            tooltip: isArabic ? 'إعادة فحص الـ GPS' : 'Refresh GPS',
            onPressed: isDetecting
                ? null
                : () => ref.read(currentZoneProvider.notifier).detect(),
          ),
        ],
      ),
      body: SafeArea(
        child: zoneAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFD700)),
          ),
          error: (err, _) => Center(
            child: Text(
              isArabic ? 'حدث خطأ أثناء تحميل البيانات' : 'Error loading zones',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          data: (_) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Hero Confidence Circular Gauge Card
                  _buildConfidenceCard(
                    context,
                    pct: confidencePct,
                    label: confidenceLabel,
                    match: match,
                    isArabic: isArabic,
                    colors: colors,
                  ),
                  const SizedBox(height: 16),

                  // 2. Exact GPS Coordinates Card
                  _buildCoordinatesCard(
                    context,
                    pos: pos,
                    match: match,
                    source: zoneState?.source ?? ZoneSource.gps,
                    isArabic: isArabic,
                    colors: colors,
                  ),
                  const SizedBox(height: 16),

                  // 3. Zone Administrative & Geographic Hierarchy
                  _buildZoneHierarchyCard(
                    context,
                    match: match,
                    isArabic: isArabic,
                    colors: colors,
                    onManualPick: () => ZonePickerSheet.show(context),
                  ),
                  const SizedBox(height: 24),

                  // 4. Action Buttons (Confirm & Enter / Change Zone)
                  ElevatedButton(
                    onPressed: onConfirmed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: const Color(0xFF17202A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          isArabic ? 'تأكيد المنطقة والمتابعة' : 'Confirm & Proceed',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  OutlinedButton(
                    onPressed: () => ZonePickerSheet.show(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.edit_location_alt_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          isArabic ? 'اختيار منطقة سياحية أخرى يدوياً' : 'Pick another zone manually',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 1. Radial Percentage & Confidence Breakdown
  Widget _buildConfidenceCard(
    BuildContext context, {
    required int pct,
    required String label,
    required ZoneMatch? match,
    required bool isArabic,
    required dynamic colors,
  }) {
    Color gaugeColor;
    if (pct >= 85) {
      gaugeColor = const Color(0xFF10B981); // Emerald
    } else if (pct >= 65) {
      gaugeColor = const Color(0xFFF59E0B); // Amber
    } else {
      gaugeColor = const Color(0xFFEF4444); // Red
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A232F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: gaugeColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: gaugeColor.withValues(alpha: 0.12),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Radial Gauge
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: pct / 100.0,
                      strokeWidth: 8,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(gaugeColor),
                    ),
                  ),
                  Text(
                    '$pct%',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: gaugeColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 18),

              // Title and verdict
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'نسبة صحة ودقة الزون' : 'Zone Match Accuracy',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: gaugeColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isArabic
                          ? 'مطابقة هندسية رسمية مع مضلعات الجهاز المركزي (CAPMAS/OCHA)'
                          : 'Official geometric match against CAPMAS / OCHA boundaries',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white54,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(color: Colors.white12, height: 28),

          // Quality factors
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFactorItem(
                title: isArabic ? 'المضلع الرسمي' : 'Official Polygon',
                value: match?.district != null
                    ? (isArabic ? 'مؤكد 100%' : 'Exact')
                    : (isArabic ? 'عام للمحافظة' : 'Gov-level'),
                isPositive: match?.district != null,
              ),
              _buildFactorItem(
                title: isArabic ? 'قرب الحدود' : 'Near Border',
                value: (match?.nearBorder ?? false)
                    ? (isArabic ? 'نعم (±150m)' : 'Yes')
                    : (isArabic ? 'في العمق' : 'Deep Inside'),
                isPositive: !(match?.nearBorder ?? false),
              ),
              _buildFactorItem(
                title: isArabic ? 'دقة الإشارة' : 'GPS Signal',
                value: (match?.accuracyM ?? 15) <= 25
                    ? (isArabic ? 'عالية جداً' : 'Excellent')
                    : (isArabic ? 'متوسطة' : 'Moderate'),
                isPositive: (match?.accuracyM ?? 15) <= 50,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFactorItem({
    required String title,
    required String value,
    required bool isPositive,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: Colors.white54),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isPositive ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  /// 2. Current GPS Coordinates Card
  Widget _buildCoordinatesCard(
    BuildContext context, {
    required dynamic pos,
    required ZoneMatch? match,
    required ZoneSource source,
    required bool isArabic,
    required dynamic colors,
  }) {
    final lat = pos?.latitude ?? match?.lat ?? 30.0444;
    final lng = pos?.longitude ?? match?.lng ?? 31.2357;
    final acc = pos?.accuracy ?? match?.accuracyM ?? 8.5;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A232F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.my_location_rounded,
                    color: Color(0xFFFFD700), size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                isArabic ? 'إحداثيات الموقع الحالي المستلم' : 'Current GPS Coordinates',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: source == ZoneSource.gps
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  source == ZoneSource.gps
                      ? (isArabic ? 'GPS حي' : 'Live GPS')
                      : (source == ZoneSource.manual
                          ? (isArabic ? 'يدوي' : 'Manual')
                          : (isArabic ? 'كاش' : 'Cached')),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: source == ZoneSource.gps
                        ? const Color(0xFF10B981)
                        : Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Coordinates Grid
          Row(
            children: [
              Expanded(
                child: _buildCoordTile(
                  label: isArabic ? 'خط العرض (Lat)' : 'Latitude',
                  val: '${lat.toStringAsFixed(6)}° N',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCoordTile(
                  label: isArabic ? 'خط الطول (Lng)' : 'Longitude',
                  val: '${lng.toStringAsFixed(6)}° E',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Accuracy & status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.track_changes_rounded,
                    size: 16, color: Color(0xFF00E5FF)),
                const SizedBox(width: 8),
                Text(
                  isArabic
                      ? 'دقة إشارة الموقع: ±${acc.toStringAsFixed(1)} متر'
                      : 'Signal Accuracy: ±${acc.toStringAsFixed(1)} m',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordTile({required String label, required String val}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54)),
          const SizedBox(height: 3),
          Text(
            val,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFE082),
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Zone Administrative & Geographic Hierarchy Card
  Widget _buildZoneHierarchyCard(
    BuildContext context, {
    required ZoneMatch? match,
    required bool isArabic,
    required dynamic colors,
    required VoidCallback onManualPick,
  }) {
    final gov = match?.governorate;
    final dist = match?.district;
    final high = match?.highlight;
    final loc = match?.locality;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A232F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_rounded,
                    color: Color(0xFF00E5FF), size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                isArabic ? 'التسلسل الإداري للزون المطابقة' : 'Assigned Zone Hierarchy',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 1) Tourist Highlight (Destination)
          if (high != null) ...[
            _buildHierarchyRow(
              icon: Icons.stars_rounded,
              iconColor: const Color(0xFFFFD700),
              level: isArabic ? 'الوجهة السياحية' : 'Tourist Destination',
              title: isArabic ? high.nameAr : high.nameEn,
              subtitle: isArabic
                  ? 'منطقة سياحية وتاريخية منتقاة'
                  : 'Curated historic destination',
            ),
            const Divider(color: Colors.white10, height: 16),
          ],

          // 2) Locality (Level 3)
          if (loc != null) ...[
            _buildHierarchyRow(
              icon: Icons.location_city_rounded,
              iconColor: const Color(0xFF26A69A),
              level: isArabic ? 'الحي / المدينة الفرعية (المستوى 3)' : 'Locality (Level 3)',
              title: isArabic ? loc.nameAr : loc.nameEn,
              subtitle: isArabic
                  ? 'مضلع تفصيلي ضمن قاعدة الـ 1,275 حي'
                  : 'Detailed urban neighbourhood',
            ),
            const Divider(color: Colors.white10, height: 16),
          ],

          // 3) District (Level 2)
          _buildHierarchyRow(
            icon: Icons.map_rounded,
            iconColor: const Color(0xFF38BDF8),
            level: isArabic ? 'القسم / المركز (المستوى 2)' : 'District / Qism (Level 2)',
            title: dist != null
                ? (isArabic ? dist.nameArFull : dist.labelEn)
                : (isArabic ? 'نطاق صحراوي مفتوح للمحافظة' : 'Governorate open zone'),
            subtitle: dist != null
                ? 'كود المركز: ${dist.id} • ${dist.geometry.name}'
                : (isArabic ? 'بدون مركز فرعي' : 'No sub-district'),
          ),
          const Divider(color: Colors.white10, height: 16),

          // 4) Governorate (Level 1)
          _buildHierarchyRow(
            icon: Icons.flag_rounded,
            iconColor: const Color(0xFFF59E0B),
            level: isArabic ? 'المحافظة (المستوى 1)' : 'Governorate (Level 1)',
            title: gov != null
                ? (isArabic ? gov.nameAr : gov.nameEn)
                : (isArabic ? 'جمهورية مصر العربية' : 'Egypt'),
            subtitle: gov != null
                ? 'كود: ${gov.code} • ${gov.iso} • المساحة: ${gov.areaKm2.toStringAsFixed(0)} كم²'
                : 'ISO: EG',
          ),
        ],
      ),
    );
  }

  Widget _buildHierarchyRow({
    required IconData icon,
    required Color iconColor,
    required String level,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                level,
                style: const TextStyle(fontSize: 11, color: Colors.white54),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.white38),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
