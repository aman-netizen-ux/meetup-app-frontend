import 'package:flutter/foundation.dart';

import '../../domain/entities/circle_member.dart';
import '../../domain/entities/circle_snapshot.dart';
import '../../domain/entities/circle_state.dart';
import '../../domain/entities/member_presence.dart';
import '../../domain/entities/journey_route_option.dart';
import '../../domain/entities/setup_status.dart';
import '../../domain/entities/travel_role.dart';
import '../../domain/repositories/circle_repository.dart';
import 'route_selection_state.dart';
import 'route_selection_status.dart';

class RouteSelectionController extends ValueNotifier<RouteSelectionState> {
  RouteSelectionController({
    required CircleRepository repository,
    required String circleId,
    required String userId,
  }) : _repository = repository,
       _circleId = circleId,
       _userId = userId,
       super(const RouteSelectionState(status: RouteSelectionStatus.inactive));

  final CircleRepository _repository;
  final String _circleId;
  final String _userId;
  bool _loaded = false;
  bool _busy = false;
  bool _disposed = false;

  void sync(CircleSnapshot circle) {
    final member = circle.members.where((item) => item.userId == _userId).firstOrNull;
    if (!_eligible(circle, member)) {
      _loaded = false;
      if (value.status != RouteSelectionStatus.inactive) {
        value = const RouteSelectionState(status: RouteSelectionStatus.inactive);
      }
      return;
    }
    if (!_loaded && !_busy) load();
  }

  Future<void> load() async {
    if (_busy) return;
    _busy = true;
    value = RouteSelectionState(
      status: RouteSelectionStatus.loading,
      selected: value.selected,
    );
    try {
      final results = await Future.wait<Object?>([
        _repository.getSelectedRoute(_circleId),
        _repository.getRouteOptions(_circleId),
      ]);
      if (_disposed) return;
      final selected = results[0] as JourneyRouteOption?;
      final options = results[1] as List<JourneyRouteOption>;
      _loaded = true;
      value = RouteSelectionState(
        status: options.isEmpty
            ? RouteSelectionStatus.empty
            : RouteSelectionStatus.ready,
        options: options,
        selected: selected,
        message: options.isEmpty
            ? 'No route is available right now. Check your connection or try again shortly.'
            : null,
      );
    } catch (_) {
      if (_disposed) return;
      value = RouteSelectionState(
        status: RouteSelectionStatus.failure,
        selected: value.selected,
        message: 'Routes could not be loaded. Your live location is still sharing.',
      );
    } finally {
      _busy = false;
    }
  }

  Future<void> select(String optionId) async {
    if (_busy) return;
    _busy = true;
    final previous = value;
    value = RouteSelectionState(
      status: RouteSelectionStatus.selecting,
      options: previous.options,
      selected: previous.selected,
    );
    try {
      final selected = await _repository.selectRoute(_circleId, optionId);
      if (_disposed) return;
      value = RouteSelectionState(
        status: RouteSelectionStatus.ready,
        options: previous.options,
        selected: selected,
      );
    } catch (_) {
      if (_disposed) return;
      value = RouteSelectionState(
        status: RouteSelectionStatus.failure,
        options: previous.options,
        selected: previous.selected,
        message: 'That route expired. Refresh the suggestions and choose again.',
      );
    } finally {
      _busy = false;
    }
  }

  bool _eligible(CircleSnapshot circle, CircleMember? member) =>
      circle.state == CircleState.active &&
      member?.travelRole == TravelRole.mover &&
      member?.setupStatus == SetupStatus.ready &&
      (member?.presence == MemberPresence.live ||
          member?.presence == MemberPresence.inTransit) &&
      member?.arrivedAt == null;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
