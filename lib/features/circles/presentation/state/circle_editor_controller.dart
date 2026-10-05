import 'package:flutter/foundation.dart';

import '../../domain/entities/circle_snapshot.dart';
import '../../domain/entities/create_circle_input.dart';
import '../../domain/entities/destination.dart';
import '../../domain/repositories/circle_repository.dart';
import 'circle_editor_state.dart';

class CircleEditorController extends ValueNotifier<CircleEditorState> {
  CircleEditorController(this._repository) : super(const CircleEditorState());

  final CircleRepository _repository;

  void setDestination(Destination destination) =>
      value = value.copyWith(destination: destination);
  void setDate(DateTime date) => value = value.copyWith(date: date);
  void setTime(String time) => value = value.copyWith(time: time);
  void setPrivatePlace(bool enabled) =>
      value = value.copyWith(isPrivatePlace: enabled);

  Future<CircleSnapshot?> create() async {
    final destination = value.destination;
    if (destination == null) {
      value = value.copyWith(error: 'Choose a destination first.');
      return null;
    }
    value = value.copyWith(saving: true);
    try {
      final date = value.date;
      final dateString = date == null
          ? null
          : '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final circle = await _repository.createCircle(
        CreateCircleInput(
          destination: destination,
          isPrivatePlace: value.isPrivatePlace,
          meetupDate: dateString,
          meetupTime: value.time,
        ),
      );
      value = value.copyWith(saving: false);
      return circle;
    } catch (_) {
      value = value.copyWith(
        saving: false,
        error: 'Could not create this circle. Check the details and try again.',
      );
      return null;
    }
  }
}
