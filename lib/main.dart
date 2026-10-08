import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_links/app_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
import 'features/contacts/data/datasources/contact_book_data_source.dart';
import 'features/contacts/data/datasources/contact_remote_data_source.dart';
import 'features/contacts/data/platform/platform_share_service.dart';
import 'features/contacts/data/repositories/contact_repository_impl.dart';
import 'features/circles/data/platform/geolocator_mover_location_permission.dart';
import 'features/circles/data/platform/geolocator_device_location_tracker.dart';
import 'features/notifications/data/datasources/push_token_remote_data_source.dart';
import 'features/notifications/data/repositories/firebase_push_token_registrar.dart';
import 'features/notifications/presentation/state/push_message_controller.dart';
import 'features/notifications/presentation/state/push_registration_controller.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: FirebaseAppConfig.options);
}
Future<void> openInitialInvitation(
  AppLinkDataSource appLinks,
  PendingInvitationController pendingInvitation,
) async {
  try {
    final initialLink = await appLinks.initialLink().timeout(
      const Duration(seconds: 5),
    );
    if (initialLink != null) pendingInvitation.open(initialLink);
  } on TimeoutException {}
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final options = FirebaseAppConfig.options;
  final apiBaseUri = AppConfig.apiBaseUri;
  if (options == null || apiBaseUri == null) {
    runApp(const SetupRequiredScreen());
    return;
  }

  await Firebase.initializeApp(options: options);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
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
  final pushRegistration = PushRegistrationController(
    controller,
    FirebasePushTokenRegistrar(FirebaseMessaging.instance, PushTokenRemoteDataSource(http)),
  );
  pushRegistration.start();
  final pushMessages = PushMessageController()..start();
  final pendingInvitation = PendingInvitationController();
  final appLinks = AppLinkDataSource(AppLinks());
  appLinks.links.listen(pendingInvitation.open);
  unawaited(openInitialInvitation(appLinks, pendingInvitation));
  runApp(
    MeetupApp(
      authController: controller,
      circleRepository: CircleRepositoryImpl(CircleRemoteDataSource(http)),
      placeRepository: PlaceSearchRepositoryImpl(http),
      pendingInvitation: pendingInvitation,
      contactRepository: ContactRepositoryImpl(
        ContactBookDataSource(),
        ContactRemoteDataSource(http),
      ),
      shareService: const PlatformShareService(),
      moverLocationPermission: const GeolocatorMoverLocationPermission(),
      locationTracker: const GeolocatorDeviceLocationTracker(),
      pushMessages: pushMessages,
    ),
  );
}

