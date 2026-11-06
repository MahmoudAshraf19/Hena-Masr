import 'dart:typed_data';

import 'package:hena_masr/core/utils/geo_math.dart';

/// One polygon: an outer ring plus optional holes. Rings are flat
/// [lat0, lng0, lat1, lng1, ...] arrays (closed: last point == first point).
final class GeoPolygon {
  GeoPolygon(this.outer, this.holes) : bounds = GeoBounds.ofRing(outer);

  final Float64List outer;
  final List<Float64List> holes;
  final GeoBounds bounds;

  bool contains(double lat, double lng) {
    if (!bounds.contains(lat, lng)) return false;
    if (!GeoMath.pointInRing(lat, lng, outer)) return false;
    for (final h in holes) {
      if (GeoMath.pointInRing(lat, lng, h)) return false;
    }
    return true;
  }

  /// Meters to the nearest edge (outer ring or a hole).
  double edgeDistanceM(double lat, double lng) {
    var best = GeoMath.distanceToRingM(lat, lng, outer);
    for (final h in holes) {
      final d = GeoMath.distanceToRingM(lat, lng, h);
      if (d < best) best = d;
    }
    return best;
  }
}

/// A MultiPolygon (one or more [GeoPolygon]s) with a cached overall bounds.
final class GeoShape {
  GeoShape(this.polygons)
      : bounds = GeoBounds.union(polygons.map((p) => p.bounds));

  final List<GeoPolygon> polygons;
  final GeoBounds bounds;

  bool contains(double lat, double lng) {
    if (!bounds.contains(lat, lng)) return false;
    for (final p in polygons) {
      if (p.contains(lat, lng)) return true;
    }
    return false;
  }

  /// True if the point is within [deg] degrees of this shape's bounding box.
  bool nearBounds(double lat, double lng, double deg) =>
      bounds.contains(lat, lng, marginDeg: deg);

  double edgeDistanceM(double lat, double lng) {
    var best = double.infinity;
    for (final p in polygons) {
      final d = p.edgeDistanceM(lat, lng);
      if (d < best) best = d;
    }
    return best;
  }
}
