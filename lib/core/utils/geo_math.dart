import 'dart:math' as math;
import 'dart:typed_data';

/// Pure geometry helpers (no Flutter dependency, fully unit-testable).
/// Rings are flat arrays: [lat0, lng0, lat1, lng1, ...].
abstract final class GeoMath {
  static const double _earthRadiusM = 6371000.0;

  static double _rad(double deg) => deg * math.pi / 180.0;

  /// Great-circle distance in meters.
  static double haversineM(double lat1, double lng1, double lat2, double lng2) {
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.pow(math.sin(dLng / 2), 2);
    return 2 * _earthRadiusM * math.asin(math.sqrt(a.toDouble()));
  }

  /// Ray-casting point-in-polygon.
  static bool pointInRing(double lat, double lng, Float64List ring) {
    var inside = false;
    final n = ring.length ~/ 2;
    for (var i = 0, j = n - 1; i < n; j = i++) {
      final yi = ring[2 * i], xi = ring[2 * i + 1];
      final yj = ring[2 * j], xj = ring[2 * j + 1];
      final crosses = (xi > lng) != (xj > lng) &&
          lat < (yj - yi) * (lng - xi) / (xj - xi) + yi;
      if (crosses) inside = !inside;
    }
    return inside;
  }

  /// Distance in meters from a point to the nearest edge of a ring
  /// (local equirectangular projection — accurate at Egypt's scale).
  static double distanceToRingM(double lat, double lng, Float64List ring) {
    final kx = 111320.0 * math.cos(_rad(lat));
    const ky = 110574.0;
    final n = ring.length ~/ 2;
    var best = double.infinity;
    for (var i = 0; i < n; i++) {
      final j = (i + 1) % n;
      final ax = (ring[2 * i + 1] - lng) * kx;
      final ay = (ring[2 * i] - lat) * ky;
      final bx = (ring[2 * j + 1] - lng) * kx;
      final by = (ring[2 * j] - lat) * ky;
      final dx = bx - ax, dy = by - ay;
      final l2 = dx * dx + dy * dy;
      final t = l2 == 0 ? 0.0 : (-(ax * dx + ay * dy) / l2).clamp(0.0, 1.0);
      final px = ax + t * dx, py = ay + t * dy;
      final d = math.sqrt(px * px + py * py);
      if (d < best) best = d;
    }
    return best;
  }
}

/// Axis-aligned bounding box used as a cheap pre-filter.
final class GeoBounds {
  const GeoBounds(this.minLat, this.maxLat, this.minLng, this.maxLng);

  factory GeoBounds.ofRing(Float64List ring) {
    var minLat = double.infinity, maxLat = -double.infinity;
    var minLng = double.infinity, maxLng = -double.infinity;
    for (var i = 0; i < ring.length; i += 2) {
      final la = ring[i], ln = ring[i + 1];
      if (la < minLat) minLat = la;
      if (la > maxLat) maxLat = la;
      if (ln < minLng) minLng = ln;
      if (ln > maxLng) maxLng = ln;
    }
    return GeoBounds(minLat, maxLat, minLng, maxLng);
  }

  factory GeoBounds.union(Iterable<GeoBounds> all) {
    var minLat = double.infinity, maxLat = -double.infinity;
    var minLng = double.infinity, maxLng = -double.infinity;
    for (final b in all) {
      if (b.minLat < minLat) minLat = b.minLat;
      if (b.maxLat > maxLat) maxLat = b.maxLat;
      if (b.minLng < minLng) minLng = b.minLng;
      if (b.maxLng > maxLng) maxLng = b.maxLng;
    }
    return GeoBounds(minLat, maxLat, minLng, maxLng);
  }

  final double minLat, maxLat, minLng, maxLng;

  bool contains(double lat, double lng, {double marginDeg = 0}) =>
      lat >= minLat - marginDeg &&
      lat <= maxLat + marginDeg &&
      lng >= minLng - marginDeg &&
      lng <= maxLng + marginDeg;
}
