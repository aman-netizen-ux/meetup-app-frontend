import 'location_sharing_status.dart';

class LocationSharingState {
  const LocationSharingState({
    required this.status,
    this.distanceFromStartMeters = 0,
    this.message,
    this.settingsRequired = false,
  });

  final LocationSharingStatus status;
  final double distanceFromStartMeters;
  final String? message;
  final bool settingsRequired;
}
