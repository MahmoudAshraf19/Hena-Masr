import 'dart:math' as math;

import 'package:hena_masr/core/utils/geo_math.dart';
import 'package:hena_masr/features/zones/domain/entities/zone.dart';

/// Resolves a GPS coordinate into a zone. Pure Dart, offline, deterministic.
///
/// Order:
///  1. District polygon (exact point-in-polygon, holes supported).
///  2. Not in any polygon → neighbouring-country land? → outside Egypt.
///  3. Otherwise water / coast: snap to the nearest Egyptian district within
///     [approxToleranceM] (only if it is closer than any foreign land).
///  4. Desert "outside zemam" → try new-city circles, else governorate only.
///  5. Tourist highlight overlay (its governorate wins inside its circle).
///  6. Hysteresis against `previous` so the zone does not flicker at borders.
///
/// The Python reference implementation (tools/resolver_v2.py) mirrors this file
/// line by line and is what the dataset validation runs against.
final class ZoneResolver {
  ZoneResolver(this.catalog);

  final ZoneCatalog catalog;

  static const double approxToleranceM = 25000;
  static const double snapToDistrictM = 3000;
  static const double _minLat = 21.5, _maxLat = 32.3;
  static const double _minLng = 24.3, _maxLng = 37.3;

  ZoneMatch? resolve({
    required double lat,
    required double lng,
    double accuracyM = 0,
    ZoneMatch? previous,
  }) {
    if (lat < _minLat || lat > _maxLat || lng < _minLng || lng > _maxLng) {
      return null;
    }

    // 1) exact district polygon
    District? hit;
    for (final d in catalog.polygonDistricts) {
      if (d.shape!.contains(lat, lng)) {
        hit = d;
        break;
      }
    }

    var approximate = false;
    double? snapDistM;

    if (hit == null) {
      // 2) neighbouring land → not Egypt
      for (final n in catalog.neighbors) {
        if (n.contains(lat, lng)) return null;
      }
      // 3) water / coast snap
      District? nearest;
      var egyptD = double.infinity;
      for (final d in catalog.polygonDistricts) {
        if (!d.shape!.nearBounds(lat, lng, 0.3)) continue;
        final e = d.shape!.edgeDistanceM(lat, lng);
        if (e < egyptD) {
          egyptD = e;
          nearest = d;
        }
      }
      if (nearest == null || egyptD > approxToleranceM) return null;
      var foreignD = double.infinity;
      for (final n in catalog.neighbors) {
        if (!n.nearBounds(lat, lng, 0.5)) continue;
        final e = n.edgeDistanceM(lat, lng);
        if (e < foreignD) foreignD = e;
      }
      if (foreignD < egyptD) return null;
      hit = nearest;
      approximate = true;
      snapDistM = egyptD;
    }

    var governorateCode = hit.governorateCode;
    District? district = hit;
    var confidence = _confidenceFor(accuracyM);
    var nearBorder = false;

    if (approximate) {
      confidence =
          snapDistM! <= snapToDistrictM ? ZoneConfidence.medium : ZoneConfidence.low;
      if (snapDistM > snapToDistrictM) district = null;
    } else {
      final edge = hit.shape!.edgeDistanceM(lat, lng);
      nearBorder = edge < math.max(150.0, accuracyM);
      if (nearBorder) confidence = _downgrade(confidence);
    }

    // 4) desert outside the built-up area → new-city circle or governorate only
    var outsideZemam = district != null && district.kind == DistrictKind.outsideZemam;
    if (outsideZemam || district == null) {
      for (final c in catalog.circleDistricts) {
        if (c.governorateCode == governorateCode &&
            GeoMath.haversineM(lat, lng, c.lat, c.lng) <= c.radiusM!) {
          district = c;
          outsideZemam = false;
          break;
        }
      }
      if (outsideZemam) district = null;
    }

    // 5) tourist highlight overlay
    Highlight? highlight;
    var bestRatio = double.infinity;
    for (final h in catalog.highlights) {
      final d = GeoMath.haversineM(lat, lng, h.lat, h.lng);
      if (d > h.radiusM) continue;
      final ratio = d / h.radiusM;
      if (highlight == null ||
          h.priority > highlight.priority ||
          (h.priority == highlight.priority && ratio < bestRatio)) {
        highlight = h;
        bestRatio = ratio;
      }
    }
    if (highlight != null && highlight.governorateCode != governorateCode) {
      // Curated destination beats a boundary error in the 2017 polygons.
      governorateCode = highlight.governorateCode;
      district = null;
    }

    final gov = catalog.governorate(governorateCode);
    if (gov == null) return null;

    final fresh = ZoneMatch(
      governorate: gov,
      district: district,
      highlight: highlight,
      confidence: confidence,
      approximate: approximate,
      nearBorder: nearBorder,
      outsideZemam: outsideZemam,
      lat: lat,
      lng: lng,
      accuracyM: accuracyM,
    );
    if (previous == null) return fresh;
    return _applyHysteresis(fresh, previous, lat, lng, accuracyM);
  }

  /// Build a match from a stored / manually chosen zone id
  /// (highlight id, district id like EG0133, or governorate code like EG01).
  ZoneMatch? matchFromId(String id) {
    // 1. Check curated tourist highlights
    for (final h in catalog.highlights) {
      if (h.id == id) {
        final g = catalog.governorate(h.governorateCode);
        final d = h.districtId != null ? catalog.district(h.districtId!) : null;
        if (g != null) {
          return ZoneMatch(governorate: g, district: d, highlight: h);
        }
      }
    }

    // 2. Check district
    final d = catalog.district(id);
    if (d != null) {
      final g = catalog.governorate(d.governorateCode);
      return g == null ? null : ZoneMatch(governorate: g, district: d);
    }

    // 3. Check governorate by code or alias id
    final g = catalog.governorate(id) ?? catalog.governorateById(id);
    return g == null ? null : ZoneMatch(governorate: g);
  }

  // ---------------------------------------------------------------------------

  ZoneMatch _applyHysteresis(
    ZoneMatch fresh,
    ZoneMatch previous,
    double lat,
    double lng,
    double accuracyM,
  ) {
    final margin = math.max(150.0, accuracyM.clamp(0.0, 1000.0).toDouble());
    var district = fresh.district;
    var governorate = fresh.governorate;
    var highlight = fresh.highlight;

    // Just crossed a district border → keep the previous district while within
    // [margin] of its edge.
    final pd = previous.district;
    if (pd != null &&
        pd.shape != null &&
        fresh.district?.id != pd.id &&
        !fresh.approximate &&
        pd.shape!.edgeDistanceM(lat, lng) <= margin) {
      district = pd;
      governorate = previous.governorate;
    }

    // Just left a destination circle → keep it while within [margin].
    final ph = previous.highlight;
    if (ph != null &&
        fresh.highlight == null &&
        GeoMath.haversineM(lat, lng, ph.lat, ph.lng) <= ph.radiusM + margin) {
      highlight = ph;
    }

    if (identical(district, fresh.district) &&
        identical(highlight, fresh.highlight)) {
      return fresh;
    }
    return ZoneMatch(
      governorate: governorate,
      district: district,
      highlight: highlight,
      confidence: fresh.confidence,
      approximate: fresh.approximate,
      nearBorder: fresh.nearBorder,
      outsideZemam: fresh.outsideZemam,
      lat: lat,
      lng: lng,
      accuracyM: accuracyM,
    );
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
