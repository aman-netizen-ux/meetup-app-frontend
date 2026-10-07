import 'package:flutter/material.dart';

import 'app_routes.dart';
import '../features/auth/presentation/state/auth_controller.dart';
import '../features/circles/presentation/state/circles_home_controller.dart';
import '../features/circles/domain/repositories/circle_repository.dart';
import '../features/places/domain/repositories/place_search_repository.dart';
import '../features/invitations/presentation/state/pending_invitation_controller.dart';

class MeetupApp extends StatelessWidget {
  MeetupApp({
    super.key,
    required AuthController authController,
    required CircleRepository circleRepository,
    required PlaceSearchRepository placeRepository,
    required PendingInvitationController pendingInvitation,
  }) : _routes = AppRoutes(
         authController,
         CirclesHomeController(),
         circleRepository,
         placeRepository,
         pendingInvitation,
       );

  final AppRoutes _routes;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Meetup',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF168C83)),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF7F4EE),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    ),
    initialRoute: AppRoutes.home,
    onGenerateRoute: _routes.onGenerateRoute,
  );
}
