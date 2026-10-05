import 'package:flutter/foundation.dart';

import '../../domain/repositories/circle_repository.dart';
import 'circles_home_state.dart';
import 'circles_home_status.dart';

/// Presentation state only. Authenticated loading is wired in F-04/F-05.
class CirclesHomeController extends ValueNotifier<CirclesHomeState> {
  CirclesHomeController()
    : super(const CirclesHomeState(status: CirclesHomeStatus.empty));

  Future<void> load(CircleRepository repository) async {
    value = const CirclesHomeState(status: CirclesHomeStatus.loading);
    try {
      final circles = await repository.listCircles();
      value = CirclesHomeState(
        status: circles.isEmpty
            ? CirclesHomeStatus.empty
            : CirclesHomeStatus.loaded,
        circles: circles,
      );
    } catch (_) {
      value = const CirclesHomeState(
        status: CirclesHomeStatus.failure,
        errorMessage: 'Could not load your circles. Try again.',
      );
    }
  }
}
