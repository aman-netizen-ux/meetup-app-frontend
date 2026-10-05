import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/repositories/place_search_repository.dart';
import 'place_picker_state.dart';

class PlacePickerController extends ValueNotifier<PlacePickerState> {
  PlacePickerController(this._repository) : super(const PlacePickerState());

  final PlaceSearchRepository _repository;
  Timer? _debounce;
  int _requestId = 0;

  void search(String query) {
    _debounce?.cancel();
    final requestId = ++_requestId;
    if (query.trim().length < 3) {
      value = const PlacePickerState(
        message: 'Type at least 3 letters to search.',
      );
      return;
    }
    value = const PlacePickerState(loading: true);
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      try {
        final items = await _repository.search(query.trim());
        if (requestId != _requestId) return;
        value = PlacePickerState(
          items: items,
          message: items.isEmpty ? 'No places found. Try another name.' : null,
        );
      } catch (_) {
        if (requestId != _requestId) return;
        value = const PlacePickerState(
          message:
              'Search is unavailable. You can still place a pin on the map.',
        );
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
