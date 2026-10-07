import 'package:flutter/material.dart';

import '../domain/entities/circle_snapshot.dart';
import '../domain/entities/circle_state.dart';
import '../domain/entities/journey_route_option.dart';
import 'live_circle_map.dart';

class CircleLiveSection extends StatelessWidget {
  const CircleLiveSection({
    super.key,
    required this.circle,
    this.selectedRoute,
  });

  final CircleSnapshot circle;
  final JourneyRouteOption? selectedRoute;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            circle.state == CircleState.ended ? 'Last shared map' : 'Live map',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          if (circle.state == CircleState.active)
            const Row(
              children: [
                Icon(Icons.circle, size: 9, color: Color(0xFF2D9D78)),
                SizedBox(width: 6),
                Text(
                  'Updating',
                  style: TextStyle(
                    color: Color(0xFF58706D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
        ],
      ),
      const SizedBox(height: 10),
      LiveCircleMap(circle: circle, selectedRoute: selectedRoute),
      const SizedBox(height: 10),
      const Row(
        children: [
          Icon(Icons.shield_outlined, size: 16, color: Color(0xFF58706D)),
          SizedBox(width: 7),
          Expanded(
            child: Text(
              'Pins appear only after each mover starts sharing.',
              style: TextStyle(fontSize: 12, color: Color(0xFF58706D)),
            ),
          ),
        ],
      ),
    ],
  );
}
