import 'package:flutter_test/flutter_test.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/location_permission_result.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/setup_status.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/travel_role.dart';
import 'package:meetup_app_frontend/features/circles/presentation/state/member_role_controller.dart';
import 'package:meetup_app_frontend/features/circles/presentation/state/member_role_status.dart';

import 'support/circle_test_snapshot.dart';
import 'support/fake_circle_repository.dart';
import 'support/fake_mover_location_permission.dart';

void main() {
  test(
    'pending active mover requests permission before becoming ready',
    () async {
      final initial = circleTestSnapshot();
      final repository = FakeCircleRepository(initial);
      final permission = FakeMoverLocationPermission(
        LocationPermissionResult.granted,
      );
      final controller = MemberRoleController(
        repository: repository,
        permission: permission,
        circleId: initial.id,
        userId: 'user-1',
        initial: initial.members.first,
      );

      final updated = await controller.change(
        TravelRole.mover,
        requestLocation: true,
      );

      expect(permission.requests, 1);
      expect(repository.roleChanges, 1);
      expect(updated?.members.first.setupStatus, SetupStatus.ready);
      expect(controller.value.setupStatus, SetupStatus.ready);
      controller.dispose();
    },
  );

  test('denied location keeps pending membership unchanged', () async {
    final initial = circleTestSnapshot();
    final repository = FakeCircleRepository(initial);
    final permission = FakeMoverLocationPermission(
      LocationPermissionResult.denied,
    );
    final controller = MemberRoleController(
      repository: repository,
      permission: permission,
      circleId: initial.id,
      userId: 'user-1',
      initial: initial.members.first,
    );

    final updated = await controller.change(
      TravelRole.mover,
      requestLocation: true,
    );

    expect(updated, isNull);
    expect(repository.roleChanges, 0);
    expect(controller.value.status, MemberRoleStatus.failure);
    expect(controller.value.setupStatus, SetupStatus.pending);
    controller.dispose();
  });
}
