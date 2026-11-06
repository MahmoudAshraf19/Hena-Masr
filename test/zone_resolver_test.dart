import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:hena_masr/features/zones/data/zones_local_datasource.dart';
import 'package:hena_masr/features/zones/domain/entities/zone.dart';
import 'package:hena_masr/features/zones/domain/services/zone_resolver.dart';

// Run from the project root:  flutter test test/zone_resolver_test.dart
void main() {
  late ZoneCatalog catalog;
  late ZoneResolver resolver;

  setUpAll(() {
    catalog = parseZoneCatalog(
      File('assets/data/egypt_zones.json').readAsStringSync(),
    );
    resolver = ZoneResolver(catalog);
  });

  ZoneMatch? at(double lat, double lng, {double acc = 15}) =>
      resolver.resolve(lat: lat, lng: lng, accuracyM: acc);

  group('catalog', () {
    test('27 governorates, unique codes', () {
      expect(catalog.governorates.length, 27);
      expect(catalog.governorates.map((g) => g.code).toSet().length, 27);
    });
    test('every district references an existing governorate', () {
      for (final d in catalog.districts) {
        expect(catalog.governorate(d.governorateCode), isNotNull, reason: d.id);
      }
    });
    test('365 polygon districts', () {
      expect(catalog.polygonDistricts.length, 365);
    });
  });

  test('every polygon district representative point resolves to itself', () {
    for (final d in catalog.polygonDistricts) {
      final m = at(d.lat, d.lng, acc: 10);
      expect(m, isNotNull, reason: d.id);
      if (d.kind == DistrictKind.outsideZemam) {
        expect(m!.governorate.code, d.governorateCode, reason: d.id);
      } else {
        expect(m!.district?.id, d.id, reason: '${d.id} ${d.nameEn}');
      }
    }
  });

  group('governorate of real landmarks', () {
    const cases = <(String, double, double, String)>[
    ('Tahrir Sq', 30.0444, 31.2357, 'EG01'),
    ('Egyptian Museum', 30.0478, 31.2336, 'EG01'),
    ('Cairo Citadel', 30.0287, 31.2599, 'EG01'),
    ('Maadi', 29.9602, 31.2569, 'EG01'),
    ('Heliopolis Baron Palace', 30.0869, 31.3281, 'EG01'),
    ('Nasr City', 30.0626, 31.3459, 'EG01'),
    ('New Cairo', 30.03, 31.47, 'EG01'),
    ('El Shorouk', 30.125, 31.61, 'EG01'),
    ('New Admin Capital', 30.0337, 31.7551, 'EG01'),
    ('Helwan', 29.8478, 31.3342, 'EG01'),
    ('Giza Pyramids', 29.9792, 31.1342, 'EG21'),
    ('Grand Egyptian Museum', 29.9942, 31.119, 'EG21'),
    ('Cairo University', 30.0261, 31.2085, 'EG21'),
    ('Mohandessin', 30.057, 31.2, 'EG21'),
    ('Sheikh Zayed City', 30.0131, 30.98, 'EG21'),
    ('6th of October City', 29.9285, 30.9188, 'EG21'),
    ('Saqqara', 29.8713, 31.2166, 'EG21'),
    ('Dahshur', 29.8089, 31.2089, 'EG21'),
    ('Bahariya Bawiti', 28.348, 28.868, 'EG21'),
    ('Shubra El Kheima', 30.1286, 31.2429, 'EG14'),
    ('Banha', 30.4658, 31.1848, 'EG14'),
    ('Obour City', 30.2272, 31.478, 'EG14'),
    ('Alexandria Qaitbay', 31.2133, 29.8853, 'EG02'),
    ('Bibliotheca Alexandrina', 31.2089, 29.9092, 'EG02'),
    ('Montaza Palace', 31.2885, 30.016, 'EG02'),
    ('Borg El Arab', 30.845, 29.605, 'EG02'),
    ('Karnak', 25.7188, 32.6573, 'EG29'),
    ('Luxor Temple', 25.6995, 32.639, 'EG29'),
    ('Valley of the Kings', 25.7402, 32.6014, 'EG29'),
    ('Hatshepsut Temple', 25.7381, 32.6065, 'EG29'),
    ('Esna', 25.2936, 32.5551, 'EG29'),
    ('Aswan city', 24.0889, 32.8998, 'EG28'),
    ('Philae', 24.0256, 32.8845, 'EG28'),
    ('Abu Simbel', 22.3372, 31.6258, 'EG28'),
    ('Kom Ombo', 24.4524, 32.9283, 'EG28'),
    ('Edfu', 24.978, 32.8737, 'EG28'),
    ('Hurghada', 27.2579, 33.8116, 'EG31'),
    ('El Gouna', 27.3946, 33.678, 'EG31'),
    ('Marsa Alam', 25.0676, 34.8789, 'EG31'),
    ('Safaga', 26.749, 33.937, 'EG31'),
    ('Sharm El Sheikh', 27.9158, 34.33, 'EG35'),
    ('Dahab', 28.509, 34.513, 'EG35'),
    ('Saint Catherine', 28.556, 33.976, 'EG35'),
    ('Taba', 29.4925, 34.8944, 'EG35'),
    ('Nuweiba', 29.03, 34.66, 'EG35'),
    ('Siwa', 29.2032, 25.5195, 'EG33'),
    ('Marsa Matrouh', 31.3543, 27.2373, 'EG33'),
    ('El Alamein', 30.83, 28.954, 'EG33'),
    ('Kharga', 25.439, 30.5586, 'EG32'),
    ('Dakhla Mut', 25.49, 29.0, 'EG32'),
    ('Farafra', 27.058, 27.97, 'EG32'),
    ('Fayoum city', 29.3084, 30.8428, 'EG23'),
    ('Wadi El Rayan', 29.261, 30.428, 'EG23'),
    ('Wadi El Hitan', 29.27, 30.05, 'EG23'),
    ('Minya', 28.1099, 30.7503, 'EG24'),
    ('Tell el-Amarna', 27.645, 30.9, 'EG24'),
    ('Beni Suef', 29.0661, 31.097, 'EG22'),
    ('Assiut', 27.1809, 31.1837, 'EG25'),
    ('Sohag', 26.5591, 31.6948, 'EG26'),
    ('Abydos', 26.185, 31.919, 'EG26'),
    ('Qena', 26.1551, 32.716, 'EG27'),
    ('Dendera', 26.1417, 32.67, 'EG27'),
    ('Mansoura', 31.0409, 31.3785, 'EG12'),
    ('Tanta', 30.7865, 31.0004, 'EG16'),
    ('Damanhur', 31.0341, 30.4682, 'EG18'),
    ('Zagazig', 30.5852, 31.5039, 'EG13'),
    ('Shebin El Kom', 30.5595, 31.009, 'EG17'),
    ('Kafr El Sheikh', 31.1107, 30.9388, 'EG15'),
    ('Damietta', 31.4165, 31.8133, 'EG11'),
    ('Ras El Bar', 31.516, 31.824, 'EG11'),
    ('Ismailia', 30.5965, 32.2715, 'EG19'),
    ('Port Said', 31.2653, 32.3019, 'EG03'),
    ('Suez', 29.9668, 32.5498, 'EG04'),
    ('Ain Sokhna', 29.6, 32.32, 'EG04'),
    ('El Arish', 31.1316, 33.7984, 'EG34'),
    ('Rosetta', 31.404, 30.417, 'EG18'),
    ('Wadi Natrun', 30.4, 30.3, 'EG18'),
    ('Sadat City', 30.3639, 30.5273, 'EG17'),
    ('10th of Ramadan', 30.2917, 31.7417, 'EG13'),
    ];
    for (final c in cases) {
      test(c.$1, () => expect(at(c.$2, c.$3)?.governorate.code, c.$4));
    }
  });

  group('district of real landmarks (confident subset)', () {
    const cases = <(String, double, double, Set<String>)>[
    ('Tahrir Sq', 30.0444, 31.2357, {'El Zamalek', 'Qasr El Nil'}),
    ('Zamalek', 30.0626, 31.2197, {'Zamalek'}),
    ('Maadi', 29.9602, 31.2569, {'Maadi'}),
    ('Heliopolis Baron Palace', 30.0869, 31.3281, {'Heliopolis'}),
    ('Hanging Church Old Cairo', 30.005, 31.23, {'Old Cairo'}),
    ('Khan el-Khalili', 30.0477, 31.2625, {'El Darb El Ahmar', 'El Gamaleya'}),
    ('Garden City', 30.036, 31.23, {'Qasr El Nil'}),
    ('Montaza Palace', 31.2885, 30.016, {'Montaza'}),
    ('Port Fouad', 31.2493, 32.3133, {'Port Fouad 1', 'Port Fouad 2'}),
    ('Helwan', 29.8478, 31.3342, {'Helwan'}),
    ('Imbaba', 30.075, 31.208, {'Imbaba'}),
    ('Dokki', 30.038, 31.212, {'Dokki', 'El Dokki'}),
    ('Sheikh Zayed City', 30.0131, 30.98, {'El Sheikh Zayed', 'Sheikh Zayed'}),
    ('Nasr City', 30.0626, 31.3459, {'Nasr City 1', 'Nasr City 2'}),
    ];
    for (final c in cases) {
      test(c.$1, () => expect(c.$4, contains(at(c.$2, c.$3)?.district?.nameEn)));
    }
  });

  group('outside Egypt / open sea', () {
    const cases = <(String, double, double)>[
    ('Jerusalem', 31.7683, 35.2137),
    ('Eilat (Israel)', 29.5577, 34.9519),
    ('Aqaba (Jordan)', 29.5267, 35.0078),
    ('Haql (Saudi)', 29.2878, 34.9418),
    ('Gaza City', 31.5017, 34.4668),
    ('Tel Aviv', 32.0853, 34.7818),
    ('Amman', 31.9454, 35.9284),
    ('Tabuk (Saudi)', 28.3835, 36.5662),
    ('Riyadh', 24.7136, 46.6753),
    ('Wadi Halfa (Sudan)', 21.797, 31.36),
    ('Port Sudan', 19.6158, 37.2164),
    ('Khartoum', 15.5007, 32.5599),
    ('Tobruk (Libya)', 32.0836, 23.9764),
    ('Jaghbub (Libya)', 29.7456, 24.5242),
    ('Benghazi', 32.1167, 20.0667),
    ('Cyprus Nicosia', 35.1856, 33.3823),
    ('Athens', 37.9838, 23.7275),
    ('Mid-Mediterranean 100km N', 33.0, 30.0),
    ('Mid Red Sea', 24.0, 36.8),
    ('Gulf of Aqaba, mid-gulf off Eilat', 29.4, 34.99),
    ];
    for (final c in cases) {
      test(c.$1, () => expect(at(c.$2, c.$3), isNull));
    }
  });

  test('hysteresis keeps a destination just outside its circle', () {
    final inside = at(29.9792, 31.1342, acc: 10)!;
    final edge = resolver.resolve(
      lat: 30.0070, lng: 31.1342, accuracyM: 10, previous: inside)!;
    expect(edge.highlight?.id, inside.highlight?.id);
  });

  test('sea point 3 km off Alexandria: approximate, never high confidence', () {
    final m = at(31.3000, 29.9000, acc: 10)!;
    expect(m.governorate.code, 'EG02');
    expect(m.approximate, isTrue);
    expect(m.confidence, isNot(ZoneConfidence.high));
  });

  test('poor GPS accuracy lowers confidence', () {
    expect(at(30.7865, 31.0004, acc: 5000)!.needsConfirmation, isTrue);
  });

  test('Valley of the Kings: highlight governorate overrides boundary error', () {
    final m = at(25.7402, 32.6014)!;
    expect(m.governorate.code, 'EG29'); // Luxor
    expect(m.highlight?.id, 'luxor_west');
  });
}
