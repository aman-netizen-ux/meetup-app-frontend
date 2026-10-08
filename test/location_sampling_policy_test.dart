import 'package:flutter_test/flutter_test.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/device_location.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/geo_point.dart';
import 'package:meetup_app_frontend/features/circles/domain/location_sampling_policy.dart';

void main() {
  const policy = LocationSamplingPolicy();
  final start = DeviceLocation(
    latitude: 12.9700,
    longitude: 77.5900,
    accuracyMeters: 10,
    capturedAt: DateTime.utc(2026, 10, 8, 10),
  );

  test('uses frequent updates while moving and near destination', () {
    final moving = DeviceLocation(
      latitude: 12.9702,
      longitude: 77.5900,
      accuracyMeters: 10,
      capturedAt: start.capturedAt.add(const Duration(seconds: 12)),
    );
    expect(
      policy.uploadInterval(
        current: moving,
        previous: start,
        destination: const GeoPoint(latitude: 13.1, longitude: 77.7),
      ),
      const Duration(seconds: 12),
    );
    expect(
      policy.uploadInterval(
        current: moving,
        previous: start,
        destination: const GeoPoint(latitude: 12.9703, longitude: 77.5900),
      ),
      const Duration(seconds: 8),
    );
  });

  test('backs off when GPS movement is effectively stationary', () {
    final stationary = DeviceLocation(
      latitude: 12.970001,
      longitude: 77.590001,
      accuracyMeters: 10,
      capturedAt: start.capturedAt.add(const Duration(seconds: 30)),
    );
    expect(
      policy.uploadInterval(
        current: stationary,
        previous: start,
        destination: const GeoPoint(latitude: 13.1, longitude: 77.7),
      ),
      const Duration(minutes: 2),
    );
  });
}
