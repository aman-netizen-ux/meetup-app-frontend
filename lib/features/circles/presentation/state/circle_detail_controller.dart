import 'package:flutter/foundation.dart';

import '../../domain/entities/circle_snapshot.dart';
import '../../domain/entities/circle_state.dart';
import '../../domain/entities/end_reason.dart';
import '../../domain/repositories/circle_repository.dart';
import 'circle_detail_action_state.dart';
import 'circle_connection_status.dart';

class CircleDetailController {
  CircleDetailController(this._repository, CircleSnapshot initial)
    : circle = ValueNotifier(initial);

  final CircleRepository _repository;
  final ValueNotifier<CircleSnapshot?> circle;
  final ValueNotifier<CircleDetailActionState> action = ValueNotifier(
    const CircleDetailActionState(),
  );
  final ValueNotifier<CircleConnectionStatus> connection = ValueNotifier(
    CircleConnectionStatus.connecting,
  );
  bool _listening = false;

  void startLiveUpdates() {
    if (_listening) return;
    _listening = true;
    _listen();
  }

  Future<void> _listen() async {
    while (_listening) {
      if (circle.value?.state == CircleState.ended) {
        connection.value = CircleConnectionStatus.live;
        _listening = false;
        return;
      }
      try {
        final updated = await _repository.waitForCircleChange(
          circle.value!.id,
          circle.value!.revision,
        );
        if (!_listening) return;
        if (updated != null && updated.revision > circle.value!.revision) {
          circle.value = updated;
        }
        connection.value = CircleConnectionStatus.live;
      } catch (_) {
        if (!_listening) return;
        connection.value = CircleConnectionStatus.reconnecting;
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }
  }

  void apply(CircleSnapshot snapshot) {
    if (snapshot.revision >= circle.value!.revision) circle.value = snapshot;
  }

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
    _listening = false;
    circle.dispose();
    action.dispose();
    connection.dispose();
  }
}
