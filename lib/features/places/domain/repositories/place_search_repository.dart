import '../entities/place_suggestion.dart';

abstract class PlaceSearchRepository {
  Future<List<PlaceSuggestion>> search(String query);
}
