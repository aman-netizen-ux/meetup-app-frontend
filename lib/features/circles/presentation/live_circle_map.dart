import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/entities/circle_snapshot.dart';
import '../domain/entities/journey_route_option.dart';
import '../domain/polyline_decoder.dart';
import 'destination_map_marker.dart';
import 'member_map_marker.dart';

class LiveCircleMap extends StatelessWidget {
  const LiveCircleMap({super.key, required this.circle, this.selectedRoute});

  final CircleSnapshot circle;
  final JourneyRouteOption? selectedRoute;

  @override
  Widget build(BuildContext context) {
    final destination = LatLng(
      circle.destination.point.latitude,
      circle.destination.point.longitude,
    );
    final visibleMembers = circle.members
        .where((member) => member.pin != null)
        .toList(growable: false);
    final routePoints = const PolylineDecoder()
        .decode(selectedRoute?.encodedPolyline, selectedRoute?.polylinePrecision)
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList(growable: false);
    final points = [
      destination,
      ...routePoints,
      ...visibleMembers.map(
        (member) => LatLng(member.pin!.latitude, member.pin!.longitude),
      ),
    ];

    return Container(
      height: 310,
      decoration: BoxDecoration(
        color: const Color(0xFFE9EFEC),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x170E2431),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            key: ValueKey(
              '${circle.id}-${circle.revision}-${visibleMembers.length}',
            ),
            options: MapOptions(
              initialCenter: destination,
              initialZoom: visibleMembers.isEmpty ? 14 : 12,
              initialCameraFit: points.length > 1
                  ? CameraFit.bounds(
                      bounds: LatLngBounds.fromPoints(points),
                      padding: const EdgeInsets.fromLTRB(46, 76, 46, 52),
                      maxZoom: 16,
                    )
                  : null,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.meetup',
              ),
              if (routePoints.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      color: const Color(0xFF168C83),
                      strokeWidth: 5,
                      borderColor: Colors.white,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: destination,
                    width: 58,
                    height: 66,
                    alignment: Alignment.topCenter,
                    child: const DestinationMapMarker(),
                  ),
                  ...visibleMembers.map(
                    (member) => Marker(
                      point: LatLng(
                        member.pin!.latitude,
                        member.pin!.longitude,
                      ),
                      width: 58,
                      height: 58,
                      child: MemberMapMarker(
                        name: member.displayName,
                        presence: member.presence,
                      ),
                    ),
                  ),
                ],
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    '© OpenStreetMap contributors',
                    onTap: () => launchUrl(
                      Uri.parse('https://www.openstreetmap.org/copyright'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 14,
            right: 14,
            top: 14,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xED17283E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.flag_circle_rounded,
                      color: Color(0xFF68D7C9),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        circle.destination.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
