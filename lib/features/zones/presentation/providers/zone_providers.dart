import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'package:hena_masr/core/constants/storage_keys.dart';
import 'package:hena_masr/core/di/providers.dart';
import 'package:hena_masr/core/error/failures.dart';
import 'package:hena_masr/core/services/location_service.dart';
import 'package:hena_masr/features/zones/data/zones_local_datasource.dart';
import 'package:hena_masr/features/zones/domain/entities/zone.dart';
import 'package:hena_masr/features/zones/domain/services/locality_index.dart';
import 'package:hena_masr/features/zones/domain/services/zone_resolver.dart';

final locationServiceProvider = Provider<LocationService>(
  (ref) => const LocationService(),
);

/// Offline catalog (27 governorates + 403 districts + destinations), loaded once.
final zoneCatalogProvider = FutureProvider<ZoneCatalog>(
  (ref) => ZonesLocalDataSource().loadCatalog(),
);

/// Neighbourhood pack (level 3). Loaded lazily the first time it is needed.
final localityIndexProvider = FutureProvider<LocalityIndex>(
  (ref) async => LocalityIndex(await ZonesLocalDataSource().loadLocalities()),
);

enum ZoneStatus { detecting, ready, outsideEgypt, locationIssue }

final class ZoneState {
  const ZoneState({
    required this.status,
    this.match,
    this.source = ZoneSource.gps,
    this.issue,
    this.rawPosition,
  });

  final ZoneStatus status;
  final ZoneMatch? match;
  final ZoneSource source;
  final LocationIssue? issue;
  final Position? rawPosition;

  /// UI should show a "Are you in …? / change" prompt.
  bool get shouldConfirm =>
      status == ZoneStatus.ready &&
      source == ZoneSource.gps &&
      (match?.needsConfirmation ?? false);
}

/// Current zone of the user.
///
/// * A manual choice (persisted) always wins over GPS.
/// * Otherwise: shows the last cached zone instantly, then refreshes from GPS.
/// * Call [CurrentZoneController.detect] on app resume / pull-to-refresh.
final currentZoneProvider =
    AsyncNotifierProvider<CurrentZoneController, ZoneState>(
  CurrentZoneController.new,
);

class CurrentZoneController extends AsyncNotifier<ZoneState> {
  ZoneResolver? _resolver;

  @override
  Future<ZoneState> build() async {
    final catalog = await ref.watch(zoneCatalogProvider.future);
    final resolver = _resolver = ZoneResolver(catalog);
    final prefs = ref.read(sharedPreferencesProvider);

    final mode = prefs.getString(StorageKeys.zoneMode);
    final savedId = prefs.getString(StorageKeys.zoneId);
    final saved = savedId == null ? null : resolver.matchFromId(savedId);

    if (mode == 'manual' && saved != null) {
      return ZoneState(
        status: ZoneStatus.ready,
        match: saved,
        source: ZoneSource.manual,
      );
    }

    // Auto mode: refresh from GPS right after the first state is published.
    Timer.run(detect);
    return ZoneState(
      status: saved != null ? ZoneStatus.ready : ZoneStatus.detecting,
      match: saved,
      source: ZoneSource.cached,
    );
  }

  /// Re-detect the zone from the device location (no-op in manual mode).
  Future<void> detect() async {
    final current = state.value;
    if (current?.source == ZoneSource.manual) return;
    final resolver = _resolver;
    if (resolver == null) return;

    state = AsyncData(ZoneState(
      status: ZoneStatus.detecting,
      match: current?.match,
      source: current?.source ?? ZoneSource.gps,
    ));

    final result = await ref.read(locationServiceProvider).getCurrentPosition();
    await result.when(
      onSuccess: (pos) async {
        var match = resolver.resolve(
          lat: pos.latitude,
          lng: pos.longitude,
          accuracyM: pos.accuracy,
          previous: current?.match,
        );
        if (match == null) {
          state = AsyncData(ZoneState(
            status: ZoneStatus.outsideEgypt,
            match: current?.match,
          ));
          return;
        }
        if (match.district != null) {
          match = await _withLocality(match, pos.latitude, pos.longitude);
        }
        final prefs = ref.read(sharedPreferencesProvider);
        await prefs.setString(StorageKeys.zoneMode, 'auto');
        await prefs.setString(StorageKeys.zoneId, match.zoneId);
        state = AsyncData(ZoneState(
          status: ZoneStatus.ready,
          match: match,
          source: ZoneSource.gps,
          rawPosition: pos,
        ));
      },
      onFailure: (failure) async {
        state = AsyncData(ZoneState(
          status: ZoneStatus.locationIssue,
          match: current?.match,
          source: current?.source ?? ZoneSource.gps,
          issue:
              failure is LocationFailure ? failure.issue : LocationIssue.unknown,
        ));
      },
    );
  }

  Future<ZoneMatch> _withLocality(ZoneMatch m, double lat, double lng) async {
    try {
      final index = await ref.read(localityIndexProvider.future);
      final loc = index.find(m.district!.id, lat, lng);
      return loc == null ? m : m.copyWith(locality: loc);
    } catch (_) {
      return m; // the neighbourhood pack is optional — never break detection
    }
  }

  /// User picked a zone manually (governorate code like EG01, or district id).
  Future<void> selectManually(String zoneId) async {
    final match = _resolver?.matchFromId(zoneId);
    if (match == null) return;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(StorageKeys.zoneMode, 'manual');
    await prefs.setString(StorageKeys.zoneId, match.zoneId);
    state = AsyncData(ZoneState(
      status: ZoneStatus.ready,
      match: match,
      source: ZoneSource.manual,
    ));
  }

  /// Go back to automatic GPS detection.
  Future<void> useAutomatic() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(StorageKeys.zoneMode, 'auto');
    state = AsyncData(ZoneState(
      status: ZoneStatus.detecting,
      match: state.value?.match,
      source: ZoneSource.cached,
    ));
    await detect();
  }
}
