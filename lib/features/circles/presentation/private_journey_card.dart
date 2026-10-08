import 'package:flutter/material.dart';

import '../../../core/presentation/shimmer_block.dart';
import 'state/private_journey_controller.dart';
import 'state/private_journey_state.dart';
import 'state/private_journey_status.dart';

class PrivateJourneyCard extends StatelessWidget {
  const PrivateJourneyCard({
    super.key,
    required this.controller,
    required this.hasMeetupTime,
  });

  final PrivateJourneyController controller;
  final bool hasMeetupTime;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<PrivateJourneyState>(
    valueListenable: controller,
    builder: (context, state, _) {
      final journey = state.journey;
      if (state.status == PrivateJourneyStatus.hidden ||
          (state.status == PrivateJourneyStatus.ready && journey?.etaMinutes == null)) {
        return const SizedBox.shrink();
      }
      if (state.status == PrivateJourneyStatus.loading && journey == null) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: ShimmerBlock(height: 146),
        );
      }
      if (state.status == PrivateJourneyStatus.failure && journey == null) {
        return OutlinedButton.icon(
          onPressed: controller.load,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Refresh your ETA'),
        );
      }
      final eta = journey!.etaMinutes!;
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE7F7F3), Color(0xFFFFF2E8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0x332D9D78)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: Color(0xFF168C83),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.schedule_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your ETA',
                        style: TextStyle(
                          color: Color(0xFF17283E),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        eta.min == eta.max
                            ? '${eta.min} min'
                            : '${eta.min}–${eta.max} min',
                        style: const TextStyle(
                          color: Color(0xFF17283E),
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.status == PrivateJourneyStatus.loading)
                  const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  hasMeetupTime ? Icons.notifications_active_outlined : Icons.lock_clock_outlined,
                  size: 18,
                  color: const Color(0xFF58706D),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasMeetupTime
                        ? _leaveMessage(journey.leaveByAt)
                        : 'Personal travel estimate. No early or late label because this circle has no meetup time.',
                    style: const TextStyle(
                      color: Color(0xFF58706D),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            if (hasMeetupTime && journey.arrivalDeltaMinutes != null) ...[
              const SizedBox(height: 10),
              Text(
                _arrivalMessage(journey.arrivalDeltaMinutes!),
                style: const TextStyle(
                  color: Color(0xFF17283E),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      );
    },
  );

  String _leaveMessage(DateTime? leaveByAt) {
    if (leaveByAt == null) return 'Your leave-by reminder will appear after a route update.';
    final minutes = leaveByAt.difference(DateTime.now()).inMinutes;
    if (minutes <= 0) return 'It’s time to leave based on the slower end of your ETA range.';
    if (minutes < 60) return 'Plan to leave in about $minutes min.';
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    return remainder == 0
        ? 'Plan to leave in about $hours hr.'
        : 'Plan to leave in about $hours hr $remainder min.';
  }

  String _arrivalMessage(int deltaMinutes) {
    if (deltaMinutes == 0) return 'You arrived around the meetup time.';
    return deltaMinutes < 0
        ? 'You arrived ${deltaMinutes.abs()} min early.'
        : 'You arrived $deltaMinutes min after the meetup time.';
  }
}
