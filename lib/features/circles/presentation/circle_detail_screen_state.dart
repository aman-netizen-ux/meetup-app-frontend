import 'package:flutter/material.dart';

import '../../contacts/presentation/contact_invite_screen.dart';
import '../../invitations/presentation/invitation_link_panel.dart';
import '../../invitations/presentation/state/invitation_link_controller.dart';
import '../domain/entities/circle_member.dart';
import '../domain/entities/circle_snapshot.dart';
import '../domain/entities/circle_state.dart';
import '../domain/entities/setup_status.dart';
import '../domain/entities/travel_role.dart';
import 'circle_connection_badge.dart';
import 'circle_detail_screen.dart';
import 'circle_header_card.dart';
import 'circle_live_section.dart';
import 'circle_member_card.dart';
import 'member_role_card.dart';
import 'location_sharing_card.dart';
import 'state/circle_connection_status.dart';
import 'state/circle_detail_action_state.dart';
import 'state/circle_detail_controller.dart';
import 'state/member_role_controller.dart';
import 'state/location_sharing_controller.dart';

class CircleDetailScreenState extends State<CircleDetailScreen> {
  late final CircleDetailController _controller = CircleDetailController(
    widget.repository,
    widget.initial,
  );
  late final InvitationLinkController _invitationController =
      InvitationLinkController(widget.repository);
  late final MemberRoleController _roleController = MemberRoleController(
    repository: widget.repository,
    permission: widget.moverLocationPermission,
    circleId: widget.initial.id,
    userId: widget.currentUserId,
    initial: _myMember(widget.initial),
  );
  late final LocationSharingController _locationController =
      LocationSharingController(
        repository: widget.repository,
        permission: widget.moverLocationPermission,
        tracker: widget.locationTracker,
        circleId: widget.initial.id,
        userId: widget.currentUserId,
        onSnapshot: _controller.apply,
      );

  CircleMember _myMember(CircleSnapshot circle) => circle.members.firstWhere(
    (member) => member.userId == widget.currentUserId,
  );

  @override
  void initState() {
    super.initState();
    _controller.circle.addListener(_syncMyRole);
    _locationController.sync(widget.initial);
    _controller.refresh();
    _controller.startLiveUpdates();
  }

  @override
  void dispose() {
    _controller.circle.removeListener(_syncMyRole);
    _controller.dispose();
    _invitationController.dispose();
    _roleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _syncMyRole() {
    final circle = _controller.circle.value;
    if (circle != null) {
      _roleController.sync(_myMember(circle));
      _locationController.sync(circle);
    }
  }

  Future<void> _prepareLocationSharing() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.shield_outlined, color: Color(0xFF168C83)),
        title: const Text('Share only when you leave'),
        content: const Text(
          'Meetup keeps your starting point on this phone. Your circle sees a pin only after you move about 150 m or choose Share now.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Allow location'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _locationController.enable();
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

  Future<void> _changeRole(
    CircleSnapshot circle,
    CircleMember member,
    TravelRole role,
  ) async {
    if (member.setupStatus == SetupStatus.ready && member.travelRole == role) {
      return;
    }
    final requestLocation =
        role == TravelRole.mover &&
        circle.state == CircleState.active &&
        (member.setupStatus == SetupStatus.pending ||
            member.travelRole != TravelRole.mover);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          role == TravelRole.mover
              ? Icons.directions_walk_rounded
              : Icons.home_work_rounded,
        ),
        title: Text(
          member.setupStatus == SetupStatus.pending
              ? 'Finish joining as ${role.name}?'
              : 'Switch to ${role.name}?',
        ),
        content: Text(
          role == TravelRole.mover
              ? requestLocation
                    ? 'Android will ask for location access next. Meetup will not share a position until the later departure or Share now step.'
                    : 'Your circle will show you as a mover. Location is requested only when this circle becomes active.'
              : 'Meetup will stop future location updates. Your last shared point can remain frozen for the circle.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final updated = await _roleController.change(
      role,
      requestLocation: requestLocation,
    );
    if (updated != null) _controller.apply(updated);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF7F4EE),
    appBar: AppBar(
      title: const Text('Circle details'),
      backgroundColor: const Color(0xFFF7F4EE),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Center(
            child: ValueListenableBuilder<CircleConnectionStatus>(
              valueListenable: _controller.connection,
              builder: (context, status, _) =>
                  CircleConnectionBadge(status: status),
            ),
          ),
        ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: _controller.refresh,
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          ValueListenableBuilder<CircleSnapshot?>(
            valueListenable: _controller.circle,
            builder: (context, circle, _) => circle == null
                ? const Center(child: CircularProgressIndicator())
                : CircleHeaderCard(circle: circle),
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder<CircleSnapshot?>(
            valueListenable: _controller.circle,
            builder: (context, circle, _) => circle == null ||
                    circle.state == CircleState.scheduled
                ? const SizedBox.shrink()
                : CircleLiveSection(circle: circle),
          ),
          const SizedBox(height: 24),
          LocationSharingCard(
            controller: _locationController,
            onPrepare: _prepareLocationSharing,
          ),
          const SizedBox(height: 24),
          const Text(
            'Your role',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<CircleSnapshot?>(
            valueListenable: _controller.circle,
            builder: (context, circle, _) {
              if (circle == null) return const SizedBox.shrink();
              final mine = _myMember(circle);
              return Column(
                children: [
                  MemberRoleCard(
                    controller: _roleController,
                    privatePlace: circle.isPrivatePlace,
                    ended: circle.state == CircleState.ended,
                    onSelected: (role) => _changeRole(circle, mine, role),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Journey updates',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<CircleSnapshot?>(
            valueListenable: _controller.circle,
            builder: (context, circle, _) => circle == null
                ? const SizedBox.shrink()
                : Column(
                    children: circle.members
                        .map((member) => CircleMemberCard(member: member))
                        .toList(growable: false),
                  ),
          ),
          const SizedBox(height: 18),
          ValueListenableBuilder<CircleSnapshot?>(
            valueListenable: _controller.circle,
            builder: (context, circle, _) {
              if (circle == null) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.isOrganizer &&
                      circle.state != CircleState.ended) ...[
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
                        if (widget.isOrganizer &&
                            circle.state != CircleState.ended)
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
              );
            },
          ),
        ],
      ),
    ),
  );
}
