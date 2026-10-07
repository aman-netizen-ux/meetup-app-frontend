import 'package:flutter/foundation.dart';

import '../../../circles/domain/repositories/circle_repository.dart';
import 'invitation_link_state.dart';
import 'invitation_link_status.dart';

class InvitationLinkController extends ValueNotifier<InvitationLinkState> {
  InvitationLinkController(this._repository)
    : super(const InvitationLinkState(status: InvitationLinkStatus.idle));

  final CircleRepository _repository;

  Future<void> create(String circleId) async {
    if (value.status == InvitationLinkStatus.loading) return;
    value = const InvitationLinkState(status: InvitationLinkStatus.loading);
    try {
      value = InvitationLinkState(
        status: InvitationLinkStatus.ready,
        link: await _repository.createInvitationLink(circleId),
      );
    } catch (_) {
      value = const InvitationLinkState(
        status: InvitationLinkStatus.failure,
        message: 'Could not create an invitation. Try again.',
      );
    }
  }

  void reset() {
    value = const InvitationLinkState(status: InvitationLinkStatus.idle);
  }
}
