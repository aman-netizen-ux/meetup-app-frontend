import 'package:flutter_test/flutter_test.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/device_location.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/location_permission_result.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/setup_status.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/sharing_trigger.dart';
import 'package:meetup_app_frontend/features/circles/presentation/state/location_sharing_controller.dart';
import 'package:meetup_app_frontend/features/circles/presentation/state/location_sharing_status.dart';

import 'support/circle_test_snapshot.dart';
import 'support/fake_circle_repository.dart';
import 'support/fake_device_location_tracker.dart';
import 'support/fake_mover_location_permission.dart';

void main() {
  test('starting point stays private until departure threshold', () async {
    final start = DeviceLocation(
      latitude: 12.9700,
      longitude: 77.5900,
      accuracyMeters: 10,
      capturedAt: DateTime.utc(2026, 10, 7, 10),
    );
    final tracker = FakeDeviceLocationTracker(start);
    final repository = FakeCircleRepository(
      circleTestSnapshot(setupStatus: SetupStatus.ready),
    );
    final controller = LocationSharingController(
      repository: repository,
      permission: FakeMoverLocationPermission(LocationPermissionResult.granted),
      tracker: tracker,
      circleId: 'circle-1',
      userId: 'user-1',
      onSnapshot: (_) {},
    );
    controller.sync(repository.snapshot);
    await controller.enable();
    expect(controller.value.status, LocationSharingStatus.monitoringDeparture);
    expect(repository.sharingStarts, 0);

    tracker.emit(DeviceLocation(
      latitude: 12.9705,
      longitude: 77.5900,
      accuracyMeters: 12,
      capturedAt: start.capturedAt.add(const Duration(seconds: 20)),
    ));
    await Future<void>.delayed(Duration.zero);
    expect(repository.sharingStarts, 0);

    tracker.emit(DeviceLocation(
      latitude: 12.9715,
      longitude: 77.5900,
      accuracyMeters: 12,
      capturedAt: start.capturedAt.add(const Duration(seconds: 40)),
    ));
    await Future<void>.delayed(Duration.zero);
    expect(repository.sharingStarts, 1);
    expect(repository.lastSharingTrigger, SharingTrigger.departure);

    controller.dispose();
    await tracker.close();
  });

  test('manual sharing publishes the current on-device point', () async {
    final start = DeviceLocation(
      latitude: 12.97,
      longitude: 77.59,
      accuracyMeters: 8,
      capturedAt: DateTime.utc(2026, 10, 7, 10),
    );
    final tracker = FakeDeviceLocationTracker(start);
    final repository = FakeCircleRepository(
      circleTestSnapshot(setupStatus: SetupStatus.ready),
    );
    final controller = LocationSharingController(
      repository: repository,
      permission: FakeMoverLocationPermission(LocationPermissionResult.granted),
      tracker: tracker,
      circleId: 'circle-1',
      userId: 'user-1',
      onSnapshot: (_) {},
    );
    controller.sync(repository.snapshot);
    await controller.enable();
    await controller.shareNow();

    expect(repository.sharingStarts, 1);
    expect(repository.lastSharingTrigger, SharingTrigger.manual);
    controller.dispose();
    await tracker.close();
  });
}
