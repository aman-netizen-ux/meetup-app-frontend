import 'package:flutter/material.dart';

import '../../circles/domain/entities/circle_snapshot.dart';
import '../../circles/domain/repositories/circle_repository.dart';
import 'join_circle_screen_state.dart';

class JoinCircleScreen extends StatefulWidget {
  const JoinCircleScreen({
    super.key,
    required this.token,
    required this.repository,
    required this.onJoined,
    required this.onClose,
  });

  final String token;
  final CircleRepository repository;
  final ValueChanged<CircleSnapshot> onJoined;
  final VoidCallback onClose;

  @override
  State<JoinCircleScreen> createState() => JoinCircleScreenState();
}
