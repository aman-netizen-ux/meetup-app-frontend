import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/circle_member.dart';
import '../../domain/entities/circle_snapshot.dart';
import '../../domain/entities/circle_state.dart';
import '../../domain/entities/device_location.dart';
import '../../domain/entities/location_permission_result.dart';
import '../../domain/entities/member_presence.dart';
import '../../domain/entities/setup_status.dart';
import '../../domain/entities/sharing_trigger.dart';
import '../../domain/entities/travel_role.dart';
import '../../domain/location_distance.dart';
import '../../domain/repositories/circle_repository.dart';
import '../../domain/repositories/device_location_tracker.dart';
import '../../domain/repositories/mover_location_permission.dart';
import 'location_sharing_state.dart';
import 'location_sharing_status.dart';

class LocationSharingController extends ValueNotifier<LocationSharingState> {
  LocationSharingController({
    required CircleRepository repository,
    required MoverLocationPermission permission,
    required DeviceLocationTracker tracker,
    required String circleId,
    required String userId,
    required ValueChanged<CircleSnapshot> onSnapshot,
    LocationDistance distance = const LocationDistance(),
  }) : _repository = repository,
       _permission = permission,
       _tracker = tracker,
       _circleId = circleId,
       _userId = userId,
       _onSnapshot = onSnapshot,
       _distance = distance,
       super(
         const LocationSharingState(
           status: LocationSharingStatus.inactive,
         ),
       );

  static const departureThresholdMeters = 150.0;
  static const uploadInterval = Duration(seconds: 12);

  final CircleRepository _repository;
  final MoverLocationPermission _permission;
  final DeviceLocationTracker _tracker;
  final String _circleId;
  final String _userId;
  final ValueChanged<CircleSnapshot> _onSnapshot;
  final LocationDistance _distance;
  StreamSubscription<DeviceLocation>? _subscription;
  DeviceLocation? _start;
  DeviceLocation? _latest;
  DateTime? _lastUploadAt;
  bool _uploading = false;
  bool _disposed = false;

  void sync(CircleSnapshot circle) {
    final member = circle.members.where((item) => item.userId == _userId).firstOrNull;
    if (member == null || !_eligible(circle, member)) {
      _stop(_inactiveMessage(circle, member));
      return;
    }
    if (member.presence == MemberPresence.live ||
        member.presence == MemberPresence.inTransit) {
      if (value.status != LocationSharingStatus.sharing) {
        value = const LocationSharingState(
          status: LocationSharingStatus.sharing,
          message: 'Your live location is visible to this circle.',
        );
      }
      _listen();
      return;
    }
    if (value.status == LocationSharingStatus.inactive ||
        value.status == LocationSharingStatus.sharing) {
      _cancelStream();
      value = const LocationSharingState(
        status: LocationSharingStatus.needsConsent,
      );
    }
  }

  Future<void> enable() async {
    if (value.status == LocationSharingStatus.locating) return;
    value = const LocationSharingState(status: LocationSharingStatus.locating);
    final permission = await _permission.requestForeground();
    if (_disposed) return;
    if (permission != LocationPermissionResult.granted) {
      value = LocationSharingState(
        status: LocationSharingStatus.failure,
        settingsRequired:
            permission == LocationPermissionResult.permanentlyDenied,
        message: permission == LocationPermissionResult.serviceDisabled
            ? 'Turn on device location to prepare sharing.'
            : 'Location permission is needed to detect when you leave.',
      );
      return;
    }
    try {
      _start = await _tracker.current();
      if (_disposed) return;
      _latest = _start;
      value = const LocationSharingState(
        status: LocationSharingStatus.monitoringDeparture,
        message: 'Your starting point stays only on this phone.',
      );
      _listen();
    } catch (_) {
      if (_disposed) return;
      value = const LocationSharingState(
        status: LocationSharingStatus.failure,
        message: 'Meetup could not get your current location. Try again.',
      );
    }
  }

