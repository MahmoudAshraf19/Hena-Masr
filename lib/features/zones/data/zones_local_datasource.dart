import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart' show rootBundle;

import 'package:hena_masr/features/zones/domain/entities/zone.dart';

/// Loads the offline zone catalog bundled in assets (works with no internet).
final class ZonesLocalDataSource {
  static const String assetPath = 'assets/data/egypt_zones.json';

  Future<ZoneCatalog> load() async {
    final raw = await rootBundle.loadString(assetPath);
    return compute(parseZoneCatalog, raw); // parse off the UI thread
  }
}

/// Top-level so it can run in an isolate (and be used directly in tests).
ZoneCatalog parseZoneCatalog(String raw) {
  final json = jsonDecode(raw) as Map<String, dynamic>;

  final governorates = (json['governorates'] as List).map((e) {
    final m = e as Map<String, dynamic>;
    final rings = (m['polygons'] as List)
        .map((r) => Float64List.fromList(
              (r as List).map((v) => (v as num).toDouble()).toList(),
            ))
        .toList(growable: false);
    return Governorate(
      id: m['id'] as String,
      nameAr: m['ar'] as String,
      nameEn: m['en'] as String,
      rings: rings,
    );
  }).toList(growable: false);

  final areas = (json['areas'] as List).map((e) {
    final m = e as Map<String, dynamic>;
    return Area(
      id: m['id'] as String,
      governorateId: m['gov'] as String,
      nameAr: m['ar'] as String,
      nameEn: m['en'] as String,
      lat: (m['lat'] as num).toDouble(),
      lng: (m['lng'] as num).toDouble(),
      radiusM: (m['r'] as num).toDouble(),
      priority: (m['p'] as num).toInt(),
    );
  }).toList(growable: false);

  return ZoneCatalog(governorates: governorates, areas: areas);
}
