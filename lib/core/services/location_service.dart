import 'dart:async';

import 'package:geolocator/geolocator.dart';

import 'package:hena_masr/core/error/failures.dart';
import 'package:hena_masr/core/utils/logger.dart';
import 'package:hena_masr/core/utils/result.dart';

/// Thin wrapper over geolocator that never throws: always returns a [Result].
class LocationService {
  const LocationService();

  Future<Result<Position>> getCurrentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const Err<Position>(
          LocationFailure(LocationIssue.serviceDisabled),
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        return const Err<Position>(
          LocationFailure(LocationIssue.permissionDenied),
        );
      }
      if (permission == LocationPermission.deniedForever) {
        return const Err<Position>(
          LocationFailure(LocationIssue.permissionDeniedForever),
        );
      }

      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 12),
          ),
        );
        return Success<Position>(pos);
      } on TimeoutException {
        // Weak GPS (indoors / old phone): fall back to the last known fix.
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) return Success<Position>(last);
        return const Err<Position>(LocationFailure(LocationIssue.timeout));
      }
    } catch (e, st) {
      AppLogger.warning('Location error: $e', e, st);
      return const Err<Position>(LocationFailure(LocationIssue.unknown));
    }
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}
