import 'package:flutter/material.dart';

import '../../circles/presentation/circles_dashboard_screen.dart';
import '../../circles/presentation/state/circles_home_controller.dart';
import '../../circles/domain/repositories/circle_repository.dart';
import '../../places/domain/repositories/place_search_repository.dart';
import 'profile_name_screen.dart';
import 'sign_in_screen.dart';
import 'state/auth_controller.dart';
import 'state/auth_state.dart';
import 'state/auth_status.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.authController,
    required this.circlesController,
    required this.circleRepository,
    required this.placeRepository,
  });

  final AuthController authController;
  final CirclesHomeController circlesController;
  final CircleRepository circleRepository;
  final PlaceSearchRepository placeRepository;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<AuthState>(
    valueListenable: authController,
    builder: (context, state, _) => switch (state.status) {
      AuthStatus.checking || AuthStatus.loadingProfile => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      AuthStatus.signedIn when state.user?.profileCompleted == false =>
        ProfileNameScreen(controller: authController),
      AuthStatus.signedIn => CirclesDashboardScreen(
        controller: circlesController,
        repository: circleRepository,
        places: placeRepository,
        displayName: state.user?.displayName ?? '',
        onSignOut: authController.signOut,
      ),
      AuthStatus.failure => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.errorMessage ?? 'Could not load account.'),
              TextButton(
                onPressed: authController.loadProfile,
                child: const Text('Retry'),
              ),
              TextButton(
                onPressed: authController.signOut,
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
      _ => SignInScreen(controller: authController),
    },
  );
}
