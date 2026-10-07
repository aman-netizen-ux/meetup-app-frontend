import '../../../circles/domain/entities/invitation_link.dart';
import 'invitation_link_status.dart';

class InvitationLinkState {
  const InvitationLinkState({required this.status, this.link, this.message});

  final InvitationLinkStatus status;
  final InvitationLink? link;
  final String? message;
}
