import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sooq/features/Address/data/services/map_failure.dart';

abstract interface class LocationService {
  /// Checks service + permission (asks if needed) and returns the position.
  Future<Either<MapFailure, LatLng>> getCurrentLocation();

  Future<void> openLocationSettings();

  Future<void> openAppSettings();
}

class GeolocatorLocationService implements LocationService {
  @override
  Future<Either<MapFailure, LatLng>> getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const Left(
          MapFailure(MapFailureType.locationServiceDisabled, 'Location services are turned off'),
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        return const Left(
          MapFailure(MapFailureType.permissionDenied, 'Location permission is required'),
        );
      }
      if (permission == LocationPermission.deniedForever) {
        return const Left(
          MapFailure(
            MapFailureType.permissionPermanentlyDenied,
            'Location permission is permanently denied',
          ),
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return Right(LatLng(position.latitude, position.longitude));
    } on TimeoutException {
      return const Left(MapFailure(MapFailureType.unknown, 'Could not get your location, try again'));
    } catch (_) {
      return const Left(MapFailure(MapFailureType.unknown, 'Could not get your location'));
    }
  }

  @override
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  @override
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
