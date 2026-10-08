import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../../domain/repositories/push_token_registrar.dart';
import '../datasources/push_token_remote_data_source.dart';

class FirebasePushTokenRegistrar implements PushTokenRegistrar {
  FirebasePushTokenRegistrar(this._messaging, this._remote);

  final FirebaseMessaging _messaging;
  final PushTokenRemoteDataSource _remote;
  StreamSubscription<String>? _refreshSubscription;

  @override
  Future<void> registerCurrentDevice() async {
    final permission = await _messaging.requestPermission();
    if (permission.authorizationStatus == AuthorizationStatus.denied ||
        permission.authorizationStatus == AuthorizationStatus.notDetermined) {
      return;
    }
    final token = await _messaging.getToken();
    if (token != null && token.isNotEmpty) await _remote.register('android', token);
  }

  @override
  void startTokenRefresh() {
    _refreshSubscription ??= _messaging.onTokenRefresh.listen(
      (token) => unawaited(_remote.register('android', token)),
    );
  }

  @override
  void dispose() {
    unawaited(_refreshSubscription?.cancel());
  }
}
