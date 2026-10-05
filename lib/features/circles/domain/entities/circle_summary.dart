import 'circle_state.dart';
import 'travel_role.dart';

class CircleSummary {
  const CircleSummary({
    required this.id,
    required this.destinationLabel,
    required this.timeZone,
    required this.state,
    required this.myRole,
    required this.isOrganizer,
    required this.memberCount,
    this.meetupDate,
    this.meetupTime,
  });

  final String id;
  final String destinationLabel;
  final String? meetupDate;
  final String? meetupTime;
  final String timeZone;
  final CircleState state;
  final TravelRole myRole;
  final bool isOrganizer;
  final int memberCount;
}
