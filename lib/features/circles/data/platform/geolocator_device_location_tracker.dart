import 'package:geolocator/geolocator.dart';

import '../../domain/entities/device_location.dart';
import '../../domain/repositories/device_location_tracker.dart';

class GeolocatorDeviceLocationTracker implements DeviceLocationTracker {
  const GeolocatorDeviceLocationTracker();

  @override
  Future<DeviceLocation> current() async => _map(
    await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    ),
  );

  @override
  Stream<DeviceLocation> positions() => Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 20,
    ),
  ).map(_map);

  DeviceLocation _map(Position position) => DeviceLocation(
    latitude: position.latitude,
    longitude: position.longitude,
    accuracyMeters: position.accuracy,
    capturedAt: position.timestamp,
  );
}
