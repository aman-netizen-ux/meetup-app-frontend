import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'access_token_provider.dart';
import 'api_error.dart';

/// Transport only: authentication header, JSON, timeouts, and HTTP errors.
class JsonHttpClient {
  JsonHttpClient({
    required Uri baseUri,
    required AccessTokenProvider accessTokenProvider,
    HttpClient? httpClient,
  }) : _baseUri = baseUri,
       _accessTokenProvider = accessTokenProvider,
       _httpClient = httpClient ?? HttpClient();

  final Uri _baseUri;
  final AccessTokenProvider _accessTokenProvider;
  final HttpClient _httpClient;
  static const _requestTimeout = Duration(seconds: 15);

  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      String? token;
      if (requiresAuth) {
        token = await _accessTokenProvider();
        if (token == null || token.isEmpty) {
          throw const ApiError(
            code: 'AUTH_REQUIRED',
            message: 'Sign in to continue.',
            statusCode: 401,
          );
        }
      }

      final request = await _httpClient
          .openUrl(method, _baseUri.resolve(path))
          .timeout(_requestTimeout);
      request.headers.contentType = ContentType.json;
      if (token != null) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
      if (body != null) request.write(jsonEncode(body));

      final response = await request.close().timeout(_requestTimeout);
      final responseText = await utf8.decoder
          .bind(response)
          .join()
          .timeout(_requestTimeout);
      Map<String, dynamic> json;
      try {
        json = jsonDecode(responseText) as Map<String, dynamic>;
      } on FormatException {
        throw ApiError(
          code: 'INVALID_RESPONSE',
          message: 'The server returned an invalid response.',
          statusCode: response.statusCode,
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        if (json['error'] is Map<String, dynamic>) {
          throw ApiError.fromJson(json, statusCode: response.statusCode);
        }
        throw ApiError(
          code: 'REQUEST_FAILED',
          message: 'The request could not be completed.',
          statusCode: response.statusCode,
        );
      }
      return json;
    } on ApiError {
      rethrow;
    } on TimeoutException {
      throw const ApiError(
        code: 'NETWORK_TIMEOUT',
        message: 'The request timed out. Try again.',
      );
    } on SocketException {
      throw const ApiError(
        code: 'NETWORK_ERROR',
        message: 'Could not connect. Check your connection and try again.',
      );
    } on HttpException {
      throw const ApiError(
        code: 'NETWORK_ERROR',
        message: 'The connection failed. Try again.',
      );
    }
  }

  void close() => _httpClient.close(force: true);
}
