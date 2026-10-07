import 'package:flutter/material.dart';

import 'state/circle_connection_status.dart';

class CircleConnectionBadge extends StatelessWidget {
  const CircleConnectionBadge({super.key, required this.status});

  final CircleConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final reconnecting = status == CircleConnectionStatus.reconnecting;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: Container(
        key: ValueKey(status),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: reconnecting
              ? const Color(0xFFFFE8E1)
              : const Color(0xFFDBF3EE),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              reconnecting ? Icons.sync_rounded : Icons.wifi_tethering_rounded,
              size: 15,
              color: reconnecting
                  ? const Color(0xFF9C432C)
                  : const Color(0xFF126F68),
            ),
            const SizedBox(width: 6),
            Text(
              reconnecting ? 'Reconnecting' : 'Live updates',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
