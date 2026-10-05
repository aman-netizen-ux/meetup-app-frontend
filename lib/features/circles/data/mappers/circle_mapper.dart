import '../../domain/entities/circle_member.dart';
import '../../domain/entities/circle_snapshot.dart';
import '../../domain/entities/circle_state.dart';
import '../../domain/entities/circle_summary.dart';
import '../../domain/entities/create_circle_input.dart';
import '../../domain/entities/current_leg.dart';
import '../../domain/entities/destination.dart';
import '../../domain/entities/end_reason.dart';
import '../../domain/entities/eta_range.dart';
import '../../domain/entities/geo_point.dart';
import '../../domain/entities/join_preview.dart';
import '../../domain/entities/member_presence.dart';
import '../../domain/entities/private_journey.dart';
import '../../domain/entities/setup_status.dart';
import '../../domain/entities/travel_role.dart';

/// JSON conversion lives in data; domain entities never import transport code.
CircleSummary mapCircleSummary(Map<String, dynamic> json) => CircleSummary(
  id: json['id'] as String,
  destinationLabel:
      (json['destination'] as Map<String, dynamic>)['label'] as String,
  meetupDate: json['meetupDate'] as String?,
  meetupTime: json['meetupTime'] as String?,
  timeZone: json['timeZone'] as String,
  state: CircleState.values.byName(json['state'] as String),
  myRole: TravelRole.values.byName(json['myRole'] as String),
  isOrganizer: json['isOrganizer'] as bool,
  memberCount: json['memberCount'] as int,
);

CircleSnapshot mapCircleSnapshot(Map<String, dynamic> json) => CircleSnapshot(
  id: json['id'] as String,
  organizerId: json['organizerId'] as String,
  destination: _mapDestination(json['destination'] as Map<String, dynamic>),
  isPrivatePlace: json['isPrivatePlace'] as bool,
  meetupDate: json['meetupDate'] as String?,
  meetupTime: json['meetupTime'] as String?,
  timeZone: json['timeZone'] as String,
  state: CircleState.values.byName(json['state'] as String),
  endReason: json['endReason'] == null
      ? null
      : _mapEndReason(json['endReason'] as String),
  revision: json['revision'] as int,
  members: (json['members'] as List<dynamic>)
      .map((value) => _mapMember(value as Map<String, dynamic>))
      .toList(growable: false),
);

JoinPreview mapJoinPreview(Map<String, dynamic> json) => JoinPreview(
  destination: _mapDestination(json['destination'] as Map<String, dynamic>),
  state: CircleState.values.byName(json['state'] as String),
  isPrivatePlace: json['isPrivatePlace'] as bool,
  memberNames: (json['memberNames'] as List<dynamic>).cast<String>(),
);

PrivateJourney mapPrivateJourney(Map<String, dynamic> json) => PrivateJourney(
  travelRole: TravelRole.values.byName(json['travelRole'] as String),
  etaMinutes: json['etaMinutes'] == null
      ? null
      : _mapEta(json['etaMinutes'] as Map<String, dynamic>),
  leaveByAt: _mapDateTime(json['leaveByAt']),
  arrivalDeltaMinutes: json['arrivalDeltaMinutes'] as int?,
);

Map<String, dynamic> serializeCreateCircle(CreateCircleInput input) => {
  'destination': {
    'label': input.destination.label,
    'latitude': input.destination.point.latitude,
    'longitude': input.destination.point.longitude,
    'placeId': input.destination.placeId,
  },
  'isPrivatePlace': input.isPrivatePlace,
  'meetupDate': input.meetupDate,
  'meetupTime': input.meetupTime,
};

Destination _mapDestination(Map<String, dynamic> json) => Destination(
  label: json['label'] as String,
  point: _mapPoint(json),
  placeId: json['placeId'] as String?,
);

GeoPoint _mapPoint(Map<String, dynamic> json) => GeoPoint(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
);

CircleMember _mapMember(Map<String, dynamic> json) => CircleMember(
  userId: json['userId'] as String,
  displayName: json['displayName'] as String,
  isOrganizer: json['isOrganizer'] as bool,
  travelRole: TravelRole.values.byName(json['travelRole'] as String),
  setupStatus: SetupStatus.values.byName(json['setupStatus'] as String),
  presence: _mapPresence(json['presence'] as String),
  pin: json['pin'] == null
      ? null
      : _mapPoint(json['pin'] as Map<String, dynamic>),
  lastUpdatedAt: _mapDateTime(json['lastUpdatedAt']),
  currentLeg: json['currentLeg'] == null
      ? null
      : _mapLeg(json['currentLeg'] as Map<String, dynamic>),
  etaMinutes: json['etaMinutes'] == null
      ? null
      : _mapEta(json['etaMinutes'] as Map<String, dynamic>),
  arrivedAt: _mapDateTime(json['arrivedAt']),
);

EtaRange _mapEta(Map<String, dynamic> json) =>
    EtaRange(min: json['min'] as int, max: json['max'] as int);

CurrentLeg _mapLeg(Map<String, dynamic> json) =>
    CurrentLeg(mode: json['mode'] as String, label: json['label'] as String);

MemberPresence _mapPresence(String value) => switch (value) {
  'not_sharing' => MemberPresence.notSharing,
  'live' => MemberPresence.live,
  'in_transit' => MemberPresence.inTransit,
  'here' => MemberPresence.here,
  'fixed' => MemberPresence.fixed,
  'frozen' => MemberPresence.frozen,
  _ => throw FormatException('Unknown member presence: $value'),
};

EndReason _mapEndReason(String value) => switch (value) {
  'all_arrived' => EndReason.allArrived,
  'organizer_ended' => EndReason.organizerEnded,
  'cancelled' => EndReason.cancelled,
  'timeout' => EndReason.timeout,
  _ => throw FormatException('Unknown end reason: $value'),
};

DateTime? _mapDateTime(Object? value) =>
    value == null ? null : DateTime.parse(value as String);
