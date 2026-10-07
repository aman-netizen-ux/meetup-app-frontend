import 'dart:math' as math;

import 'entities/device_location.dart';

class LocationDistance {
  const LocationDistance();

  double metersBetween(DeviceLocation first, DeviceLocation second) {
    const earthRadiusMeters = 6371000.0;
    final firstLatitude = _radians(first.latitude);
    final secondLatitude = _radians(second.latitude);
    final latitudeDelta = _radians(second.latitude - first.latitude);
    final longitudeDelta = _radians(second.longitude - first.longitude);
    final a = math.sin(latitudeDelta / 2) * math.sin(latitudeDelta / 2) +
        math.cos(firstLatitude) *
            math.cos(secondLatitude) *
            math.sin(longitudeDelta / 2) *
            math.sin(longitudeDelta / 2);
    return earthRadiusMeters * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _radians(double degrees) => degrees * math.pi / 180;
}
