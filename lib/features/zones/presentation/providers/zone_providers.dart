import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hena_masr/core/constants/storage_keys.dart';
import 'package:hena_masr/core/di/providers.dart';
import 'package:hena_masr/core/error/failures.dart';
import 'package:hena_masr/core/services/location_service.dart';
import 'package:hena_masr/features/zones/data/zones_local_datasource.dart';
import 'package:hena_masr/features/zones/domain/entities/zone.dart';
import 'package:hena_masr/features/zones/domain/services/zone_resolver.dart';

final locationServiceProvider = Provider<LocationService>(
  (ref) => const LocationService(),
);

/// Offline catalog (27 governorates + curated areas), loaded once.
final zoneCatalogProvider = FutureProvider<ZoneCatalog>(
  (ref) => ZonesLocalDataSource().load(),
);

enum ZoneStatus { detecting, ready, outsideEgypt, locationIssue }

final class ZoneState {
  const ZoneState({
    required this.status,
    this.match,
    this.source = ZoneSource.gps,
    this.issue,
  });

  final ZoneStatus status;
  final ZoneMatch? match;
  final ZoneSource source;
  final LocationIssue? issue;

  /// UI should show a "Is this where you are? / change" prompt.
  bool get shouldConfirm =>
      status == ZoneStatus.ready &&
      source == ZoneSource.gps &&
      (match?.needsConfirmation ?? false);
}

/// Current zone of the user.
///
/// * Manual choice (persisted) always wins over GPS.
/// * Otherwise: shows the last cached zone instantly, then refreshes from GPS.
/// * Call [detect] on app resume / pull-to-refresh to re-check.
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
    final current = state.valueOrNull;
    if (current?.source == ZoneSource.manual) return;
    final resolver = _resolver;
    if (resolver == null) return;

    state = AsyncData(ZoneState(
      status: ZoneStatus.detecting,
      match: current?.match,
      source: current?.source ?? ZoneSource.gps,
    ));

    final result = await ref.read(locationServiceProvider).getCurrentPosition();
    result.when(
      onSuccess: (pos) {
        final match = resolver.resolve(
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
        final prefs = ref.read(sharedPreferencesProvider);
        prefs.setString(StorageKeys.zoneMode, 'auto');
        prefs.setString(StorageKeys.zoneId, match.primaryId);
        state = AsyncData(ZoneState(
          status: ZoneStatus.ready,
          match: match,
          source: ZoneSource.gps,
        ));
      },
      onFailure: (failure) {
        state = AsyncData(ZoneState(
          status: ZoneStatus.locationIssue,
          match: current?.match,
          source: current?.source ?? ZoneSource.gps,
          issue: failure is LocationFailure ? failure.issue : LocationIssue.unknown,
        ));
      },
    );
  }

  /// User picked a zone manually (governorate id or area id).
  Future<void> selectManually(String zoneId) async {
    final match = _resolver?.matchFromId(zoneId);
    if (match == null) return;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(StorageKeys.zoneMode, 'manual');
    await prefs.setString(StorageKeys.zoneId, match.primaryId);
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
      match: state.valueOrNull?.match,
      source: ZoneSource.cached,
    ));
    await detect();
  }
}
