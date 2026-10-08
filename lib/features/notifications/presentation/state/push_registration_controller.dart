import 'dart:async';

import '../../../auth/presentation/state/auth_controller.dart';
import '../../../auth/presentation/state/auth_status.dart';
import '../../domain/repositories/push_token_registrar.dart';

class PushRegistrationController {
  PushRegistrationController(this._auth, this._registrar);

  final AuthController _auth;
  final PushTokenRegistrar _registrar;
  bool _registeredForCurrentSession = false;

  void start() {
    _auth.addListener(_sync);
    _sync();
  }

  void _sync() {
    if (_auth.value.status != AuthStatus.signedIn) {
      _registeredForCurrentSession = false;
      return;
    }
    if (_registeredForCurrentSession) return;
    _registeredForCurrentSession = true;
    _registrar.startTokenRefresh();
    unawaited(_registrar.registerCurrentDevice());
  }

  void dispose() {
    _auth.removeListener(_sync);
    _registrar.dispose();
  }
}
