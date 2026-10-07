import 'contact_action_status.dart';

class ContactActionState {
  const ContactActionState({required this.status, this.message});

  final ContactActionStatus status;
  final String? message;
}
