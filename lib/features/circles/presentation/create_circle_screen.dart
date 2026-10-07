import 'package:flutter/material.dart';

import '../../places/domain/repositories/place_search_repository.dart';
import '../domain/repositories/circle_repository.dart';
import 'create_circle_screen_state.dart';

class CreateCircleScreen extends StatefulWidget {
  const CreateCircleScreen({
    super.key,
    required this.repository,
    required this.places,
  });

  final CircleRepository repository;
  final PlaceSearchRepository places;

  @override
  State<CreateCircleScreen> createState() => CreateCircleScreenState();
}
