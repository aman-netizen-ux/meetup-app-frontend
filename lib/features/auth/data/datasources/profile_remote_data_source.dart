import '../../../../core/network/json_http_client.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._http);

  final JsonHttpClient _http;

  Future<Map<String, dynamic>> loadProfile() => _http.request('GET', '/v1/me');

  Future<Map<String, dynamic>> updateDisplayName(String displayName) =>
      _http.request('PATCH', '/v1/me', body: {'displayName': displayName});
}
