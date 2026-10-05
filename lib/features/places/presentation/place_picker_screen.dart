import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../circles/domain/entities/destination.dart';
import '../../circles/domain/entities/geo_point.dart';
import '../domain/repositories/place_search_repository.dart';
import 'state/place_picker_controller.dart';
import 'state/place_picker_state.dart';

class PlacePickerScreen extends StatefulWidget {
  const PlacePickerScreen({super.key, required this.repository});

  final PlaceSearchRepository repository;

  @override
  State<PlacePickerScreen> createState() => _PlacePickerScreenState();
}

class _PlacePickerScreenState extends State<PlacePickerScreen> {
  late final PlacePickerController _controller = PlacePickerController(
    widget.repository,
  );
  final MapController _mapController = MapController();
  final TextEditingController _search = TextEditingController();
  Destination? _selected;
  LatLng _center = const LatLng(20, 0);

  void _choose(Destination destination) {
    setState(() {
      _selected = destination;
      _center = LatLng(destination.point.latitude, destination.point.longitude);
    });
    _mapController.move(_center, 15);
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _search.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EE),
      appBar: AppBar(
        title: const Text('Choose a place'),
        backgroundColor: const Color(0xFFF7F4EE),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
              child: TextField(
                controller: _search,
                onChanged: _controller.search,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search a cafe, address or landmark',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            ValueListenableBuilder<PlacePickerState>(
              valueListenable: _controller,
              builder: (context, state, _) => Column(
                children: [
                  if (state.loading)
                    const LinearProgressIndicator(minHeight: 2),
                  if (state.message != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          state.message!,
                          style: TextStyle(color: color.onSurfaceVariant),
                        ),
                      ),
                    ),
                  if (state.items.isNotEmpty)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.items.length,
                        itemBuilder: (_, index) {
                          final item = state.items[index];
                          return ListTile(
                            leading: const Icon(Icons.place_outlined),
                            title: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              item.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _choose(item.destination),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _center,
                        initialZoom: 2,
                        onPositionChanged: (camera, hasGesture) {
                          if (hasGesture) _center = camera.center;
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.meetup',
                        ),
                        RichAttributionWidget(
                          attributions: [
                            TextSourceAttribution(
                              '© OpenStreetMap contributors',
                              onTap: () => launchUrl(
                                Uri.parse(
                                  'https://www.openstreetmap.org/copyright',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 42),
                        child: Icon(
                          Icons.location_pin,
                          size: 48,
                          color: Color(0xFFFF765E),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      right: 14,
                      child: FilledButton.tonalIcon(
                        onPressed: () => setState(() {
                          _selected = Destination(
                            label:
                                'Pinned place (${_center.latitude.toStringAsFixed(5)}, ${_center.longitude.toStringAsFixed(5)})',
                            point: GeoPoint(
                              latitude: _center.latitude,
                              longitude: _center.longitude,
                            ),
                          );
                        }),
                        icon: const Icon(Icons.push_pin_outlined),
                        label: const Text('Use map center'),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selected?.label ??
                                    'Move the map to place a pin',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: _selected == null
                                      ? null
                                      : () => Navigator.of(
                                          context,
                                        ).pop(_selected),
                                  child: const Text('Use this destination'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
