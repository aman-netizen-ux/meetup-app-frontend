import '../../../../core/network/json_http_client.dart';

/// Feature-specific endpoints; returns wire JSON only.
class CircleRemoteDataSource {
  const CircleRemoteDataSource(this._http);

  final JsonHttpClient _http;

  Future<Map<String, dynamic>> listCircles() =>
      _http.request('GET', '/v1/circles');

  Future<Map<String, dynamic>> getCircle(String circleId) =>
      _http.request('GET', '/v1/circles/${Uri.encodeComponent(circleId)}');

  Future<Map<String, dynamic>?> waitForCircleChange(
    String circleId,
    int afterRevision,
  ) async {
    final json = await _http.request(
      'GET',
      '/v1/circles/${Uri.encodeComponent(circleId)}/events?afterRevision=$afterRevision',
      allowEmpty: true,
      timeout: const Duration(seconds: 35),
    );
    return json.isEmpty ? null : json;
  }

  Future<Map<String, dynamic>> getMyJourney(String circleId) =>
      _http.request('GET', '/v1/circles/${Uri.encodeComponent(circleId)}/me');

  Future<Map<String, dynamic>> createCircle(Map<String, dynamic> body) =>
      _http.request('POST', '/v1/circles', body: body);

  Future<Map<String, dynamic>> updateCircle(
    String circleId,
    Map<String, dynamic> body,
  ) => _http.request(
    'PATCH',
    '/v1/circles/${Uri.encodeComponent(circleId)}',
    body: body,
  );

  Future<Map<String, dynamic>> endCircle(String circleId, String reason) =>
      _http.request(
        'POST',
        '/v1/circles/${Uri.encodeComponent(circleId)}/end',
        body: {'reason': reason},
      );

  Future<Map<String, dynamic>> previewInvitation(String token) => _http.request(
    'GET',
    '/v1/invitations/${Uri.encodeComponent(token)}/preview',
    requiresAuth: false,
  );

  Future<Map<String, dynamic>> acceptInvitation(String token, String role) =>
      _http.request(
        'POST',
        '/v1/invitations/${Uri.encodeComponent(token)}/accept',
        body: {'travelRole': role},
      );

  Future<Map<String, dynamic>> changeMyRole(String circleId, String role) =>
      _http.request(
        'PATCH',
        '/v1/circles/${Uri.encodeComponent(circleId)}/me/role',
        body: {'travelRole': role},
      );

  Future<Map<String, dynamic>> createInvitationLink(String circleId) =>
      _http.request(
        'POST',
        '/v1/circles/${Uri.encodeComponent(circleId)}/invite-links',
        body: const {},
      );
}
