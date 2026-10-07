import 'package:geolocator/geolocator.dart';

import '../../domain/entities/location_permission_result.dart';
import '../../domain/repositories/mover_location_permission.dart';

class GeolocatorMoverLocationPermission implements MoverLocationPermission {
  const GeolocatorMoverLocationPermission();

  @override
  Future<LocationPermissionResult> requestForeground() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationPermissionResult.serviceDisabled;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return switch (permission) {
      LocationPermission.always ||
      LocationPermission.whileInUse => LocationPermissionResult.granted,
      LocationPermission.deniedForever =>
        LocationPermissionResult.permanentlyDenied,
      _ => LocationPermissionResult.denied,
    };
  }

  @override
  Future<void> openSettings() => Geolocator.openAppSettings();
}
