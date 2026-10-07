import '../entities/contact_invite_candidate.dart';

abstract class ContactRepository {
  Future<List<ContactInviteCandidate>> loadAndMatch(String circleId);
  Future<void> addMappedContact(
    String circleId,
    ContactInviteCandidate contact,
  );
  Future<void> openSettings();
}
