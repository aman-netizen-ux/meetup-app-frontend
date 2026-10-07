import 'journey_mode.dart';
import 'journey_route_leg.dart';
import 'route_checkpoint.dart';

class JourneyRouteOption {
  const JourneyRouteOption({
    required this.id,
    required this.mode,
    required this.label,
    required this.accuracyLabel,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.legs,
    required this.checkpoints,
    this.encodedPolyline,
    this.polylinePrecision,
    this.expiresAt,
  });

  final String id;
  final JourneyMode mode;
  final String label;
  final String accuracyLabel;
  final int distanceMeters;
  final int durationSeconds;
  final String? encodedPolyline;
  final int? polylinePrecision;
  final List<JourneyRouteLeg> legs;
  final List<RouteCheckpoint> checkpoints;
  final DateTime? expiresAt;
}
