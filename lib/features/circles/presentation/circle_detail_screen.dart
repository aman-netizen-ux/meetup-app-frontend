import 'package:flutter/material.dart';

import '../domain/entities/circle_snapshot.dart';
import '../domain/repositories/circle_repository.dart';
import 'circle_detail_screen_state.dart';
import '../../contacts/domain/repositories/contact_repository.dart';
import '../../contacts/domain/repositories/share_service.dart';
import '../domain/repositories/mover_location_permission.dart';

class CircleDetailScreen extends StatefulWidget {
  const CircleDetailScreen({
    super.key,
    required this.initial,
    required this.repository,
    required this.isOrganizer,
    required this.contactRepository,
    required this.shareService,
    required this.moverLocationPermission,
    required this.currentUserId,
  });

  final CircleSnapshot initial;
  final CircleRepository repository;
  final bool isOrganizer;
  final ContactRepository contactRepository;
  final ShareService shareService;
  final MoverLocationPermission moverLocationPermission;
  final String currentUserId;

  @override
  State<CircleDetailScreen> createState() => CircleDetailScreenState();
}
