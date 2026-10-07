import 'package:flutter/material.dart';

import '../domain/entities/circle_snapshot.dart';
import '../domain/entities/circle_state.dart';

class CircleHeaderCard extends StatelessWidget {
  const CircleHeaderCard({super.key, required this.circle});

  final CircleSnapshot circle;

  @override
  Widget build(BuildContext context) {
    final stateLabel = switch (circle.state) {
      CircleState.active => 'Live circle',
      CircleState.scheduled => 'Scheduled',
      CircleState.ended => 'Ended',
    };
    final when = [
      if (circle.meetupDate != null) circle.meetupDate!,
      if (circle.meetupTime != null) circle.meetupTime!,
    ].join(' · ');
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF17283E), Color(0xFF244B59)],
        ),
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
            when.isEmpty ? 'Starting now' : '$when  ·  ${circle.timeZone}',
            style: const TextStyle(color: Color(0xFFC7D7E4)),
          ),
        ],
      ),
    );
  }
}
