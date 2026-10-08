import 'entities/device_location.dart';
import 'entities/geo_point.dart';
import 'location_distance.dart';

class LocationSamplingPolicy {
  const LocationSamplingPolicy({
    this.distance = const LocationDistance(),
  });

  final LocationDistance distance;

  Duration uploadInterval({
    required DeviceLocation current,
    required DeviceLocation? previous,
    required GeoPoint? destination,
  }) {
    if (destination != null &&
        distance.metersBetween(
              current,
              DeviceLocation(
                latitude: destination.latitude,
                longitude: destination.longitude,
                accuracyMeters: 0,
                capturedAt: current.capturedAt,
              ),
            ) <=
            500) {
      return const Duration(seconds: 8);
    }
    if (previous == null) return const Duration(seconds: 12);
    final seconds = current.capturedAt.difference(previous.capturedAt).inMilliseconds / 1000;
    if (seconds <= 0) return const Duration(seconds: 12);
    final speed = distance.metersBetween(previous, current) / seconds;
    return speed >= 0.8
        ? const Duration(seconds: 12)
        : const Duration(minutes: 2);
  }
}
