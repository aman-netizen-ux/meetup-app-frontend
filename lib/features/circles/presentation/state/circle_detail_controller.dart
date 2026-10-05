import 'package:flutter/foundation.dart';

import '../../domain/entities/circle_snapshot.dart';
import '../../domain/entities/end_reason.dart';
import '../../domain/repositories/circle_repository.dart';

class CircleDetailController extends ValueNotifier<CircleSnapshot?> {
  CircleDetailController(this._repository, CircleSnapshot initial)
    : super(initial);

  final CircleRepository _repository;
  bool busy = false;
  String? error;

  Future<void> refresh() async {
    if (value == null) return;
    try {
      value = await _repository.getCircle(value!.id);
      error = null;
    } catch (_) {
      error = 'Could not refresh this circle.';
      notifyListeners();
    }
  }

  Future<bool> end() async {
    if (value == null || busy) return false;
    busy = true;
    notifyListeners();
    try {
      value = await _repository.endCircle(value!.id, EndReason.organizerEnded);
      error = null;
      return true;
    } catch (_) {
      error = 'Could not end this circle. Try again.';
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
