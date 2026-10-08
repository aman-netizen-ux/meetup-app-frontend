import 'dart:async';

import 'package:meetup_app_frontend/features/circles/domain/entities/device_location.dart';
import 'package:meetup_app_frontend/features/circles/domain/repositories/device_location_tracker.dart';

class FakeDeviceLocationTracker implements DeviceLocationTracker {
  FakeDeviceLocationTracker(this.initial);

  final DeviceLocation initial;
  final StreamController<DeviceLocation> _positions =
      StreamController<DeviceLocation>.broadcast();

  void emit(DeviceLocation location) => _positions.add(location);
  void emitError(Object error) => _positions.addError(error);

  @override
  Future<DeviceLocation> current() async => initial;

  @override
  Stream<DeviceLocation> positions() => _positions.stream;

  Future<void> close() => _positions.close();
}
