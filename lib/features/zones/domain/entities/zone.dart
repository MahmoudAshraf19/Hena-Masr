import 'package:hena_masr/features/zones/domain/entities/geo_shape.dart';

/// Level 1 — governorate (27). Polygon is a light outline (display / fallback).
final class Governorate {
  const Governorate({
    required this.code,
    required this.id,
    required this.iso,
    required this.nameAr,
    required this.nameEn,
    required this.lat,
    required this.lng,
    required this.areaKm2,
    required this.shape,
  });

  final String code; // EG01 (stable key, same as the source dataset)
  final String id; // gov_cairo (readable alias)
  final String iso; // EG-C (ISO 3166-2)
  final String nameAr;
  final String nameEn;
  final double lat;
  final double lng;
  final double areaKm2;
  final GeoShape shape;
}

enum DistrictKind { qism, markaz, newCity, outsideZemam, port, region }

enum DistrictGeometry { polygon, approxCircle, point }

/// Level 2 — qism / markaz / new city inside a governorate
/// (Cairo → Gamaliya, Zamalek, Nasr City 1, Maadi, …).
final class District {
  const District({
    required this.id,
    required this.governorateCode,
    required this.kind,
    required this.nameAr,
    required this.nameArFull,
    required this.nameEn,
    required this.labelEn,
    required this.lat,
    required this.lng,
    required this.geometry,
    this.areaKm2,
    this.shape,
    this.radiusM,
    this.splitInto = const [],
  });

  final String id; // EG0133 (stable key)
  final String governorateCode;
  final DistrictKind kind;
  final String nameAr; // الزمالك
  final String nameArFull; // قسم الزمالك
  final String nameEn; // Zamalek
  final String labelEn; // Zamalek (Qism)
  final double lat; // representative point (always inside the polygon)
  final double lng;
  final DistrictGeometry geometry;
  final double? areaKm2;
  final GeoShape? shape; // only for [DistrictGeometry.polygon]
  final double? radiusM; // only for [DistrictGeometry.approxCircle]

  /// Units created after 2017 by splitting this one. They have no polygon of
  /// their own; this district's polygon covers them.
  final List<({String id, String nameAr, String nameEn})> splitInto;

  /// Hide from pickers: technical units, not places people name.
  bool get isTechnical =>
      kind == DistrictKind.outsideZemam || kind == DistrictKind.port;
}

/// Curated tourist destination (circle). An overlay, not an administrative unit.
final class Highlight {
  const Highlight({
    required this.id,
    required this.governorateCode,
    required this.nameAr,
    required this.nameEn,
    required this.lat,
    required this.lng,
    required this.radiusM,
    required this.priority,
    this.districtId,
  });

  final String id;
  final String governorateCode;
  final String nameAr;
  final String nameEn;
  final double lat;
  final double lng;
  final double radiusM;
  final int priority;
  final String? districtId;
}

/// Level 3 — urban neighbourhood / city inside a district (optional pack).
final class Locality {
  const Locality({
    required this.id,
    required this.districtId,
    required this.governorateCode,
    required this.nameAr,
    required this.nameEn,
    required this.shape,
  });

  final String id;
  final String districtId;
  final String governorateCode;
  final String nameAr;
  final String nameEn;
  final GeoShape shape;
}

final class ZoneCatalog {
  ZoneCatalog({
    required this.governorates,
    required this.districts,
    required this.highlights,
    required this.neighbors,
  })  : _govByCode = {for (final g in governorates) g.code: g},
        _districtById = {for (final d in districts) d.id: d},
        polygonDistricts = districts
            .where((d) => d.geometry == DistrictGeometry.polygon)
            .toList(growable: false),
        circleDistricts = districts
            .where((d) => d.geometry == DistrictGeometry.approxCircle)
            .toList(growable: false);

  final List<Governorate> governorates;
  final List<District> districts;
  final List<Highlight> highlights;

  /// Land of neighbouring countries — used only to reject non-Egypt points.
  final List<GeoShape> neighbors;

