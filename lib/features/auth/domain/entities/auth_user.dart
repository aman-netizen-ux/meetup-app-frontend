class AuthUser {
  const AuthUser({
    required this.id,
    required this.phoneE164,
    required this.displayName,
    required this.profileCompleted,
  });

  final String id;
  final String phoneE164;
  final String displayName;
  final bool profileCompleted;
}
