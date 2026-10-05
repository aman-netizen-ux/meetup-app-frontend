import 'eta_range.dart';
import 'travel_role.dart';

class PrivateJourney {
  const PrivateJourney({
    required this.travelRole,
    this.etaMinutes,
    this.leaveByAt,
    this.arrivalDeltaMinutes,
  });

  final TravelRole travelRole;
  final EtaRange? etaMinutes;
  final DateTime? leaveByAt;
  final int? arrivalDeltaMinutes;
}
