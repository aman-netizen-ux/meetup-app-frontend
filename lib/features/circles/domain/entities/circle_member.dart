import 'current_leg.dart';
import 'eta_range.dart';
import 'geo_point.dart';
import 'member_presence.dart';
import 'setup_status.dart';
import 'travel_role.dart';

class CircleMember {
  const CircleMember({
    required this.userId,
    required this.displayName,
    required this.isOrganizer,
    required this.travelRole,
    required this.setupStatus,
    required this.presence,
    this.pin,
    this.lastUpdatedAt,
    this.currentLeg,
    this.etaMinutes,
    this.arrivedAt,
  });

  final String userId;
  final String displayName;
  final bool isOrganizer;
  final TravelRole travelRole;
  final SetupStatus setupStatus;
  final MemberPresence presence;
  final GeoPoint? pin;
  final DateTime? lastUpdatedAt;
  final CurrentLeg? currentLeg;
  final EtaRange? etaMinutes;
  final DateTime? arrivedAt;
}
