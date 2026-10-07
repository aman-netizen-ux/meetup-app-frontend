import '../../domain/entities/circle_snapshot.dart';
import '../../domain/entities/circle_summary.dart';
import '../../domain/entities/create_circle_input.dart';
import '../../domain/entities/join_preview.dart';
import '../../domain/entities/private_journey.dart';
import '../../domain/entities/travel_role.dart';
import '../../domain/entities/end_reason.dart';
import '../../domain/entities/invitation_link.dart';
import '../../domain/repositories/circle_repository.dart';
import '../datasources/circle_remote_data_source.dart';
import '../mappers/circle_mapper.dart';

/// Converts wire JSON into domain entities behind the repository port.
class CircleRepositoryImpl implements CircleRepository {
  const CircleRepositoryImpl(this._remote);

  final CircleRemoteDataSource _remote;

  @override
  Future<List<CircleSummary>> listCircles() async {
    final json = await _remote.listCircles();
    return (json['items'] as List<dynamic>)
        .map((value) => mapCircleSummary(value as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<CircleSnapshot> getCircle(String circleId) async =>
      mapCircleSnapshot(await _remote.getCircle(circleId));

  @override
  Future<CircleSnapshot?> waitForCircleChange(
    String circleId,
    int afterRevision,
  ) async {
    final json = await _remote.waitForCircleChange(circleId, afterRevision);
    return json == null ? null : mapCircleSnapshot(json);
  }

  @override
  Future<PrivateJourney> getMyJourney(String circleId) async =>
      mapPrivateJourney(await _remote.getMyJourney(circleId));

  @override
  Future<CircleSnapshot> createCircle(CreateCircleInput input) async =>
      mapCircleSnapshot(
        await _remote.createCircle(serializeCreateCircle(input)),
      );

  @override
  Future<CircleSnapshot> updateCircle(
    String circleId, {
    String? meetupDate,
    String? meetupTime,
    bool? isPrivatePlace,
  }) async => mapCircleSnapshot(
    await _remote.updateCircle(circleId, {
      'meetupDate': ?meetupDate,
      'meetupTime': ?meetupTime,
      'isPrivatePlace': ?isPrivatePlace,
    }),
  );

  @override
  Future<CircleSnapshot> endCircle(String circleId, EndReason reason) async =>
      mapCircleSnapshot(
        await _remote.endCircle(
          circleId,
          reason.name == 'organizerEnded' ? 'organizer_ended' : reason.name,
        ),
      );

  @override
  Future<JoinPreview> previewInvitation(String token) async =>
      mapJoinPreview(await _remote.previewInvitation(token));

  @override
  Future<CircleSnapshot> acceptInvitation(
    String token,
    TravelRole role,
  ) async =>
      mapCircleSnapshot(await _remote.acceptInvitation(token, role.name));

  @override
  Future<CircleSnapshot> changeMyRole(String circleId, TravelRole role) async =>
      mapCircleSnapshot(await _remote.changeMyRole(circleId, role.name));

  @override
  Future<InvitationLink> createInvitationLink(String circleId) async {
    final json = await _remote.createInvitationLink(circleId);
    return InvitationLink(
      url: Uri.parse(json['url'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}
