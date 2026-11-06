import 'package:hena_masr/features/zones/domain/entities/zone.dart';

/// Finds the neighbourhood (level 3) inside an already-resolved district.
final class LocalityIndex {
  LocalityIndex(List<Locality> all) {
    for (final l in all) {
      (_byDistrict[l.districtId] ??= <Locality>[]).add(l);
    }
  }

  final Map<String, List<Locality>> _byDistrict = {};

  Locality? find(String districtId, double lat, double lng) {
    final list = _byDistrict[districtId];
    if (list == null) return null;
    for (final l in list) {
      if (l.shape.contains(lat, lng)) return l;
    }
    return null;
  }

  List<Locality> of(String districtId) => _byDistrict[districtId] ?? const [];
}
