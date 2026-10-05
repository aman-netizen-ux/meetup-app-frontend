import '../../domain/entities/place_suggestion.dart';

class PlacePickerState {
  const PlacePickerState({
    this.items = const [],
    this.loading = false,
    this.message,
  });

  final List<PlaceSuggestion> items;
  final bool loading;
  final String? message;
}
