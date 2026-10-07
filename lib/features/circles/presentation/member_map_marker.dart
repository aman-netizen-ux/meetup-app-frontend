import 'package:flutter/material.dart';

import '../domain/entities/member_presence.dart';

class MemberMapMarker extends StatelessWidget {
  const MemberMapMarker({
    super.key,
    required this.name,
    required this.presence,
  });

  final String name;
  final MemberPresence presence;

  @override
  Widget build(BuildContext context) {
    final here = presence == MemberPresence.here;
    final stale = presence == MemberPresence.inTransit;
    final color = here
        ? const Color(0xFF2D9D78)
        : stale
        ? const Color(0xFFF0A34A)
        : const Color(0xFF275A68);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0x44000000), blurRadius: 9),
        ],
      ),
      child: Center(
        child: Text(
          name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase(),
          style: TextStyle(color: color, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
