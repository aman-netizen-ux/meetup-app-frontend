import '../entities/circle_snapshot.dart';
import '../entities/circle_summary.dart';
import '../entities/create_circle_input.dart';
import '../entities/join_preview.dart';
import '../entities/private_journey.dart';
import '../entities/travel_role.dart';
import '../entities/end_reason.dart';
import '../entities/invitation_link.dart';

abstract class CircleRepository {
  Future<List<CircleSummary>> listCircles();
  Future<CircleSnapshot> getCircle(String circleId);
  Future<PrivateJourney> getMyJourney(String circleId);
  Future<CircleSnapshot> createCircle(CreateCircleInput input);
  Future<CircleSnapshot> updateCircle(
    String circleId, {
    String? meetupDate,
    String? meetupTime,
    bool? isPrivatePlace,
  });
  Future<CircleSnapshot> endCircle(String circleId, EndReason reason);
  Future<JoinPreview> previewInvitation(String token);
  Future<CircleSnapshot> acceptInvitation(String token, TravelRole role);
  Future<CircleSnapshot> changeMyRole(String circleId, TravelRole role);
  Future<InvitationLink> createInvitationLink(String circleId);
  Future<CircleSnapshot?> waitForCircleChange(
    String circleId,
    int afterRevision,
  );
}
