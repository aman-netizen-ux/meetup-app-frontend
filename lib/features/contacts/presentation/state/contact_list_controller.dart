import 'package:flutter/foundation.dart';

import '../../data/contact_permission_denied.dart';
import '../../domain/repositories/contact_repository.dart';
import 'contact_list_state.dart';
import 'contact_list_status.dart';

class ContactListController extends ValueNotifier<ContactListState> {
  ContactListController(this._repository, this._circleId)
    : super(const ContactListState(status: ContactListStatus.loading));

  final ContactRepository _repository;
  final String _circleId;

  Future<void> load() async {
    value = const ContactListState(status: ContactListStatus.loading);
    try {
      final contacts = await _repository.loadAndMatch(_circleId);
      value = ContactListState(
        status: contacts.isEmpty
            ? ContactListStatus.empty
            : ContactListStatus.ready,
        contacts: contacts,
      );
    } on ContactPermissionDenied catch (error) {
      value = ContactListState(
        status: error.permanent
            ? ContactListStatus.settingsRequired
            : ContactListStatus.denied,
        message:
            'Contacts permission is needed to find friends already using Meetup.',
      );
    } catch (_) {
      value = const ContactListState(
        status: ContactListStatus.failure,
        message: 'Could not load contacts. Try again.',
      );
    }
  }

  Future<void> openSettings() => _repository.openSettings();
}
