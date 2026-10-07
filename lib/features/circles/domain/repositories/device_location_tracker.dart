import '../entities/device_location.dart';

abstract class DeviceLocationTracker {
  Future<DeviceLocation> current();
  Stream<DeviceLocation> positions();
}
