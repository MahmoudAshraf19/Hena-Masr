import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:hena_masr/features/zones/data/zones_local_datasource.dart';
import 'package:hena_masr/features/zones/domain/services/zone_resolver.dart';

void main() {
  late ZoneResolver resolver;

  setUpAll(() {
    final raw = File('assets/data/egypt_zones.json').readAsStringSync();
    resolver = ZoneResolver(parseZoneCatalog(raw));
  });

  String? zone(double lat, double lng, {double acc = 20}) =>
      resolver.resolve(lat: lat, lng: lng, accuracyM: acc)?.primaryId;

  test('catalog has 27 governorates', () {
    expect(resolver.catalog.governorates.length, 27);
  });

  group('tourist areas (real coordinates)', () {
    final cases = <String, (double, double, String)>{
      'Tahrir Square': (30.0444, 31.2357, 'downtown_cairo'),
      'Giza Pyramids': (29.9792, 31.1342, 'giza_pyramids'),
      'Grand Egyptian Museum': (29.9942, 31.1190, 'gem'),
      'Citadel': (30.0287, 31.2599, 'citadel'),
      'Zamalek': (30.0626, 31.2197, 'zamalek'),
      'Karnak': (25.7188, 32.6573, 'luxor_east'),
      'Valley of the Kings': (25.7402, 32.6014, 'luxor_west'),
      'Sharm El Sheikh': (27.9158, 34.3300, 'sharm'),
      'Hurghada': (27.2579, 33.8116, 'hurghada'),
      'Qaitbay Citadel': (31.2133, 29.8853, 'alex_qaitbay'),
      'Abu Simbel': (22.3372, 31.6258, 'abu_simbel'),
      'Siwa': (29.2032, 25.5195, 'siwa'),
      'Aswan': (24.0889, 32.8998, 'aswan_city'),
      'Dahab': (28.5090, 34.5130, 'dahab'),
      'Marsa Alam': (25.0676, 34.8789, 'marsa_alam'),
    };
    cases.forEach((name, c) {
      test(name, () => expect(zone(c.$1, c.$2), c.$3));
    });
  });

  group('governorate fallback', () {
    test('Tanta -> Gharbia', () => expect(zone(30.7865, 31.0004), 'gov_gharbia'));
    test('Mansoura -> Dakahlia', () => expect(zone(31.0409, 31.3785), 'gov_dakahlia'));
    test('Zagazig -> Sharqia', () => expect(zone(30.5852, 31.5039), 'gov_sharqia'));
    test('Beni Suef', () => expect(zone(29.0661, 31.0970), 'gov_beni_suef'));
    test('Sohag', () => expect(zone(26.5591, 31.6948), 'gov_sohag'));
    test('Qena', () => expect(zone(26.1551, 32.7160), 'gov_qena'));
    test('Shubra El Kheima -> Qalyubia', () => expect(zone(30.1286, 31.2429), 'gov_qalyubia'));
    test('Banha -> Qalyubia', () => expect(zone(30.4658, 31.1848), 'gov_qalyubia'));
    test('Kafr El Sheikh', () => expect(zone(31.4, 31.0), 'gov_kafr_el_sheikh'));
  });

  group('outside Egypt', () {
    test('Jerusalem', () => expect(zone(31.77, 35.21), isNull));
    test('Riyadh', () => expect(zone(24.7, 46.7), isNull));
    test('Khartoum', () => expect(zone(15.6, 32.5), isNull));
    test('Cyprus', () => expect(zone(35.0, 33.0), isNull));
  });

  test('priority: GEM wins over the Giza plateau circle', () {
    final m = resolver.resolve(lat: 29.9942, lng: 31.1190, accuracyM: 10)!;
    expect(m.area?.id, 'gem');
    expect(m.governorate.id, 'gov_giza');
  });

  test('hysteresis keeps the area just outside its edge', () {
    final inside = resolver.resolve(lat: 29.9792, lng: 31.1342, accuracyM: 10)!;
    // ~3.1 km north of the Pyramids center: just outside the 3 km circle.
    final edge = resolver.resolve(
      lat: 30.0070,
      lng: 31.1342,
      accuracyM: 10,
      previous: inside,
    )!;
    expect(edge.primaryId, inside.primaryId);
  });

  test('poor accuracy lowers confidence', () {
    final m = resolver.resolve(lat: 30.7865, lng: 31.0004, accuracyM: 5000)!;
    expect(m.needsConfirmation, isTrue);
  });
}
