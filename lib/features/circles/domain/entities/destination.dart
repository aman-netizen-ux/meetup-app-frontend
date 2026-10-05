import 'geo_point.dart';

class Destination {
  const Destination({required this.label, required this.point, this.placeId});

  final String label;
  final GeoPoint point;
  final String? placeId;
}
