import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/network/api_error.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';
import 'auth_status.dart';

class AuthController extends ValueNotifier<AuthState> {
  AuthController(this._repository)
    : super(const AuthState(status: AuthStatus.checking));

  final AuthRepository _repository;
  StreamSubscription<bool>? _subscription;
  Future<void>? _profileLoad;
  int _sessionGeneration = 0;

  void start() {
    _subscription ??= _repository.signedInChanges.listen(
      (signedIn) {
        if (signedIn) {
          unawaited(loadProfile());
        } else {
          _sessionGeneration++;
          _profileLoad = null;
          value = const AuthState(status: AuthStatus.signedOut);
        }
      },
      onError: (_) {
        value = const AuthState(
          status: AuthStatus.failure,
          errorMessage: 'Could not restore your session. Retry or sign out.',
        );
      },
    );
  }

  Future<void> loadProfile() {
    final inFlight = _profileLoad;
    if (inFlight != null) return inFlight;
    late final Future<void> loading;
    loading = _loadProfile().whenComplete(() {
      if (identical(_profileLoad, loading)) _profileLoad = null;
    });
    return _profileLoad = loading;
  }

  Future<void> _loadProfile() async {
    final generation = _sessionGeneration;
    value = const AuthState(status: AuthStatus.loadingProfile);
    try {
      final user = await _repository.loadProfile();
      if (generation == _sessionGeneration && _repository.isSignedIn) {
        value = AuthState(status: AuthStatus.signedIn, user: user);
      }
    } on ApiError catch (error) {
      if (generation != _sessionGeneration) return;
      if (error.statusCode == 401) {
        await signOut();
        return;
      }
      value = const AuthState(
        status: AuthStatus.failure,
        errorMessage: 'Could not load your account. Check the API and retry.',
      );
    } catch (_) {
      if (generation != _sessionGeneration) return;
      value = const AuthState(
        status: AuthStatus.failure,
        errorMessage: 'Could not load your account. Check the API and retry.',
      );
    }
  }

  Future<void> sendCode(String phoneE164) async {
    final phone = phoneE164.trim();
    if (!RegExp(r'^\+[1-9][0-9]{6,14}$').hasMatch(phone)) {
      value = const AuthState(
        status: AuthStatus.signedOut,
        errorMessage:
            'Enter a phone number with country code, such as +919876543210.',
      );
      return;
    }
    value = AuthState(status: AuthStatus.sendingCode, phoneE164: phone);
    try {
      final verificationId = await _repository.sendCode(phone);
      if (verificationId.isNotEmpty && !_repository.isSignedIn) {
        value = AuthState(
          status: AuthStatus.awaitingCode,
          verificationId: verificationId,
          phoneE164: phone,
        );
      }
    } catch (_) {
      value = const AuthState(
        status: AuthStatus.signedOut,
        errorMessage:
            'Could not send the code. Check the number and try again.',
      );
    }
  }

  void resetSignIn() {
    value = const AuthState(status: AuthStatus.signedOut);
  }

  Future<void> verifyCode(String smsCode) async {
    final verificationId = value.verificationId;
    final phone = value.phoneE164;
    if (verificationId == null || phone == null) return;
    value = AuthState(
      status: AuthStatus.verifying,
      verificationId: verificationId,
      phoneE164: phone,
    );
    try {
      await _repository.verifyCode(verificationId, smsCode.trim());
      await loadProfile();
    } catch (_) {
      value = AuthState(
        status: AuthStatus.awaitingCode,
        verificationId: verificationId,
        phoneE164: phone,
        errorMessage: 'That code did not work. Check it and try again.',
      );
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = await _repository.updateDisplayName(displayName);
      value = AuthState(status: AuthStatus.signedIn, user: user);
    } catch (_) {
      value = AuthState(
        status: AuthStatus.signedIn,
        user: value.user,
        errorMessage: 'Could not save your name. Try again.',
      );
    }
  }

  Future<void> signOut() async {
    _sessionGeneration++;
    _profileLoad = null;
    await _repository.signOut();
    value = const AuthState(status: AuthStatus.signedOut);
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
