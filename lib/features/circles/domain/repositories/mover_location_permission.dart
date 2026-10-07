import '../entities/location_permission_result.dart';

abstract class MoverLocationPermission {
  Future<LocationPermissionResult> requestForeground();
  Future<void> openSettings();
}