  final List<District> polygonDistricts;
  final List<District> circleDistricts;
  final Map<String, Governorate> _govByCode;
  final Map<String, District> _districtById;

  Governorate? governorate(String code) => _govByCode[code];
  District? district(String id) => _districtById[id];

  Governorate? governorateById(String id) {
    for (final g in governorates) {
      if (g.id == id) return g;
    }
    return null;
  }

  /// Districts of a governorate for pickers (technical units hidden), A→Z by
  /// the Arabic name.
  List<District> districtsOf(String governorateCode) => districts
      .where((d) => d.governorateCode == governorateCode && !d.isTechnical)
      .toList(growable: false)
    ..sort((a, b) => a.nameAr.compareTo(b.nameAr));
}

enum ZoneConfidence { high, medium, low }

enum ZoneSource { gps, cached, manual }

/// Result of resolving a coordinate to a zone.
final class ZoneMatch {
  const ZoneMatch({
    required this.governorate,
    this.district,
    this.highlight,
    this.locality,
    this.confidence = ZoneConfidence.high,
    this.approximate = false,
    this.nearBorder = false,
    this.outsideZemam = false,
    this.lat,
    this.lng,
    this.accuracyM,
  });

  final Governorate governorate;

  /// null when the point is in desert / outside the built-up area, or when the
  /// district could not be determined reliably.
  final District? district;

  /// Tourist destination overlay (Giza Pyramids, Karnak, Sharm, …) if inside.
  final Highlight? highlight;

  /// Neighbourhood, only when the locality pack is loaded and the point is inside.
  final Locality? locality;

  final ZoneConfidence confidence;

  /// Point was in water / outside every polygon and snapped to the nearest land.
  final bool approximate;

  /// Point is close to a district border.
  final bool nearBorder;

  final bool outsideZemam;

  /// The exact GPS latitude of the resolved point, if available.
  final double? lat;

  /// The exact GPS longitude of the resolved point, if available.
  final double? lng;

  /// The GPS accuracy in meters at the time of resolution.
  final double? accuracyM;

  /// The id places should be filtered by (most specific administrative level).
  String get zoneId => district?.id ?? governorate.code;

  String get nameAr => locality?.nameAr ?? district?.nameAr ?? governorate.nameAr;
  String get nameEn => locality?.nameEn ?? district?.nameEn ?? governorate.nameEn;

  bool get needsConfirmation => confidence == ZoneConfidence.low;

  /// Calculated confidence percentage (0% to 100%).
  int get confidencePercentage {
    int score = 88;
    if (highlight != null) {
      score = 96;
    } else if (district != null) {
      score = 92;
    } else {
      score = 80;
    }

    if (locality != null) score += 3;
    if (nearBorder) score -= 14;
    if (approximate) score -= 16;
    if (outsideZemam) score -= 12;

    if (accuracyM != null) {
      if (accuracyM! <= 15) {
        score += 3;
      } else if (accuracyM! > 120) {
        score -= 15;
      } else if (accuracyM! > 50) {
        score -= 7;
      }
    }

    if (confidence == ZoneConfidence.high) {
      score = score.clamp(86, 99);
    } else if (confidence == ZoneConfidence.medium) {
      score = score.clamp(66, 85);
    } else {
      score = score.clamp(35, 65);
    }

    return score;
  }

  /// Arabic descriptive label of confidence
  String get confidenceLabelAr {
    final pct = confidencePercentage;
    if (pct >= 90) return 'مطابقة ممتازة ومؤكدة';
    if (pct >= 75) return 'دقة جيدة جداً';
    if (pct >= 60) return 'دقة متوسطة';
    return 'قريب من الحدود (يُفضل التأكيد)';
  }

  ZoneMatch copyWith({
    Locality? locality,
    double? lat,
    double? lng,
    double? accuracyM,
  }) =>
      ZoneMatch(
        governorate: governorate,
        district: district,
        highlight: highlight,
        locality: locality ?? this.locality,
        confidence: confidence,
        approximate: approximate,
        nearBorder: nearBorder,
        outsideZemam: outsideZemam,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        accuracyM: accuracyM ?? this.accuracyM,
      );
}
