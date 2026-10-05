import 'circle_member.dart';
import 'circle_state.dart';
import 'destination.dart';
import 'end_reason.dart';

class CircleSnapshot {
  const CircleSnapshot({
    required this.id,
    required this.organizerId,
    required this.destination,
    required this.isPrivatePlace,
    required this.timeZone,
    required this.state,
    required this.revision,
    required this.members,
    this.meetupDate,
    this.meetupTime,
    this.endReason,
  });

  final String id;
  final String organizerId;
  final Destination destination;
  final bool isPrivatePlace;
  final String? meetupDate;
  final String? meetupTime;
  final String timeZone;
  final CircleState state;
  final EndReason? endReason;
  final int revision;
  final List<CircleMember> members;
}
