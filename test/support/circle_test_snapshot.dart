import 'package:meetup_app_frontend/features/circles/domain/entities/circle_member.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/circle_snapshot.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/circle_state.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/destination.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/geo_point.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/member_presence.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/setup_status.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/travel_role.dart';

CircleSnapshot circleTestSnapshot({
  int revision = 0,
  SetupStatus setupStatus = SetupStatus.pending,
  TravelRole role = TravelRole.mover,
  MemberPresence presence = MemberPresence.notSharing,
}) => CircleSnapshot(
  id: 'circle-1',
  organizerId: 'user-1',
  destination: const Destination(
    label: 'Test destination',
    point: GeoPoint(latitude: 12.97, longitude: 77.59),
  ),
  isPrivatePlace: true,
  timeZone: 'Asia/Kolkata',
  state: CircleState.active,
  revision: revision,
  members: [
    CircleMember(
      userId: 'user-1',
      displayName: 'Test member',
      isOrganizer: true,
      travelRole: role,
      setupStatus: setupStatus,
      presence: presence,
    ),
  ],
);
