import 'package:flutter_test/flutter_test.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/eta_range.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/private_journey.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/setup_status.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/travel_role.dart';
import 'package:meetup_app_frontend/features/circles/presentation/state/private_journey_controller.dart';
import 'package:meetup_app_frontend/features/circles/presentation/state/private_journey_status.dart';

import 'support/circle_test_snapshot.dart';
import 'support/fake_circle_repository.dart';

void main() {
  test('loads private ETA once per circle revision', () async {
    final repository = FakeCircleRepository(circleTestSnapshot(
      setupStatus: SetupStatus.ready,
    ))..privateJourney = PrivateJourney(
      travelRole: TravelRole.mover,
      etaMinutes: const EtaRange(min: 18, max: 27),
      leaveByAt: DateTime.utc(2026, 10, 8, 12),
    );
    final controller = PrivateJourneyController(
      repository: repository,
      circleId: 'circle-1',
      userId: 'user-1',
    );

    controller.sync(repository.snapshot);
    await Future<void>.delayed(Duration.zero);
    expect(controller.value.status, PrivateJourneyStatus.ready);
    expect(controller.value.journey?.etaMinutes?.max, 27);

    controller.sync(circleTestSnapshot(
      revision: 1,
      setupStatus: SetupStatus.ready,
    ));
    await Future<void>.delayed(Duration.zero);
    expect(controller.value.status, PrivateJourneyStatus.ready);
    controller.dispose();
  });
}
