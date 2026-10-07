import 'package:flutter/material.dart';

import '../domain/entities/circle_member.dart';
import '../domain/entities/member_presence.dart';
import '../domain/entities/setup_status.dart';

class CircleMemberCard extends StatelessWidget {
  const CircleMemberCard({super.key, required this.member});

  final CircleMember member;

  @override
  Widget build(BuildContext context) {
    final status = _statusLabel;
    final statusColor = _statusColor;
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: statusColor.withValues(alpha: 0.14),
              child: Text(
                member.displayName.isEmpty
                    ? '?'
                    : member.displayName[0].toUpperCase(),
                style: TextStyle(color: statusColor, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          member.displayName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (member.isOrganizer) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.workspace_premium_rounded,
                          size: 16,
                          color: Color(0xFFF0A34A),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _journeyLabel,
                    style: const TextStyle(color: Color(0xFF677381)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            DecoratedBox(
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _journeyLabel {
    if (member.setupStatus == SetupStatus.pending) return 'Pending confirmation';
    if (member.currentLeg != null) {
      final eta = member.etaMinutes;
      return eta == null
          ? member.currentLeg!.label
          : '${member.currentLeg!.label} · ${eta.min}–${eta.max} min';
    }
    if (member.arrivedAt != null || member.presence == MemberPresence.here) {
      return 'Arrived at the destination';
    }
    return member.travelRole.name == 'anchor'
        ? 'At the meeting place'
        : 'Journey has not started';
  }

  String get _statusLabel => switch (member.presence) {
    MemberPresence.notSharing => 'Not sharing',
    MemberPresence.live => 'Live',
    MemberPresence.inTransit => 'In transit',
    MemberPresence.here => 'Here',
    MemberPresence.fixed => 'At destination',
    MemberPresence.frozen => 'Last seen',
  };

  Color get _statusColor => switch (member.presence) {
    MemberPresence.live || MemberPresence.here || MemberPresence.fixed =>
      const Color(0xFF2D9D78),
    MemberPresence.inTransit => const Color(0xFFB86E1B),
    MemberPresence.frozen => const Color(0xFF7367A8),
    MemberPresence.notSharing => const Color(0xFF677381),
  };
}
