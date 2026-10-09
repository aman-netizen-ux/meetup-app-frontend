import '../../../../core/network/json_http_client.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._http);

  final JsonHttpClient _http;

  /// A free staging service can be suspended between app sessions. Give the
  /// first authenticated request enough time to wake it instead of treating a
  /// valid restored Firebase session as an account failure.
  Future<Map<String, dynamic>> loadProfile() => _http.request(
    'GET',
    '/v1/me',
    timeout: const Duration(seconds: 75),
  );

  Future<Map<String, dynamic>> updateDisplayName(String displayName) =>
      _http.request('PATCH', '/v1/me', body: {'displayName': displayName});
}
