import '../../domain/entities/setup_status.dart';
import '../../domain/entities/travel_role.dart';
import 'member_role_status.dart';

class MemberRoleState {
  const MemberRoleState({
    required this.role,
    required this.setupStatus,
    this.status = MemberRoleStatus.idle,
    this.message,
    this.settingsRequired = false,
  });

  final TravelRole role;
  final SetupStatus setupStatus;
  final MemberRoleStatus status;
  final String? message;
  final bool settingsRequired;
}
