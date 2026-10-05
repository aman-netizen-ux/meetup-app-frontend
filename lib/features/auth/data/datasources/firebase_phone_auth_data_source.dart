import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class FirebasePhoneAuthDataSource {
  FirebasePhoneAuthDataSource(this._auth);

  final FirebaseAuth _auth;

  Stream<bool> get signedInChanges =>
      _auth.authStateChanges().map((user) => user != null);

  bool get isSignedIn => _auth.currentUser != null;

  Future<String?> accessToken() =>
      _auth.currentUser?.getIdToken() ?? Future.value();

  Future<String> sendCode(String phoneE164) async {
    final result = Completer<String>();
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneE164,
      verificationCompleted: (credential) async {
        try {
          await _auth.signInWithCredential(credential);
          if (!result.isCompleted) result.complete('');
        } catch (error) {
          if (!result.isCompleted) result.completeError(error);
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
    );
    return result.future;
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
