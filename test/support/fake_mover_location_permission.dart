import 'package:meetup_app_frontend/features/circles/domain/entities/location_permission_result.dart';
import 'package:meetup_app_frontend/features/circles/domain/repositories/mover_location_permission.dart';

class FakeMoverLocationPermission implements MoverLocationPermission {
  FakeMoverLocationPermission(this.result);

  LocationPermissionResult result;
  int requests = 0;
  int settingsOpens = 0;

  @override
  Future<LocationPermissionResult> requestForeground() async {
    requests++;
    return result;
  }

  @override
  Future<void> openSettings() async {
    settingsOpens++;
  }
}
