import 'package:flutter_test/flutter_test.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/journey_mode.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/journey_route_leg.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/journey_route_option.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/member_presence.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/setup_status.dart';
import 'package:meetup_app_frontend/features/circles/presentation/state/route_selection_controller.dart';
import 'package:meetup_app_frontend/features/circles/presentation/state/route_selection_status.dart';

import 'support/circle_test_snapshot.dart';
import 'support/fake_circle_repository.dart';

void main() {
  const walk = JourneyRouteOption(
    id: 'walk-1',
    mode: JourneyMode.walk,
    label: 'Walk there',
    accuracyLabel: 'Walking estimate',
    distanceMeters: 1400,
    durationSeconds: 1100,
    encodedPolyline: 'abc',
    polylinePrecision: 6,
    legs: [
      JourneyRouteLeg(
        mode: JourneyMode.walk,
        label: 'Walk west',
        distanceMeters: 1400,
        durationSeconds: 1100,
      ),
    ],
    checkpoints: [],
  );

  test('loads only after live sharing and saves an explicit choice', () async {
    final repository = FakeCircleRepository(circleTestSnapshot(
      setupStatus: SetupStatus.ready,
    ))..routeOptions = const [walk];
    final controller = RouteSelectionController(
      repository: repository,
      circleId: 'circle-1',
      userId: 'user-1',
    );

    controller.sync(repository.snapshot);
    expect(controller.value.status, RouteSelectionStatus.inactive);

    final live = circleTestSnapshot(
      setupStatus: SetupStatus.ready,
      presence: MemberPresence.live,
    );
    controller.sync(live);
    await Future<void>.delayed(Duration.zero);
    expect(controller.value.status, RouteSelectionStatus.ready);
    expect(controller.value.options, const [walk]);
    expect(controller.value.selected, isNull);

    await controller.select('walk-1');
    expect(controller.value.selected, walk);
    expect(repository.selectedRoute, walk);
    controller.dispose();
  });

  test('empty provider result is a recoverable state', () async {
    final repository = FakeCircleRepository(circleTestSnapshot(
      setupStatus: SetupStatus.ready,
      presence: MemberPresence.live,
    ));
    final controller = RouteSelectionController(
      repository: repository,
      circleId: 'circle-1',
      userId: 'user-1',
    );

    controller.sync(repository.snapshot);
    await Future<void>.delayed(Duration.zero);
    expect(controller.value.status, RouteSelectionStatus.empty);
    expect(controller.value.message, contains('No route'));
    controller.dispose();
  });
}
