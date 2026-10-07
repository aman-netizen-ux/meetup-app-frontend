import 'package:flutter/foundation.dart';

import '../../domain/entities/circle_snapshot.dart';
import '../../domain/entities/end_reason.dart';
import '../../domain/repositories/circle_repository.dart';
import 'circle_detail_action_state.dart';

class CircleDetailController {
  CircleDetailController(this._repository, CircleSnapshot initial)
    : circle = ValueNotifier(initial);

  final CircleRepository _repository;
  final ValueNotifier<CircleSnapshot?> circle;
  final ValueNotifier<CircleDetailActionState> action = ValueNotifier(
    const CircleDetailActionState(),
  );

  Future<void> refresh() async {
    if (circle.value == null) return;
    try {
      circle.value = await _repository.getCircle(circle.value!.id);
      action.value = const CircleDetailActionState();
    } catch (_) {
      action.value = const CircleDetailActionState(
        error: 'Could not refresh this circle.',
      );
    }
  }

  Future<bool> end() async {
    if (circle.value == null || action.value.busy) return false;
    action.value = const CircleDetailActionState(busy: true);
    try {
      circle.value = await _repository.endCircle(
        circle.value!.id,
        EndReason.organizerEnded,
      );
      action.value = const CircleDetailActionState();
      return true;
    } catch (_) {
      action.value = const CircleDetailActionState(
        error: 'Could not end this circle. Try again.',
      );
      return false;
    }
  }

  void dispose() {
    circle.dispose();
    action.dispose();
  }
}
