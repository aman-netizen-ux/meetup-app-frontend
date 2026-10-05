import '../../domain/entities/destination.dart';

class CircleEditorState {
  const CircleEditorState({
    this.destination,
    this.date,
    this.time,
    this.isPrivatePlace = false,
    this.saving = false,
    this.error,
  });

  final Destination? destination;
  final DateTime? date;
  final String? time;
  final bool isPrivatePlace;
  final bool saving;
  final String? error;

  CircleEditorState copyWith({
    Destination? destination,
    DateTime? date,
    String? time,
    bool? isPrivatePlace,
    bool? saving,
    String? error,
  }) => CircleEditorState(
    destination: destination ?? this.destination,
    date: date ?? this.date,
    time: time ?? this.time,
    isPrivatePlace: isPrivatePlace ?? this.isPrivatePlace,
    saving: saving ?? this.saving,
    error: error,
  );
}
