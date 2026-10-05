import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_phone_auth_data_source.dart';
import '../datasources/profile_remote_data_source.dart';
import '../mappers/auth_user_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._phoneAuth, this._profile);

  final FirebasePhoneAuthDataSource _phoneAuth;
  final ProfileRemoteDataSource _profile;

  @override
  Stream<bool> get signedInChanges => _phoneAuth.signedInChanges;

  @override
  bool get isSignedIn => _phoneAuth.isSignedIn;

  @override
  Future<String> sendCode(String phoneE164) => _phoneAuth.sendCode(phoneE164);

  @override
  Future<void> verifyCode(String verificationId, String smsCode) =>
      _phoneAuth.verifyCode(verificationId, smsCode);

  @override
  Future<AuthUser> loadProfile() async =>
      mapAuthUser(await _profile.loadProfile());

  @override
  Future<AuthUser> updateDisplayName(String displayName) async =>
      mapAuthUser(await _profile.updateDisplayName(displayName));

  @override
  Future<void> signOut() => _phoneAuth.signOut();
}
