import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class FirebasePhoneAuthDataSource {
  FirebasePhoneAuthDataSource(this._auth);

  final FirebaseAuth _auth;

  Stream<bool> get signedInChanges =>
      _auth.authStateChanges().map((user) => user != null);

  bool get isSignedIn => _auth.currentUser != null;

  Future<String?> accessToken() {
    final user = _auth.currentUser;
    if (user == null) return Future.value();
    return user.getIdToken().timeout(const Duration(seconds: 30));
  }

  Future<String> sendCode(String phoneE164) {
    final result = Completer<String>();
    try {
      unawaited(
        _auth
            .verifyPhoneNumber(
              phoneNumber: phoneE164,
              verificationCompleted: (credential) async {
                try {
                  await _auth.signInWithCredential(credential);
                  if (!result.isCompleted) result.complete('');
                } catch (error, stackTrace) {
                  if (!result.isCompleted) {
                    result.completeError(error, stackTrace);
                  }
                }
              },
              verificationFailed: (error) {
                if (!result.isCompleted) result.completeError(error);
              },
              codeSent: (verificationId, _) {
                if (!result.isCompleted) result.complete(verificationId);
              },
              codeAutoRetrievalTimeout: (verificationId) {
                if (!result.isCompleted) result.complete(verificationId);
              },
            )
            .catchError((Object error, StackTrace stackTrace) {
              if (!result.isCompleted) result.completeError(error, stackTrace);
            }),
      );
    } catch (error, stackTrace) {
      if (!result.isCompleted) result.completeError(error, stackTrace);
    }
    return result.future.timeout(
      const Duration(seconds: 45),
      onTimeout: () => throw TimeoutException(
        'Phone verification did not start in time.',
      ),
    );
  }

  Future<void> verifyCode(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() => _auth.signOut();
}
