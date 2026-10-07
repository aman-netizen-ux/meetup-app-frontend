import 'contact_match_status.dart';

class ContactInviteCandidate {
  const ContactInviteCandidate({
    required this.localId,
    required this.displayName,
    required this.status,
    this.appDisplayName,
    this.matchId,
  });

  final String localId;
  final String displayName;
  final ContactMatchStatus status;
  final String? appDisplayName;
  final String? matchId;
}
