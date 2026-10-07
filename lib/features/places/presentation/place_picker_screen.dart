import 'package:flutter/material.dart';

import '../domain/repositories/place_search_repository.dart';
import 'place_picker_screen_state.dart';

class PlacePickerScreen extends StatefulWidget {
  const PlacePickerScreen({super.key, required this.repository});

  final PlaceSearchRepository repository;

  @override
  State<PlacePickerScreen> createState() => PlacePickerScreenState();
}
