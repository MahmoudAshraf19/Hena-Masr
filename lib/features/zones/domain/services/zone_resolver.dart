import 'dart:math' as math;

import 'package:hena_masr/core/utils/geo_math.dart';
import 'package:hena_masr/features/zones/domain/entities/zone.dart';

/// Resolves a GPS coordinate into a zone. Pure Dart, offline, deterministic.
///
/// Order:
///  1. Curated area (circle) — highest priority wins.
///  2. Governorate polygon (point-in-polygon, bbox pre-filter).
///  3. Nearest governorate within [approxToleranceM] (coast / sea / coarse border).
///  4. null → outside Egypt.
/// Then hysteresis against `previous` so the zone doesn't flicker at borders.
final class ZoneResolver {
  ZoneResolver(this.catalog);

  final ZoneCatalog catalog;

  static const double approxToleranceM = 25000;
  static const double _minLat = 21.5, _maxLat = 32.0;
  static const double _minLng = 24.5, _maxLng = 36.9;

  ZoneMatch? resolve({
    required double lat,
    required double lng,
    double accuracyM = 0,
    ZoneMatch? previous,
  }) {
    if (lat < _minLat || lat > _maxLat || lng < _minLng || lng > _maxLng) {
      return null;
    }
    final fresh = _resolveRaw(lat, lng, accuracyM);
    if (fresh == null) return null;
    if (previous == null) return fresh;
    return _applyHysteresis(fresh, previous, lat, lng, accuracyM);
  }

  /// Build a match from a stored / manually chosen zone id.
  ZoneMatch? matchFromId(String id) {
    final area = catalog.area(id);
    if (area != null) {
      final gov = catalog.governorate(area.governorateId);
      if (gov == null) return null;
      return ZoneMatch(governorate: gov, area: area);
    }
    final gov = catalog.governorate(id);
    return gov == null ? null : ZoneMatch(governorate: gov);
  }

  // ---------------------------------------------------------------------------

  ZoneMatch? _resolveRaw(double lat, double lng, double acc) {
    // 1) curated areas
    Area? best;
    var bestRatio = double.infinity;
    for (final a in catalog.areas) {
      final d = GeoMath.haversineM(lat, lng, a.lat, a.lng);
      if (d > a.radiusM) continue;
      final ratio = d / a.radiusM;
      if (best == null ||
          a.priority > best.priority ||
          (a.priority == best.priority && ratio < bestRatio)) {
        best = a;
        bestRatio = ratio;
      }
    }
    if (best != null) {
      final gov = catalog.governorate(best.governorateId);
      if (gov != null) {
        var conf = _confidenceFor(acc);
        if (acc > best.radiusM) conf = _downgrade(conf);
        return ZoneMatch(governorate: gov, area: best, confidence: conf);
      }
    }

    // 2) governorate polygons (smallest wins if borders overlap)
    Governorate? hit;
    for (final g in catalog.governorates) {
      if (g.contains(lat, lng) &&
          (hit == null || g.boundsArea < hit.boundsArea)) {
        hit = g;
      }
    }
    if (hit != null) {
      final border = hit.edgeDistanceM(lat, lng);
      final near = border < math.max(1500.0, acc);
      var conf = _confidenceFor(acc);
      if (near) conf = _downgrade(conf);
      return ZoneMatch(governorate: hit, confidence: conf, nearBorder: near);
    }

    // 3) coast / sea / coarse border → nearest governorate within tolerance
    Governorate? nearest;
    var nearestD = double.infinity;
    for (final g in catalog.governorates) {
      final d = g.edgeDistanceM(lat, lng);
      if (d < nearestD) {
        nearestD = d;
        nearest = g;
      }
    }
    if (nearest != null && nearestD <= approxToleranceM) {
      return ZoneMatch(
        governorate: nearest,
        confidence: ZoneConfidence.low,
        approximate: true,
      );
    }
    return null; // outside Egypt
  }

  ZoneMatch _applyHysteresis(
    ZoneMatch fresh,
    ZoneMatch previous,
    double lat,
    double lng,
    double acc,
  ) {
    if (fresh.primaryId == previous.primaryId) return fresh;
    final margin = math.max(150.0, acc.clamp(0.0, 1000.0).toDouble());

    // Just stepped out of an area into the plain governorate → keep the area
    // while still within [margin] of its edge.
    final pa = previous.area;
    if (pa != null &&
        fresh.area == null &&
        GeoMath.haversineM(lat, lng, pa.lat, pa.lng) <= pa.radiusM + margin) {
      return previous;
    }

    // Crossed a governorate border → keep the previous governorate while still
    // within [margin] of its border.
    if (fresh.area == null &&
        previous.area == null &&
        fresh.governorate.id != previous.governorate.id &&
        previous.governorate.edgeDistanceM(lat, lng) <= margin) {
      return previous;
    }
    return fresh;
  }

  static ZoneConfidence _confidenceFor(double acc) {
    if (acc <= 200) return ZoneConfidence.high;
    if (acc <= 2000) return ZoneConfidence.medium;
    return ZoneConfidence.low;
  }

  static ZoneConfidence _downgrade(ZoneConfidence c) => switch (c) {
        ZoneConfidence.high => ZoneConfidence.medium,
        ZoneConfidence.medium => ZoneConfidence.low,
        ZoneConfidence.low => ZoneConfidence.low,
      };
}
