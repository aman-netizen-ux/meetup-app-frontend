import '../../domain/entities/journey_route_option.dart';
import 'route_selection_status.dart';

class RouteSelectionState {
  const RouteSelectionState({
    required this.status,
    this.options = const [],
    this.selected,
    this.message,
  });

  final RouteSelectionStatus status;
  final List<JourneyRouteOption> options;
  final JourneyRouteOption? selected;
  final String? message;
}
