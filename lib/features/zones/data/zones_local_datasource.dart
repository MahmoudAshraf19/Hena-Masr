import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart' show rootBundle;

import 'package:hena_masr/features/zones/domain/entities/geo_shape.dart';
import 'package:hena_masr/features/zones/domain/entities/zone.dart';

/// Loads the offline zone data bundled in assets (works with no internet).
final class ZonesLocalDataSource {
  static const String coreAsset = 'assets/data/egypt_zones.json';
  static const String localitiesAsset = 'assets/data/egypt_localities.json';

  /// 27 governorates + 403 districts + destinations + neighbour mask (~2.3 MB).
  Future<ZoneCatalog> loadCatalog() async {
    final raw = await rootBundle.loadString(coreAsset);
    return compute(parseZoneCatalog, raw); // parsed off the UI thread
  }

  /// Urban neighbourhoods pack (~0.7 MB). Load lazily, only when needed.
  Future<List<Locality>> loadLocalities() async {
    final raw = await rootBundle.loadString(localitiesAsset);
    return compute(parseLocalities, raw);
  }
}

// --- top-level so they can run in an isolate and be used directly in tests ---

GeoShape _shape(List<dynamic> polygons) => GeoShape([
      for (final p in polygons)
        GeoPolygon(
          _ring((p as List)[0] as List),
          [for (var i = 1; i < p.length; i++) _ring(p[i] as List)],
        ),
    ]);

Float64List _ring(List<dynamic> r) {
  final out = Float64List(r.length);
  for (var i = 0; i < r.length; i++) {
    out[i] = (r[i] as num).toDouble();
  }
  return out;
}

DistrictKind _kind(String k) => switch (k) {
      'qism' => DistrictKind.qism,
      'markaz' => DistrictKind.markaz,
      'new_city' => DistrictKind.newCity,
      'outside_zemam' => DistrictKind.outsideZemam,
      'port' => DistrictKind.port,
      _ => DistrictKind.region,
    };

ZoneCatalog parseZoneCatalog(String raw) {
  final json = jsonDecode(raw) as Map<String, dynamic>;

  final governorates = [
    for (final e in json['governorates'] as List)
      Governorate(
        code: e['code'] as String,
        id: e['id'] as String,
        iso: e['iso'] as String,
        nameAr: e['ar'] as String,
        nameEn: e['en'] as String,
        lat: (e['lat'] as num).toDouble(),
        lng: (e['lng'] as num).toDouble(),
        areaKm2: (e['area_km2'] as num).toDouble(),
        shape: _shape(e['polygons'] as List),
      ),
  ];

  final districts = [
    for (final e in json['districts'] as List)
      District(
        id: e['id'] as String,
        governorateCode: e['gov'] as String,
        kind: _kind(e['kind'] as String),
        nameAr: e['ar'] as String,
        nameArFull: e['ar_full'] as String,
        nameEn: e['en'] as String,
        labelEn: e['label_en'] as String,
        lat: (e['lat'] as num).toDouble(),
        lng: (e['lng'] as num).toDouble(),
        geometry: switch (e['geometry'] as String) {
          'polygon' => DistrictGeometry.polygon,
          'approx_circle' => DistrictGeometry.approxCircle,
          _ => DistrictGeometry.point,
        },
        areaKm2: (e['area_km2'] as num?)?.toDouble(),
        shape: e['polygons'] == null ? null : _shape(e['polygons'] as List),
        radiusM: (e['radius_m'] as num?)?.toDouble(),
        splitInto: [
          for (final c in (e['split_into'] as List? ?? const []))
            (
              id: c['id'] as String,
              nameAr: c['ar'] as String,
              nameEn: c['en'] as String,
            ),
        ],
      ),
  ];

  final highlights = [
    for (final e in json['highlights'] as List)
      Highlight(
        id: e['id'] as String,
        governorateCode: e['gov'] as String,
        nameAr: e['ar'] as String,
        nameEn: e['en'] as String,
        lat: (e['lat'] as num).toDouble(),
        lng: (e['lng'] as num).toDouble(),
        radiusM: (e['radius_m'] as num).toDouble(),
        priority: (e['priority'] as num).toInt(),
        districtId: e['district'] as String?,
      ),
  ];

  final neighbors = [
    for (final n in json['neighbors'] as List) _shape(n['polygons'] as List),
  ];

  return ZoneCatalog(
    governorates: governorates,
    districts: districts,
    highlights: highlights,
    neighbors: neighbors,
  );
}

List<Locality> parseLocalities(String raw) {
  final json = jsonDecode(raw) as Map<String, dynamic>;
  return [
    for (final e in json['localities'] as List)
      Locality(
        id: e['id'] as String,
        districtId: e['district'] as String,
        governorateCode: e['gov'] as String,
        nameAr: e['ar'] as String,
        nameEn: e['en'] as String,
        shape: _shape(e['polygons'] as List),
      ),
  ];
}
