import '../entities/auth_user.dart';

abstract class AuthRepository {
  Stream<bool> get signedInChanges;
  bool get isSignedIn;
  Future<String> sendCode(String phoneE164);
  Future<void> verifyCode(String verificationId, String smsCode);
  Future<AuthUser> loadProfile();
  Future<AuthUser> updateDisplayName(String displayName);
  Future<void> signOut();
}
