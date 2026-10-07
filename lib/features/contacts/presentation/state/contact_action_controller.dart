import 'package:flutter/foundation.dart';

import '../../../circles/domain/repositories/circle_repository.dart';
import '../../domain/entities/contact_invite_candidate.dart';
import '../../domain/repositories/contact_repository.dart';
import '../../domain/repositories/share_service.dart';
import 'contact_action_state.dart';
import 'contact_action_status.dart';

class ContactActionController extends ValueNotifier<ContactActionState> {
  ContactActionController({
    required ContactRepository contacts,
    required CircleRepository circles,
    required ShareService share,
    required String circleId,
    required ContactInviteCandidate contact,
  }) : _contacts = contacts,
       _circles = circles,
       _share = share,
       _circleId = circleId,
       _contact = contact,
       super(const ContactActionState(status: ContactActionStatus.idle));

  final ContactRepository _contacts;
  final CircleRepository _circles;
  final ShareService _share;
  final String _circleId;
  final ContactInviteCandidate _contact;

  Future<void> add() async {
    if (value.status == ContactActionStatus.working) return;
    value = const ContactActionState(status: ContactActionStatus.working);
    try {
      await _contacts.addMappedContact(_circleId, _contact);
      value = const ContactActionState(status: ContactActionStatus.added);
    } catch (_) {
      value = const ContactActionState(
        status: ContactActionStatus.failure,
        message: 'Could not add this person. Refresh contacts and try again.',
      );
    }
  }

  Future<void> share() async {
    if (value.status == ContactActionStatus.working) return;
    value = const ContactActionState(status: ContactActionStatus.working);
    try {
      final link = await _circles.createInvitationLink(_circleId);
      await _share.shareInvitation(
        contactName: _contact.displayName,
        invitationUrl: link.url,
      );
      value = const ContactActionState(status: ContactActionStatus.shared);
    } catch (_) {
      value = const ContactActionState(
        status: ContactActionStatus.failure,
        message: 'Could not open the share sheet. Try again.',
      );
    }
  }
}
