import 'circle_state.dart';
import 'destination.dart';

class JoinPreview {
  const JoinPreview({
    required this.destination,
    required this.state,
    required this.isPrivatePlace,
    required this.memberNames,
  });

  final Destination destination;
  final CircleState state;
  final bool isPrivatePlace;
  final List<String> memberNames;
}
