import 'destination.dart';

class CreateCircleInput {
  const CreateCircleInput({
    required this.destination,
    required this.isPrivatePlace,
    this.meetupDate,
    this.meetupTime,
  });

  final Destination destination;
  final bool isPrivatePlace;
  final String? meetupDate;
  final String? meetupTime;
}
