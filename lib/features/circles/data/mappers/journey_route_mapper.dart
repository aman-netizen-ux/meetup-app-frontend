import '../../domain/entities/geo_point.dart';
import '../../domain/entities/journey_mode.dart';
import '../../domain/entities/journey_route_leg.dart';
import '../../domain/entities/journey_route_option.dart';
import '../../domain/entities/route_checkpoint.dart';

JourneyRouteOption mapJourneyRouteOption(Map<String, dynamic> json) =>
    JourneyRouteOption(
      id: json['id'] as String,
      mode: JourneyMode.values.byName(json['mode'] as String),
      label: json['label'] as String,
      accuracyLabel: json['accuracyLabel'] as String,
      distanceMeters: json['distanceMeters'] as int,
      durationSeconds: json['durationSeconds'] as int,
      encodedPolyline: json['encodedPolyline'] as String?,
      polylinePrecision: json['polylinePrecision'] as int?,
      legs: (json['legs'] as List<dynamic>)
          .map((value) => _mapLeg(value as Map<String, dynamic>))
          .toList(growable: false),
      checkpoints: (json['checkpoints'] as List<dynamic>)
          .map((value) => _mapCheckpoint(value as Map<String, dynamic>))
          .toList(growable: false),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

JourneyRouteLeg _mapLeg(Map<String, dynamic> json) => JourneyRouteLeg(
  mode: JourneyMode.values.byName(json['mode'] as String),
  label: json['label'] as String,
  distanceMeters: json['distanceMeters'] as int,
  durationSeconds: json['durationSeconds'] as int,
);

RouteCheckpoint _mapCheckpoint(Map<String, dynamic> json) => RouteCheckpoint(
  point: GeoPoint(
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
  ),
  label: json['label'] as String,
  sequence: json['sequence'] as int,
);
