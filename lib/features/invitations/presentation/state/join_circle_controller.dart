import 'package:flutter/foundation.dart';

import '../../../../core/network/api_error.dart';
import '../../../circles/domain/entities/circle_snapshot.dart';
import '../../../circles/domain/entities/travel_role.dart';
import '../../../circles/domain/repositories/circle_repository.dart';
import 'join_circle_state.dart';
import 'join_circle_status.dart';

class JoinCircleController extends ValueNotifier<JoinCircleState> {
  JoinCircleController(this._repository, this._token)
    : super(const JoinCircleState(status: JoinCircleStatus.loading));

  final CircleRepository _repository;
  final String _token;

  Future<void> load() async {
    value = const JoinCircleState(status: JoinCircleStatus.loading);
    try {
      value = JoinCircleState(
        status: JoinCircleStatus.ready,
        preview: await _repository.previewInvitation(_token),
      );
    } on ApiError catch (error) {
      value = JoinCircleState(
        status: error.statusCode == 410
            ? JoinCircleStatus.expired
            : JoinCircleStatus.failure,
        message: error.message,
      );
    } catch (_) {
      value = const JoinCircleState(
        status: JoinCircleStatus.failure,
        message: 'Could not open this invitation.',
      );
    }
  }

  Future<CircleSnapshot?> accept(TravelRole role) async {
    final preview = value.preview;
    if (preview == null || value.status == JoinCircleStatus.accepting) {
      return null;
    }
    value = JoinCircleState(
      status: JoinCircleStatus.accepting,
      preview: preview,
    );
    try {
      return await _repository.acceptInvitation(_token, role);
    } on ApiError catch (error) {
      value = JoinCircleState(
        status: JoinCircleStatus.ready,
        preview: preview,
        message: error.message,
      );
      return null;
    } catch (_) {
      value = JoinCircleState(
        status: JoinCircleStatus.ready,
        preview: preview,
        message: 'Could not join this circle. Try again.',
      );
      return null;
    }
  }
}
