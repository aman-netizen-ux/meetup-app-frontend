import 'package:flutter/foundation.dart';

import '../../domain/entities/circle_member.dart';
import '../../domain/entities/circle_snapshot.dart';
import '../../domain/entities/location_permission_result.dart';
import '../../domain/entities/travel_role.dart';
import '../../domain/repositories/circle_repository.dart';
import '../../domain/repositories/mover_location_permission.dart';
import 'member_role_state.dart';
import 'member_role_status.dart';

class MemberRoleController extends ValueNotifier<MemberRoleState> {
  MemberRoleController({
    required CircleRepository repository,
    required MoverLocationPermission permission,
    required String circleId,
    required String userId,
    required CircleMember initial,
  }) : _repository = repository,
       _permission = permission,
       _circleId = circleId,
       _userId = userId,
       super(
         MemberRoleState(
           role: initial.travelRole,
           setupStatus: initial.setupStatus,
         ),
       );

  final CircleRepository _repository;
  final MoverLocationPermission _permission;
  final String _circleId;
  final String _userId;

  Future<CircleSnapshot?> change(
    TravelRole role, {
    required bool requestLocation,
  }) async {
    if (value.status == MemberRoleStatus.saving ||
        value.status == MemberRoleStatus.requestingPermission) {
      return null;
    }
    if (requestLocation) {
      value = MemberRoleState(
        role: value.role,
        setupStatus: value.setupStatus,
        status: MemberRoleStatus.requestingPermission,
      );
      final permission = await _permission.requestForeground();
      if (permission != LocationPermissionResult.granted) {
        value = MemberRoleState(
          role: value.role,
          setupStatus: value.setupStatus,
          status: MemberRoleStatus.failure,
          settingsRequired:
              permission == LocationPermissionResult.permanentlyDenied,
          message: permission == LocationPermissionResult.serviceDisabled
              ? 'Turn on location services before choosing mover.'
              : 'Location permission is needed before an active mover can continue.',
        );
        return null;
      }
    }
    value = MemberRoleState(
      role: value.role,
      setupStatus: value.setupStatus,
      status: MemberRoleStatus.saving,
    );
    try {
      final circle = await _repository.changeMyRole(_circleId, role);
      final member = circle.members.firstWhere(
        (candidate) => candidate.userId == _userId,
      );
      value = MemberRoleState(
        role: member.travelRole,
        setupStatus: member.setupStatus,
      );
      return circle;
    } catch (_) {
      value = MemberRoleState(
        role: value.role,
        setupStatus: value.setupStatus,
        status: MemberRoleStatus.failure,
        message: 'Could not update your role. Try again.',
      );
      return null;
    }
  }

  void sync(CircleMember member) {
    if (value.status == MemberRoleStatus.saving ||
        value.status == MemberRoleStatus.requestingPermission) {
      return;
    }
    if (value.role == member.travelRole &&
        value.setupStatus == member.setupStatus &&
        value.status == MemberRoleStatus.idle) {
      return;
    }
    value = MemberRoleState(
      role: member.travelRole,
      setupStatus: member.setupStatus,
    );
  }

  Future<void> openSettings() => _permission.openSettings();
}
