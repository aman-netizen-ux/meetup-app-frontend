import 'journey_mode.dart';

class JourneyRouteLeg {
  const JourneyRouteLeg({
    required this.mode,
    required this.label,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  final JourneyMode mode;
  final String label;
  final int distanceMeters;
  final int durationSeconds;
}
