import 'package:flutter/material.dart';

import '../domain/entities/setup_status.dart';
import '../domain/entities/travel_role.dart';
import 'state/member_role_controller.dart';
import 'state/member_role_state.dart';
import 'state/member_role_status.dart';

class MemberRoleCard extends StatelessWidget {
  const MemberRoleCard({
    super.key,
    required this.controller,
    required this.privatePlace,
    required this.ended,
    required this.onSelected,
  });

  final MemberRoleController controller;
  final bool privatePlace;
  final bool ended;
  final ValueChanged<TravelRole> onSelected;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<MemberRoleState>(
    valueListenable: controller,
    builder: (context, state, _) {
      final pending = state.setupStatus == SetupStatus.pending;
      final busy =
          state.status == MemberRoleStatus.saving ||
          state.status == MemberRoleStatus.requestingPermission;
      return Card(
        color: pending ? const Color(0xFFFFF2D8) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF17283E),
                    child: Icon(Icons.person_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'You',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          pending
                              ? 'Confirm how you are joining this meetup'
                              : 'Your role in this circle',
                          style: const TextStyle(color: Color(0xFF677381)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SegmentedButton<TravelRole>(
                segments: [
                  const ButtonSegment(
                    value: TravelRole.mover,
                    icon: Icon(Icons.directions_walk_rounded),
                    label: Text('Mover'),
                  ),
                  ButtonSegment(
                    value: TravelRole.anchor,
                    enabled: privatePlace,
                    icon: const Icon(Icons.home_work_rounded),
                    label: const Text('Anchor'),
                  ),
                ],
                selected: {state.role},
                onSelectionChanged: ended || busy
                    ? null
                    : (roles) => onSelected(roles.first),
              ),
              if (!privatePlace) ...[
                const SizedBox(height: 8),
                const Text(
                  'Anchor is available only for a private-place destination.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF677381)),
                ),
              ],
              if (busy) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(borderRadius: BorderRadius.circular(8)),
              ],
              if (state.message != null) ...[
                const SizedBox(height: 10),
                Text(
                  state.message!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                if (state.settingsRequired)
                  TextButton(
                    onPressed: controller.openSettings,
                    child: const Text('Open app settings'),
                  ),
              ],
            ],
          ),
        ),
      );
    },
  );
}
