import 'package:flutter/material.dart';

import '../features/auth/presentation/auth_gate.dart';
import '../features/auth/presentation/state/auth_controller.dart';
import '../features/circles/presentation/state/circles_home_controller.dart';
import '../features/circles/domain/repositories/circle_repository.dart';
import '../features/places/domain/repositories/place_search_repository.dart';

class AppRoutes {
  const AppRoutes(
    this.authController,
    this.homeController,
    this.circleRepository,
    this.placeRepository,
  );

  final AuthController authController;
  final CirclesHomeController homeController;
  final CircleRepository circleRepository;
  final PlaceSearchRepository placeRepository;

  static const home = '/';

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => AuthGate(
            authController: authController,
            circlesController: homeController,
            circleRepository: circleRepository,
            placeRepository: placeRepository,
          ),
        );
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const Scaffold(
            body: Center(child: Text('This page is not available yet.')),
          ),
        );
    }
  }
}
