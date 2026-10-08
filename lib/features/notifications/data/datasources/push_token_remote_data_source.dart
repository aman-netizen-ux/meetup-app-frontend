import '../../../../core/network/json_http_client.dart';

class PushTokenRemoteDataSource {
  const PushTokenRemoteDataSource(this._http);

  final JsonHttpClient _http;

  Future<void> register(String platform, String token) async {
    await _http.request(
      'POST',
      '/v1/me/device-tokens',
      body: {'platform': platform, 'token': token},
      allowEmpty: true,
    );
  }
}
