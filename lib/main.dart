import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_links/app_links.dart';

import 'app/meetup_app.dart';
import 'app/setup_required_screen.dart';
import 'core/config/app_config.dart';
import 'core/config/firebase_app_config.dart';
import 'core/network/json_http_client.dart';
import 'features/auth/data/datasources/firebase_phone_auth_data_source.dart';
import 'features/auth/data/datasources/profile_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/state/auth_controller.dart';
import 'features/circles/data/datasources/circle_remote_data_source.dart';
import 'features/circles/data/repositories/circle_repository_impl.dart';
import 'features/places/data/place_search_repository_impl.dart';
import 'features/invitations/data/app_link_data_source.dart';
import 'features/invitations/presentation/state/pending_invitation_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final options = FirebaseAppConfig.options;
  final apiBaseUri = AppConfig.apiBaseUri;
  if (options == null || apiBaseUri == null) {
    runApp(const SetupRequiredScreen());
    return;
  }

  await Firebase.initializeApp(options: options);
  final phoneAuth = FirebasePhoneAuthDataSource(FirebaseAuth.instance);
  final http = JsonHttpClient(
    baseUri: apiBaseUri,
    accessTokenProvider: phoneAuth.accessToken,
  );
  final repository = AuthRepositoryImpl(
    phoneAuth,
    ProfileRemoteDataSource(http),
  );
  final controller = AuthController(repository)..start();
  final pendingInvitation = PendingInvitationController();
  final appLinks = AppLinkDataSource(AppLinks());
  final initialLink = await appLinks.initialLink();
  if (initialLink != null) pendingInvitation.open(initialLink);
  appLinks.links.listen(pendingInvitation.open);
  runApp(
    MeetupApp(
      authController: controller,
      circleRepository: CircleRepositoryImpl(CircleRemoteDataSource(http)),
      placeRepository: PlaceSearchRepositoryImpl(http),
      pendingInvitation: pendingInvitation,
    ),
  );
}
