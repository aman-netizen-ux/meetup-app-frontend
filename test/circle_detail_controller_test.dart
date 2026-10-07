import 'package:flutter_test/flutter_test.dart';
import 'package:meetup_app_frontend/features/circles/presentation/state/circle_detail_controller.dart';

import 'support/circle_test_snapshot.dart';
import 'support/fake_circle_repository.dart';

void main() {
  test('live listener applies only a newer complete snapshot', () async {
    final initial = circleTestSnapshot();
    final repository = FakeCircleRepository(initial);
    final controller = CircleDetailController(repository, initial);

    controller.startLiveUpdates();
    repository.emit(circleTestSnapshot(revision: 1));
    await Future<void>.delayed(Duration.zero);

    expect(controller.circle.value?.revision, 1);
    controller.dispose();
  });
}
