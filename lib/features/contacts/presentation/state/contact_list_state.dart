import '../../domain/entities/contact_invite_candidate.dart';
import 'contact_list_status.dart';

class ContactListState {
  const ContactListState({
    required this.status,
    this.contacts = const [],
    this.message,
  });

  final ContactListStatus status;
  final List<ContactInviteCandidate> contacts;
  final String? message;
}
