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
    debugPrint('📍 [LocationService] Starting location request (kIsWeb: $kIsWeb, timeout: ${timeLimit.inSeconds}s)...');
    try {
      // 1. Verify location services hardware (Android / iOS only)
      if (!kIsWeb) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        debugPrint('📍 [LocationService] Mobile hardware location service enabled: $serviceEnabled');
        if (!serviceEnabled) {
          debugPrint('⚠️ [LocationService] Hardware location service is DISABLED.');
          return const Err<Position>(
            LocationFailure(LocationIssue.serviceDisabled),
          );
        }
      }

      // 2. Cross-platform permission verification and escalation
      var permission = await Geolocator.checkPermission();
      debugPrint('📍 [LocationService] Initial permission status: $permission');
      if (permission == LocationPermission.denied) {
        debugPrint('📍 [LocationService] Requesting permission from user...');
        permission = await Geolocator.requestPermission();
        debugPrint('📍 [LocationService] User response permission status: $permission');
      }
      if (permission == LocationPermission.denied) {
        debugPrint('⚠️ [LocationService] Location permission DENIED by user.');
        return const Err<Position>(
          LocationFailure(LocationIssue.permissionDenied),
        );
      }
      if (permission == LocationPermission.deniedForever) {
        debugPrint('⚠️ [LocationService] Location permission DENIED FOREVER.');
        return const Err<Position>(
          LocationFailure(LocationIssue.permissionDeniedForever),
        );
      }

      // 3. Obtain location using platform-tailored settings
      try {
        final settings = _buildPlatformSettings(timeLimit: timeLimit);
        debugPrint('📍 [LocationService] Calling Geolocator.getCurrentPosition()...');
        final pos = await Geolocator.getCurrentPosition(locationSettings: settings);
        debugPrint('✅ [LocationService] Location acquired successfully! Lat: ${pos.latitude}, Lng: ${pos.longitude}, Acc: ±${pos.accuracy}m');
        return Success<Position>(pos);
      } on TimeoutException {
        debugPrint('⏱️ [LocationService] Primary fix timed out after ${timeLimit.inSeconds}s. Trying getLastKnownPosition()...');
        // Fallback for indoors, weak GPS or browser delays: check last known position
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          debugPrint('✅ [LocationService] Fallback to last known position succeeded! Lat: ${last.latitude}, Lng: ${last.longitude}');
          return Success<Position>(last);
        }
        // Web-specific resilience: fallback to low accuracy (IP/Wi-Fi database)
        if (kIsWeb) {
          try {
            debugPrint('🌐 [LocationService Web] Trying fast IP/Wi-Fi database low accuracy fix (4s)...');
            final webFallback = await Geolocator.getCurrentPosition(
              locationSettings: WebSettings(
                accuracy: LocationAccuracy.low,
                maximumAge: const Duration(minutes: 10),
                timeLimit: const Duration(seconds: 4),
              ),
            );
            debugPrint('✅ [LocationService Web] Low-accuracy fallback succeeded! Lat: ${webFallback.latitude}, Lng: ${webFallback.longitude}');
            return Success<Position>(webFallback);
          } catch (e) {
            debugPrint('⚠️ [LocationService Web] Low-accuracy fallback also failed: $e');
          }
        }
        debugPrint('❌ [LocationService] All location acquisition attempts timed out.');
        return const Err<Position>(LocationFailure(LocationIssue.timeout));
      }
    } catch (e, st) {
      debugPrint('❌ [LocationService] Unexpected exception: $e');
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
