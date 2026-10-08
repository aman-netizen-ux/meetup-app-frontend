import '../../domain/entities/private_journey.dart';
import 'private_journey_status.dart';

class PrivateJourneyState {
  const PrivateJourneyState({required this.status, this.journey});

  final PrivateJourneyStatus status;
  final PrivateJourney? journey;
}
