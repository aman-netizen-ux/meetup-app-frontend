import 'package:flutter/material.dart';

import '../../places/domain/repositories/place_search_repository.dart';
import '../domain/repositories/circle_repository.dart';
import 'circles_dashboard_screen_state.dart';
import 'state/circles_home_controller.dart';
import '../../contacts/domain/repositories/contact_repository.dart';
import '../../contacts/domain/repositories/share_service.dart';

class CirclesDashboardScreen extends StatefulWidget {
  const CirclesDashboardScreen({
    super.key,
    required this.controller,
    required this.repository,
    required this.places,
    required this.displayName,
    required this.onSignOut,
    required this.contactRepository,
    required this.shareService,
  });

  final CirclesHomeController controller;
  final CircleRepository repository;
  final PlaceSearchRepository places;
  final String displayName;
  final VoidCallback onSignOut;
  final ContactRepository contactRepository;
  final ShareService shareService;

  @override
  State<CirclesDashboardScreen> createState() => CirclesDashboardScreenState();
}
