import '../../domain/entities/circle_summary.dart';
import 'circles_home_status.dart';

class CirclesHomeState {
  const CirclesHomeState({
    required this.status,
    this.circles = const [],
    this.errorMessage,
  });

  final CirclesHomeStatus status;
  final List<CircleSummary> circles;
  final String? errorMessage;
}
