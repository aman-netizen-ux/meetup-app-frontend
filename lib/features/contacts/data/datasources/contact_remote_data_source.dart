import '../../../../core/network/json_http_client.dart';

class ContactRemoteDataSource {
  const ContactRemoteDataSource(this._http);

  final JsonHttpClient _http;

  Future<Map<String, dynamic>> match(
    String circleId,
    List<Map<String, String>> contacts,
  ) => _http.request(
    'POST',
    '/v1/circles/${Uri.encodeComponent(circleId)}/contacts/match',
    body: {'contacts': contacts},
  );

  Future<Map<String, dynamic>> add(String circleId, String matchId) =>
      _http.request(
        'POST',
        '/v1/circles/${Uri.encodeComponent(circleId)}/contact-members',
        body: {'matchId': matchId},
      );
}
