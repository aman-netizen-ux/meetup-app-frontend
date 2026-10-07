import 'package:flutter/material.dart';

import '../domain/entities/contact_invite_candidate.dart';
import '../domain/entities/contact_match_status.dart';
import 'contact_invite_screen.dart';
import 'state/contact_action_controller.dart';
import 'state/contact_action_state.dart';
import 'state/contact_action_status.dart';
import 'state/contact_list_controller.dart';
import 'state/contact_list_state.dart';
import 'state/contact_list_status.dart';

class ContactInviteScreenState extends State<ContactInviteScreen> {
  late final ContactListController _controller = ContactListController(
    widget.contacts,
    widget.circleId,
  );
  final ValueNotifier<String> _query = ValueNotifier('');
  final Map<String, ContactActionController> _actions = {};

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _query.dispose();
    for (final action in _actions.values) {
      action.dispose();
    }
    super.dispose();
  }

  ContactActionController _actionFor(ContactInviteCandidate contact) =>
      _actions.putIfAbsent(
        contact.localId,
        () => ContactActionController(
          contacts: widget.contacts,
          circles: widget.circles,
          share: widget.share,
          circleId: widget.circleId,
          contact: contact,
        ),
      );

  Future<void> _confirmAdd(
    ContactInviteCandidate contact,
    ContactActionController action,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${contact.displayName}?'),
        content: const Text(
          'They will appear as pending. They must open the circle, confirm their role, and grant location permission before sharing can begin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add pending member'),
          ),
        ],
      ),
    );
    if (confirmed == true) await action.add();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF7F4EE),
    appBar: AppBar(
      title: const Text('Invite contacts'),
      backgroundColor: const Color(0xFFF7F4EE),
    ),
    body: ValueListenableBuilder<ContactListState>(
      valueListenable: _controller,
      builder: (context, state, _) => switch (state.status) {
        ContactListStatus.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        ContactListStatus.ready => _contactList(state.contacts),
        ContactListStatus.empty => _message(
          icon: Icons.contact_phone_outlined,
          title: 'No matchable contacts',
          message:
              'Contacts need a phone number saved with an international country code.',
          action: 'Try again',
          onPressed: _controller.load,
        ),
        ContactListStatus.settingsRequired => _message(
          icon: Icons.lock_outline_rounded,
          title: 'Allow contacts in Settings',
          message: state.message!,
          action: 'Open Settings',
          onPressed: _controller.openSettings,
        ),
        ContactListStatus.denied || ContactListStatus.failure => _message(
          icon: Icons.contacts_outlined,
          title: state.status == ContactListStatus.denied
              ? 'Contacts stay private'
              : 'Could not load contacts',
          message: state.message!,
          action: 'Try again',
          onPressed: _controller.load,
        ),
      },
    ),
  );

  Widget _contactList(List<ContactInviteCandidate> contacts) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Names stay on your phone. Only international phone numbers are checked securely and are not retained.',
              style: TextStyle(color: Color(0xFF677381)),
            ),
            const SizedBox(height: 14),
            TextField(
              onChanged: (value) => _query.value = value.trim().toLowerCase(),
              decoration: InputDecoration(
                hintText: 'Search contacts',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: ValueListenableBuilder<String>(
          valueListenable: _query,
          builder: (context, query, _) {
            final visible = query.isEmpty
                ? contacts
                : contacts
                      .where(
                        (contact) =>
                            contact.displayName.toLowerCase().contains(query),
                      )
                      .toList(growable: false);
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: visible.length,
              itemBuilder: (context, index) => _contactCard(visible[index]),
            );
          },
        ),
      ),
    ],
  );

  Widget _contactCard(ContactInviteCandidate contact) {
    final action = _actionFor(contact);
    final mapped = contact.status == ContactMatchStatus.mapped;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: mapped
                  ? const Color(0xFFDBF3EE)
                  : const Color(0xFFFFE8E1),
              child: Text(contact.displayName[0].toUpperCase()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    mapped
                        ? '${contact.appDisplayName ?? contact.displayName} · On Meetup'
                        : 'Send an invitation link',
                    style: const TextStyle(color: Color(0xFF677381)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<ContactActionState>(
              valueListenable: action,
              builder: (context, state, _) =>
                  _actionButton(contact, action, state, mapped),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
    ContactInviteCandidate contact,
    ContactActionController action,
    ContactActionState state,
    bool mapped,
  ) {
    if (state.status == ContactActionStatus.working) {
      return const SizedBox.square(
        dimension: 34,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (state.status == ContactActionStatus.added) {
      return const Chip(
        label: Text('Added'),
        avatar: Icon(Icons.check, size: 18),
      );
    }
    if (state.status == ContactActionStatus.shared) {
      return const Chip(
        label: Text('Shared'),
        avatar: Icon(Icons.check, size: 18),
      );
    }
    return IconButton.filledTonal(
      tooltip: state.message ?? (mapped ? 'Add contact' : 'Share invitation'),
      onPressed: mapped ? () => _confirmAdd(contact, action) : action.share,
      icon: Icon(mapped ? Icons.person_add_alt_1_rounded : Icons.share_rounded),
    );
  }

  Widget _message({
    required IconData icon,
    required String title,
    required String message,
    required String action,
    required VoidCallback onPressed,
  }) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 62, color: const Color(0xFF168C83)),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 18),
          FilledButton.tonal(onPressed: onPressed, child: Text(action)),
        ],
      ),
    ),
  );
}
