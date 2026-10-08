import 'package:flutter/foundation.dart';

import '../../domain/entities/circle_snapshot.dart';
import '../../domain/entities/circle_state.dart';
import '../../domain/entities/setup_status.dart';
import '../../domain/entities/travel_role.dart';
import '../../domain/repositories/circle_repository.dart';
import 'private_journey_state.dart';
import 'private_journey_status.dart';

class PrivateJourneyController extends ValueNotifier<PrivateJourneyState> {
  PrivateJourneyController({
    required CircleRepository repository,
    required String circleId,
    required String userId,
  }) : _repository = repository,
       _circleId = circleId,
       _userId = userId,
       super(const PrivateJourneyState(status: PrivateJourneyStatus.hidden));

  final CircleRepository _repository;
  final String _circleId;
  final String _userId;
  int? _loadedRevision;
  bool _loading = false;
  bool _disposed = false;

  void sync(CircleSnapshot circle) {
    final member = circle.members.where((item) => item.userId == _userId).firstOrNull;
    final eligible = circle.state == CircleState.active &&
        member?.travelRole == TravelRole.mover &&
        member?.setupStatus == SetupStatus.ready;
    if (!eligible) {
      _loadedRevision = null;
      value = const PrivateJourneyState(status: PrivateJourneyStatus.hidden);
      return;
    }
    if (_loadedRevision != circle.revision && !_loading) load(circle.revision);
  }

  Future<void> load([int? revision]) async {
    if (_loading) return;
    _loading = true;
    value = PrivateJourneyState(
      status: PrivateJourneyStatus.loading,
      journey: value.journey,
    );
    try {
      final journey = await _repository.getMyJourney(_circleId);
      if (_disposed) return;
      _loadedRevision = revision ?? _loadedRevision;
      value = PrivateJourneyState(
        status: PrivateJourneyStatus.ready,
        journey: journey,
      );
    } catch (_) {
      if (_disposed) return;
      value = PrivateJourneyState(
        status: PrivateJourneyStatus.failure,
        journey: value.journey,
      );
    } finally {
      _loading = false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
