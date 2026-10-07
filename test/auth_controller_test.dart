import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meetup_app_frontend/features/auth/domain/entities/auth_user.dart';
import 'package:meetup_app_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:meetup_app_frontend/features/auth/presentation/state/auth_controller.dart';
import 'package:meetup_app_frontend/features/auth/presentation/state/auth_status.dart';

class FakeAuthRepository implements AuthRepository {
  final changes = StreamController<bool>.broadcast();
  bool signedIn = false;
  int profileLoads = 0;

  @override
  Stream<bool> get signedInChanges => changes.stream;

  @override
  bool get isSignedIn => signedIn;

  @override
  Future<String> sendCode(String phoneE164) async => 'verification-1';

  @override
  Future<void> verifyCode(String verificationId, String smsCode) async {
    signedIn = true;
    changes.add(true);
  }

  @override
  Future<AuthUser> loadProfile() async {
    profileLoads++;
    return const AuthUser(
      id: 'user-1',
      phoneE164: '+919876543210',
      displayName: 'Priya',
      profileCompleted: true,
    );
  }

  @override
  Future<AuthUser> updateDisplayName(String displayName) async => AuthUser(
    id: 'user-1',
    phoneE164: '+919876543210',
    displayName: displayName,
    profileCompleted: true,
  );

  @override
  Future<void> signOut() async {
    signedIn = false;
    changes.add(false);
  }
}

void main() {
  test(
    'phone validation, code verification, account load, and sign-out',
    () async {
      final repository = FakeAuthRepository();
      final controller = AuthController(repository)..start();
      repository.changes.add(false);
      await Future<void>.delayed(Duration.zero);
      expect(controller.value.status, AuthStatus.signedOut);

      await controller.sendCode('123');
      expect(controller.value.status, AuthStatus.signedOut);
      expect(controller.value.errorMessage, isNotNull);

      await controller.sendCode('+919876543210');
      expect(controller.value.status, AuthStatus.awaitingCode);
      await controller.verifyCode('654987');
      expect(controller.value.status, AuthStatus.signedIn);
      expect(controller.value.user?.displayName, 'Priya');
      expect(repository.profileLoads, 1);

      await controller.signOut();
      expect(controller.value.status, AuthStatus.signedOut);
      controller.dispose();
      await repository.changes.close();
    },
  );
}
