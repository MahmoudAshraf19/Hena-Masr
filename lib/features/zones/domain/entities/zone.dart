import 'dart:typed_data';

import 'package:hena_masr/core/utils/geo_math.dart';

/// Governorate-level zone (27 governorates). Together they cover the country.
final class Governorate {
  Governorate({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.rings,
  }) : bounds = rings.map(GeoBounds.ofRing).toList(growable: false);

  final String id; // e.g. gov_giza
  final String nameAr;
  final String nameEn;
  final List<Float64List> rings;
  final List<GeoBounds> bounds;

  double get boundsArea => bounds.fold(0.0, (s, b) => s + b.areaDeg2);

  bool contains(double lat, double lng) {
    for (var i = 0; i < rings.length; i++) {
      if (bounds[i].contains(lat, lng) &&
          GeoMath.pointInRing(lat, lng, rings[i])) {
        return true;
      }
    }
    return false;
  }

  /// Meters to the nearest border edge (inside or outside).
  double edgeDistanceM(double lat, double lng) {
    var best = double.infinity;
    for (final r in rings) {
      final d = GeoMath.distanceToRingM(lat, lng, r);
      if (d < best) best = d;
    }
    return best;
  }
}

/// Curated tourist / famous-area zone (circle). Takes priority over the
/// governorate polygon because it is hand-verified and more precise.
final class Area {
  const Area({
    required this.id,
    required this.governorateId,
    required this.nameAr,
    required this.nameEn,
    required this.lat,
    required this.lng,
    required this.radiusM,
    required this.priority,
  });

  final String id;
  final String governorateId;
  final String nameAr;
  final String nameEn;
  final double lat;
  final double lng;
  final double radiusM;

  /// Higher wins when circles overlap (e.g. GEM inside the Giza plateau zone).
  final int priority;
}

final class ZoneCatalog {
  ZoneCatalog({required this.governorates, required this.areas})
      : _govById = {for (final g in governorates) g.id: g},
        _areaById = {for (final a in areas) a.id: a};

  final List<Governorate> governorates;
  final List<Area> areas;
  final Map<String, Governorate> _govById;
  final Map<String, Area> _areaById;

  Governorate? governorate(String id) => _govById[id];
  Area? area(String id) => _areaById[id];

  List<Area> areasOf(String governorateId) => areas
      .where((a) => a.governorateId == governorateId)
      .toList(growable: false);
}

enum ZoneConfidence { high, medium, low }

enum ZoneSource { gps, cached, manual }

/// Result of resolving a coordinate to a zone.
final class ZoneMatch {
  const ZoneMatch({
    required this.governorate,
    this.area,
    this.confidence = ZoneConfidence.high,
    this.approximate = false,
    this.nearBorder = false,
  });

  final Governorate governorate;
  final Area? area;
  final ZoneConfidence confidence;

  /// Point was outside every polygon (coast / sea) and snapped to the nearest
  /// governorate within tolerance.
  final bool approximate;

  /// Point is close to a governorate border → ask the user to confirm.
  final bool nearBorder;

  /// Id used to store the zone and to filter places.
  String get primaryId => area?.id ?? governorate.id;
  String get nameAr => area?.nameAr ?? governorate.nameAr;
  String get nameEn => area?.nameEn ?? governorate.nameEn;

  bool get needsConfirmation => confidence == ZoneConfidence.low;
}