  Future<void> shareNow() async {
    final location = _latest ?? _start;
    if (location == null ||
        value.status != LocationSharingStatus.monitoringDeparture) {
      return;
    }
    await _startSharing(SharingTrigger.manual, location);
  }

  Future<void> openSettings() => _permission.openSettings();

  bool _eligible(CircleSnapshot circle, CircleMember member) =>
      circle.state == CircleState.active &&
      member.travelRole == TravelRole.mover &&
      member.setupStatus == SetupStatus.ready &&
      member.arrivedAt == null &&
      member.presence != MemberPresence.here;

  String _inactiveMessage(CircleSnapshot circle, CircleMember? member) {
    if (circle.state == CircleState.scheduled) {
      return 'Sharing becomes available on the meetup date.';
    }
    if (circle.state == CircleState.ended) return 'This circle has ended.';
    if (member?.travelRole == TravelRole.anchor) {
      return 'Anchors do not share a journey location.';
    }
    if (member?.arrivedAt != null || member?.presence == MemberPresence.here) {
      return 'You are here. Location sharing has stopped.';
    }
    return 'Finish your role setup to prepare location sharing.';
  }

  void _listen() {
    _subscription ??= _tracker.positions().listen(
      _onPosition,
      onError: (_) {
        if (_disposed) return;
        value = const LocationSharingState(
          status: LocationSharingStatus.failure,
          message: 'Location updates paused. Check location access and retry.',
        );
      },
    );
  }

  Future<void> _onPosition(DeviceLocation location) async {
    if (_disposed) return;
    _latest = location;
    if (value.status == LocationSharingStatus.monitoringDeparture &&
        _start != null) {
      final meters = _distance.metersBetween(_start!, location);
      value = LocationSharingState(
        status: LocationSharingStatus.monitoringDeparture,
        distanceFromStartMeters: meters,
        message: 'Your starting point stays only on this phone.',
      );
      if (meters >= departureThresholdMeters) {
        await _startSharing(SharingTrigger.departure, location);
      }
      return;
    }
    if (value.status != LocationSharingStatus.sharing || _uploading) return;
    final lastUpload = _lastUploadAt;
    if (lastUpload != null &&
        location.capturedAt.difference(lastUpload) < uploadInterval) {
      return;
    }
    _uploading = true;
    try {
      final snapshot = await _repository.sendLocation(_circleId, location);
      _lastUploadAt = location.capturedAt;
      _onSnapshot(snapshot);
    } catch (_) {
      if (!_disposed) {
        value = const LocationSharingState(
          status: LocationSharingStatus.sharing,
          message: 'Live sharing is reconnecting…',
        );
      }
    } finally {
      _uploading = false;
    }
  }

  Future<void> _startSharing(
    SharingTrigger trigger,
    DeviceLocation location,
  ) async {
    value = LocationSharingState(
      status: LocationSharingStatus.startingSharing,
      distanceFromStartMeters: value.distanceFromStartMeters,
    );
    try {
      final snapshot = await _repository.startLocationSharing(
        _circleId,
        trigger,
        location,
      );
      _lastUploadAt = location.capturedAt;
      if (_disposed) return;
      value = const LocationSharingState(
        status: LocationSharingStatus.sharing,
        message: 'Your live location is visible to this circle.',
      );
      _onSnapshot(snapshot);
    } catch (_) {
      if (_disposed) return;
      value = LocationSharingState(
        status: LocationSharingStatus.monitoringDeparture,
        distanceFromStartMeters: value.distanceFromStartMeters,
        message: 'Sharing could not start. Check your connection and retry.',
      );
    }
  }

  void _stop(String message) {
    _cancelStream();
    _start = null;
    _latest = null;
    if (value.status != LocationSharingStatus.inactive ||
        value.message != message) {
      value = LocationSharingState(
        status: LocationSharingStatus.inactive,
        message: message,
      );
    }
  }

  void _cancelStream() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelStream();
    super.dispose();
  }
}
