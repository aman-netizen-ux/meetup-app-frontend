import 'package:flutter/material.dart';

import '../../invitations/presentation/invitation_link_panel.dart';
import '../../invitations/presentation/state/invitation_link_controller.dart';
import '../domain/entities/circle_snapshot.dart';
import '../domain/entities/circle_state.dart';
import 'circle_detail_screen.dart';
import 'state/circle_detail_controller.dart';
import 'state/circle_detail_action_state.dart';
import '../../contacts/presentation/contact_invite_screen.dart';

class CircleDetailScreenState extends State<CircleDetailScreen> {
  late final CircleDetailController _controller = CircleDetailController(
    widget.repository,
    widget.initial,
  );
  late final InvitationLinkController _invitationController =
      InvitationLinkController(widget.repository);

  @override
  void initState() {
    super.initState();
    _controller.refresh();
  }

  @override
  void dispose() {
    _controller.dispose();
    _invitationController.dispose();
    super.dispose();
  }

  Future<void> _end() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End this circle?'),
        content: const Text(
          'The meetup will close for everyone in this circle.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep circle'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('End circle'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _controller.end();
  }

  Future<void> _inviteContacts() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ContactInviteScreen(
          circleId: widget.initial.id,
          contacts: widget.contactRepository,
          circles: widget.repository,
          share: widget.shareService,
        ),
      ),
    );
    if (mounted) await _controller.refresh();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<CircleSnapshot?>(
    valueListenable: _controller.circle,
    builder: (context, circle, _) {
      if (circle == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final stateLabel = switch (circle.state) {
        CircleState.active => 'Live circle',
        CircleState.scheduled => 'Scheduled',
        CircleState.ended => 'Ended',
      };
      final when = [
        if (circle.meetupDate != null) circle.meetupDate!,
        if (circle.meetupTime != null) circle.meetupTime!,
      ].join(' · ');
      return Scaffold(
        backgroundColor: const Color(0xFFF7F4EE),
        appBar: AppBar(
          title: const Text('Circle details'),
          backgroundColor: const Color(0xFFF7F4EE),
        ),
        body: RefreshIndicator(
          onRefresh: _controller.refresh,
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF17283E),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stateLabel.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF68D7C9),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      circle.destination.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      when.isEmpty
                          ? 'Starting now'
                          : '$when  ·  ${circle.timeZone}',
                      style: const TextStyle(color: Color(0xFFC7D7E4)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'People',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              ...circle.members.map(
                (member) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        member.displayName.isEmpty
                            ? '?'
                            : member.displayName[0].toUpperCase(),
                      ),
                    ),
                    title: Text(member.displayName),
                    subtitle: Text(
                      member.isOrganizer ? 'Organizer' : member.travelRole.name,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (widget.isOrganizer && circle.state != CircleState.ended) ...[
                FilledButton.tonalIcon(
                  onPressed: _inviteContacts,
                  icon: const Icon(Icons.contacts_rounded),
                  label: const Text('Invite from contacts'),
                ),
                const SizedBox(height: 10),
                InvitationLinkPanel(
                  circleId: circle.id,
                  controller: _invitationController,
                ),
                const SizedBox(height: 10),
              ],
              ValueListenableBuilder<CircleDetailActionState>(
                valueListenable: _controller.action,
                builder: (context, action, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (action.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          action.error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    if (widget.isOrganizer && circle.state != CircleState.ended)
                      OutlinedButton.icon(
                        onPressed: action.busy ? null : _end,
                        icon: action.busy
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.stop_circle_outlined),
                        label: Text(
                          action.busy ? 'Ending circle…' : 'End circle',
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
