import '../../domain/entities/auth_user.dart';

AuthUser mapAuthUser(Map<String, dynamic> response) {
  final user = response['user'] as Map<String, dynamic>;
  return AuthUser(
    id: user['id'] as String,
    phoneE164: user['phoneE164'] as String,
    displayName: user['displayName'] as String,
    profileCompleted: user['profileCompleted'] as bool,
  );
}
