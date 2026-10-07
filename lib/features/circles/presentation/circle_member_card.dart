import 'package:flutter/material.dart';

import '../domain/entities/circle_member.dart';
import '../domain/entities/setup_status.dart';

class CircleMemberCard extends StatelessWidget {
  const CircleMemberCard({super.key, required this.member});

  final CircleMember member;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFDBF3EE),
        child: Text(
          member.displayName.isEmpty
              ? '?'
              : member.displayName[0].toUpperCase(),
        ),
      ),
      title: Text(member.displayName),
      subtitle: Text(
        member.isOrganizer
            ? 'Organizer · ${member.travelRole.name}'
            : member.setupStatus == SetupStatus.pending
            ? 'Pending confirmation'
            : member.travelRole.name,
      ),
      trailing: member.setupStatus == SetupStatus.pending
          ? const Icon(Icons.schedule_rounded, color: Color(0xFFB87333))
          : null,
    ),
  );
}
