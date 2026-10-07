import 'package:flutter/material.dart';

import '../features/auth/presentation/auth_gate.dart';
import '../features/auth/presentation/state/auth_controller.dart';
import '../features/circles/presentation/state/circles_home_controller.dart';
import '../features/circles/domain/repositories/circle_repository.dart';
import '../features/places/domain/repositories/place_search_repository.dart';
import '../features/invitations/presentation/state/pending_invitation_controller.dart';
import '../features/contacts/domain/repositories/contact_repository.dart';
import '../features/contacts/domain/repositories/share_service.dart';
import '../features/circles/domain/repositories/mover_location_permission.dart';

class AppRoutes {
  const AppRoutes(
    this.authController,
    this.homeController,
    this.circleRepository,
    this.placeRepository,
    this.pendingInvitation,
    this.contactRepository,
    this.shareService,
    this.moverLocationPermission,
  );

  final AuthController authController;
  final CirclesHomeController homeController;
  final CircleRepository circleRepository;
  final PlaceSearchRepository placeRepository;
  final PendingInvitationController pendingInvitation;
  final ContactRepository contactRepository;
  final ShareService shareService;
  final MoverLocationPermission moverLocationPermission;

  static const home = '/';

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _homeRoute(settings);
      default:
        final uri = Uri.tryParse(settings.name ?? '');
        if (uri != null) pendingInvitation.open(uri);
        if (pendingInvitation.value != null) return _homeRoute(settings);
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const Scaffold(
            body: Center(child: Text('This page is not available yet.')),
          ),
        );
    }
  }

  MaterialPageRoute<void> _homeRoute(RouteSettings settings) =>
      MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => AuthGate(
          authController: authController,
          circlesController: homeController,
          circleRepository: circleRepository,
          placeRepository: placeRepository,
          pendingInvitation: pendingInvitation,
          contactRepository: contactRepository,
          shareService: shareService,
          moverLocationPermission: moverLocationPermission,
        ),
      );
}
