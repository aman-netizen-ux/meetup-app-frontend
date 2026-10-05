import '../../domain/entities/auth_user.dart';
import 'auth_status.dart';

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.verificationId,
    this.phoneE164,
    this.errorMessage,
  });

  final AuthStatus status;
  final AuthUser? user;
  final String? verificationId;
  final String? phoneE164;
  final String? errorMessage;
}
