import 'package:flutter/foundation.dart';

class PendingInvitationController extends ValueNotifier<String?> {
  PendingInvitationController() : super(null);

  void open(Uri uri) {
    final token = _tokenFrom(uri);
    if (token != null) value = token;
  }

  void clear() => value = null;

  String? _tokenFrom(Uri uri) {
    String? token;
    if (uri.scheme == 'meetup' &&
        uri.host == 'join' &&
        uri.pathSegments.length == 1) {
      token = uri.pathSegments.single;
    } else {
      final joinIndex = uri.pathSegments.indexOf('join');
      if ((uri.scheme == 'https' || uri.scheme == 'http') &&
          joinIndex >= 0 &&
          joinIndex + 1 == uri.pathSegments.length - 1) {
        token = uri.pathSegments[joinIndex + 1];
      }
    }
    return token != null && RegExp(r'^[A-Za-z0-9_-]{40,64}$').hasMatch(token)
        ? token
        : null;
  }
}
