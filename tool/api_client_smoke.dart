import 'dart:convert';
import 'dart:io';

import 'package:meetup_app_frontend/core/network/api_error.dart';
import 'package:meetup_app_frontend/core/network/json_http_client.dart';
import 'package:meetup_app_frontend/features/circles/data/datasources/circle_remote_data_source.dart';
import 'package:meetup_app_frontend/features/circles/data/repositories/circle_repository_impl.dart';

Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  final subscription = server.listen((request) async {
    request.response.headers.contentType = ContentType.json;
    switch (request.uri.path) {
      case '/v1/circles':
        if (request.headers.value(HttpHeaders.authorizationHeader) !=
            'Bearer test-token') {
          throw StateError(
            'Authenticated call did not carry its bearer token.',
          );
        }
        request.response.write(
          jsonEncode({
            'items': [
              {
                'id': 'cir_123',
                'destination': {'label': 'Central Cafe'},
                'meetupDate': null,
                'meetupTime': '18:30',
                'timeZone': 'Asia/Kolkata',
                'state': 'active',
                'myRole': 'mover',
                'isOrganizer': false,
                'memberCount': 2,
              },
            ],
          }),
        );
      case '/v1/invitations/token/preview':
        if (request.headers.value(HttpHeaders.authorizationHeader) != null) {
          throw StateError('Invitation preview must not send a bearer token.');
        }
        request.response.write(
          jsonEncode({
            'destination': {
              'label': 'Central Cafe',
              'latitude': 12.97,
              'longitude': 77.59,
              'placeId': null,
            },
            'state': 'active',
            'isPrivatePlace': false,
            'memberNames': ['Meera'],
          }),
        );
      default:
        request.response.statusCode = HttpStatus.unprocessableEntity;
        request.response.write(
          jsonEncode({
            'error': {
              'code': 'ROLE_NOT_ALLOWED',
              'message': 'Role not allowed.',
            },
          }),
        );
    }
    await request.response.close();
  });

  final http = JsonHttpClient(
    baseUri: Uri.parse('http://127.0.0.1:${server.port}'),
    accessTokenProvider: () async => 'test-token',
  );
  final repository = CircleRepositoryImpl(CircleRemoteDataSource(http));
  try {
    final circles = await repository.listCircles();
    if (circles.length != 1 ||
        circles.single.meetupDate != null ||
        circles.single.meetupTime != '18:30') {
      throw StateError('Independent date/time fields were not parsed.');
    }
    final preview = await repository.previewInvitation('token');
    if (preview.memberNames.single != 'Meera') {
      throw StateError('Invitation preview was not parsed.');
    }
    try {
      await repository.getCircle('bad');
      throw StateError('Expected an API error.');
    } on ApiError catch (error) {
      if (error.code != 'ROLE_NOT_ALLOWED' || error.statusCode != 422) {
        rethrow;
      }
    }
    stdout.writeln('API client smoke check passed.');
  } finally {
    http.close();
    await subscription.cancel();
    await server.close(force: true);
  }
}
