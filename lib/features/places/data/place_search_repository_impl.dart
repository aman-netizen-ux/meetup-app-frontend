import '../../../core/network/json_http_client.dart';
import '../../circles/domain/entities/destination.dart';
import '../../circles/domain/entities/geo_point.dart';
import '../domain/entities/place_suggestion.dart';
import '../domain/repositories/place_search_repository.dart';

class PlaceSearchRepositoryImpl implements PlaceSearchRepository {
  const PlaceSearchRepositoryImpl(this._http);

  final JsonHttpClient _http;

  @override
  Future<List<PlaceSuggestion>> search(String query) async {
    final json = await _http.request('POST', '/v1/places/search', body: {'query': query});
    return (json['items'] as List<dynamic>)
        .map((value) {
          final item = value as Map<String, dynamic>;
          final title = item['label'] as String;
          return PlaceSuggestion(
            title: title,
            subtitle: item['secondaryLabel'] as String? ?? '',
            destination: Destination(
              label: title,
              point: GeoPoint(
                latitude: (item['latitude'] as num).toDouble(),
                longitude: (item['longitude'] as num).toDouble(),
              ),
              placeId: item['placeId'] as String?,
            ),
          );
        })
        .toList(growable: false);
  }
}
