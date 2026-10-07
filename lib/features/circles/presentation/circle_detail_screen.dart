import 'package:flutter/material.dart';

import '../domain/entities/circle_snapshot.dart';
import '../domain/repositories/circle_repository.dart';
import 'circle_detail_screen_state.dart';

class CircleDetailScreen extends StatefulWidget {
  const CircleDetailScreen({
    super.key,
    required this.initial,
    required this.repository,
    required this.isOrganizer,
  });

  final CircleSnapshot initial;
  final CircleRepository repository;
  final bool isOrganizer;

  @override
  State<CircleDetailScreen> createState() => CircleDetailScreenState();
}
