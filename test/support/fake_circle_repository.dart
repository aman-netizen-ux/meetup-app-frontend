import 'dart:async';

import 'package:meetup_app_frontend/features/circles/domain/entities/circle_member.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/circle_snapshot.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/circle_summary.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/create_circle_input.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/end_reason.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/invitation_link.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/join_preview.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/private_journey.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/setup_status.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/travel_role.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/device_location.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/sharing_trigger.dart';
import 'package:meetup_app_frontend/features/circles/domain/entities/journey_route_option.dart';
import 'package:meetup_app_frontend/features/circles/domain/repositories/circle_repository.dart';

class FakeCircleRepository implements CircleRepository {
  FakeCircleRepository(this.snapshot);

  CircleSnapshot snapshot;
  int roleChanges = 0;
  int sharingStarts = 0;
  int locationUpdates = 0;
  List<JourneyRouteOption> routeOptions = const [];
  JourneyRouteOption? selectedRoute;
  PrivateJourney privateJourney = const PrivateJourney(
    travelRole: TravelRole.mover,
  );
  SharingTrigger? lastSharingTrigger;
  Completer<CircleSnapshot?> _nextChange = Completer();

  void emit(CircleSnapshot value) {
    snapshot = value;
    _nextChange.complete(value);
    _nextChange = Completer();
  }

  @override
  Future<CircleSnapshot> changeMyRole(String circleId, TravelRole role) async {
    roleChanges++;
    final members = snapshot.members
        .map(
          (member) => CircleMember(
            userId: member.userId,
            displayName: member.displayName,
            isOrganizer: member.isOrganizer,
            travelRole: role,
            setupStatus: SetupStatus.ready,
            presence: member.presence,
            pin: member.pin,
            lastUpdatedAt: member.lastUpdatedAt,
            currentLeg: member.currentLeg,
            etaMinutes: member.etaMinutes,
            arrivedAt: member.arrivedAt,
          ),
        )
        .toList(growable: false);
    snapshot = CircleSnapshot(
      id: snapshot.id,
      organizerId: snapshot.organizerId,
      destination: snapshot.destination,
      isPrivatePlace: snapshot.isPrivatePlace,
      timeZone: snapshot.timeZone,
      state: snapshot.state,
      revision: snapshot.revision + 1,
      members: members,
      meetupDate: snapshot.meetupDate,
      meetupTime: snapshot.meetupTime,
      endReason: snapshot.endReason,
    );
    return snapshot;
  }

  @override
  Future<CircleSnapshot?> waitForCircleChange(
    String circleId,
    int afterRevision,
  ) => _nextChange.future;

  @override
  Future<CircleSnapshot> getCircle(String circleId) async => snapshot;

  @override
  Future<List<CircleSummary>> listCircles() => throw UnimplementedError();

  @override
  Future<PrivateJourney> getMyJourney(String circleId) async => privateJourney;

  @override
  Future<CircleSnapshot> createCircle(CreateCircleInput input) =>
      throw UnimplementedError();

  @override
  Future<CircleSnapshot> updateCircle(
    String circleId, {
    String? meetupDate,
    String? meetupTime,
    bool? isPrivatePlace,
  }) => throw UnimplementedError();

  @override
  Future<CircleSnapshot> endCircle(String circleId, EndReason reason) =>
      throw UnimplementedError();

  @override
  Future<JoinPreview> previewInvitation(String token) =>
      throw UnimplementedError();

  @override
  Future<CircleSnapshot> acceptInvitation(String token, TravelRole role) =>
      throw UnimplementedError();

  @override
  Future<InvitationLink> createInvitationLink(String circleId) =>
      throw UnimplementedError();

  @override
  Future<CircleSnapshot> startLocationSharing(
    String circleId,
    SharingTrigger trigger,
    DeviceLocation location,
  ) async {
    sharingStarts++;
    lastSharingTrigger = trigger;
    return snapshot;
  }

  @override
  Future<CircleSnapshot> sendLocation(
    String circleId,
    DeviceLocation location,
  ) async {
    locationUpdates++;
    return snapshot;
  }

  @override
  Future<List<JourneyRouteOption>> getRouteOptions(String circleId) async =>
      routeOptions;

  @override
  Future<JourneyRouteOption?> getSelectedRoute(String circleId) async =>
      selectedRoute;

  @override
  Future<JourneyRouteOption> selectRoute(
    String circleId,
    String optionId,
  ) async {
    selectedRoute = routeOptions.firstWhere((option) => option.id == optionId);
    return selectedRoute!;
  }
}
