import 'geo_point.dart';

class RouteCheckpoint {
  const RouteCheckpoint({
    required this.point,
    required this.label,
    required this.sequence,
  });

  final GeoPoint point;
  final String label;
  final int sequence;
}
