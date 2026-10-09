import 'package:flutter/material.dart';

import 'state/location_sharing_controller.dart';
import 'state/location_sharing_state.dart';
import 'state/location_sharing_status.dart';

class LocationSharingCard extends StatelessWidget {
  const LocationSharingCard({
    super.key,
    required this.controller,
    required this.onPrepare,
  });

  final LocationSharingController controller;
  final VoidCallback onPrepare;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<LocationSharingState>(
    valueListenable: controller,
    builder: (context, state, _) {
      final monitoring =
          state.status == LocationSharingStatus.monitoringDeparture ||
          state.status == LocationSharingStatus.startingSharing;
      final sharing = state.status == LocationSharingStatus.sharing;
      final accent = sharing
          ? const Color(0xFF2D9D78)
          : monitoring
          ? const Color(0xFFFF765E)
          : const Color(0xFF168C83);
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              accent.withValues(alpha: 0.12),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: accent.withValues(alpha: 0.22)),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_icon(state.status), color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _title(state.status),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _subtitle(state),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (monitoring) ...[
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: (state.distanceFromStartMeters /
                          LocationSharingController.departureThresholdMeters)
                      .clamp(0, 1),
                  color: const Color(0xFFFF765E),
                  backgroundColor: const Color(0xFFFFE1D9),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${state.distanceFromStartMeters.round()} m from your private starting point',
                style: const TextStyle(
                  color: Color(0xFF8B574C),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            if (state.status == LocationSharingStatus.needsConsent ||
                state.status == LocationSharingStatus.failure) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onPrepare,
                  icon: const Icon(Icons.shield_outlined),
                  label: const Text('Prepare location sharing'),
                ),
              ),
            ],
            if (state.status == LocationSharingStatus.gpsPaused) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: controller.retryTracking,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Resume GPS updates'),
                ),
              ),
            ],
            if (monitoring) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: state.status == LocationSharingStatus.startingSharing
                      ? null
                      : controller.shareNow,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF765E),
                    foregroundColor: Colors.white,
                  ),
                  icon: state.status == LocationSharingStatus.startingSharing
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.near_me_rounded),
                  label: Text(
                    state.status == LocationSharingStatus.startingSharing
                        ? 'Starting…'
                        : 'Share now',
                  ),
                ),
              ),
            ],
            if (state.settingsRequired) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: controller.openSettings,
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Open app settings'),
              ),
            ],
          ],
        ),
      );
    },
  );

  String _title(LocationSharingStatus status) => switch (status) {
    LocationSharingStatus.inactive => 'Journey sharing is off',
    LocationSharingStatus.needsConsent => 'Ready when you are',
    LocationSharingStatus.locating => 'Finding your starting point…',
    LocationSharingStatus.monitoringDeparture => 'Watching for departure',
    LocationSharingStatus.startingSharing => 'Starting live sharing…',
    LocationSharingStatus.sharing => 'You’re sharing live',
    LocationSharingStatus.gpsPaused => 'GPS updates paused',
    LocationSharingStatus.failure => 'Location needs attention',
  };

  String _subtitle(LocationSharingState state) => state.message ?? switch (state.status) {
    LocationSharingStatus.needsConsent =>
      'Your start stays private. Friends see you only after you leave or tap Share now.',
    LocationSharingStatus.locating => 'This point is kept on your phone.',
    LocationSharingStatus.monitoringDeparture ||
    LocationSharingStatus.startingSharing =>
      'Sharing starts automatically at about 150 m.',
    LocationSharingStatus.sharing => 'Only members of this circle can see your pin.',
    LocationSharingStatus.gpsPaused =>
      'Reconnect before relying on the last shared position.',
    LocationSharingStatus.failure => 'Try again when location access is available.',
    LocationSharingStatus.inactive => 'No location is being collected.',
  };

  IconData _icon(LocationSharingStatus status) => switch (status) {
    LocationSharingStatus.sharing => Icons.radar_rounded,
    LocationSharingStatus.monitoringDeparture ||
    LocationSharingStatus.startingSharing => Icons.directions_walk_rounded,
    LocationSharingStatus.failure => Icons.location_disabled_rounded,
    LocationSharingStatus.gpsPaused => Icons.gps_off_rounded,
    LocationSharingStatus.inactive => Icons.location_off_outlined,
    _ => Icons.my_location_rounded,
  };
}
