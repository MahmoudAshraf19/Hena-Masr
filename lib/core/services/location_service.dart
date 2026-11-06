import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'package:hena_masr/core/error/failures.dart';
import 'package:hena_masr/core/utils/logger.dart';
import 'package:hena_masr/core/utils/result.dart';

/// Enterprise-grade, cross-platform location service (Android, iOS, Web).
/// Never throws: gracefully catches timeouts, permissions, and returns a [Result].
class LocationService {
  const LocationService();

  /// Gets current position with platform-optimized settings and fallback.
  Future<Result<Position>> getCurrentPosition({
    Duration timeLimit = const Duration(seconds: 9),
  }) async {
    try {
      // 1. Verify location services hardware (Android / iOS only)
      if (!kIsWeb) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          return const Err<Position>(
            LocationFailure(LocationIssue.serviceDisabled),
          );
        }
      }

      // 2. Cross-platform permission verification and escalation
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

      // 3. Obtain location using platform-tailored settings
      try {
        final settings = _buildPlatformSettings(timeLimit: timeLimit);
        final pos = await Geolocator.getCurrentPosition(locationSettings: settings);
        return Success<Position>(pos);
      } on TimeoutException {
        // Fallback for indoors, weak GPS or browser delays: check last known position
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          AppLogger.info('Location fix obtained from last known position fallback.');
          return Success<Position>(last);
        }
        // Web-specific resilience: fallback to low accuracy (IP/Wi-Fi database)
        if (kIsWeb) {
          try {
            final webFallback = await Geolocator.getCurrentPosition(
              locationSettings: const WebSettings(
                accuracy: LocationAccuracy.low,
                maximumAge: Duration(minutes: 10),
                timeLimit: Duration(seconds: 4),
              ),
            );
            return Success<Position>(webFallback);
          } catch (_) {}
        }
        return const Err<Position>(LocationFailure(LocationIssue.timeout));
      }
    } catch (e, st) {
      AppLogger.warning('Location detection error: $e', e, st);
      return const Err<Position>(LocationFailure(LocationIssue.unknown));
    }
  }

  /// Platform-tailored location parameters for Android, iOS, and Web.
  LocationSettings _buildPlatformSettings({required Duration timeLimit}) {
    if (kIsWeb) {
      return WebSettings(
        accuracy: LocationAccuracy.medium,
        maximumAge: const Duration(minutes: 5),
        timeLimit: timeLimit,
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidSettings(
          accuracy: LocationAccuracy.high,
          forceLocationManager: false,
          intervalDuration: const Duration(seconds: 5),
          timeLimit: timeLimit,
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return AppleSettings(
          accuracy: LocationAccuracy.high,
          activityType: ActivityType.other,
          pauseLocationUpdatesAutomatically: true,
          timeLimit: timeLimit,
        );
      default:
        return LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeLimit,
        );
    }
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}
