import 'package:flutter/material.dart';

import '../domain/entities/journey_mode.dart';
import '../domain/entities/journey_route_option.dart';
import 'state/route_selection_controller.dart';
import 'state/route_selection_state.dart';
import 'state/route_selection_status.dart';

class RouteSelectionCard extends StatelessWidget {
  const RouteSelectionCard({super.key, required this.controller});

  final RouteSelectionController controller;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<RouteSelectionState>(
    valueListenable: controller,
    builder: (context, state, _) {
      if (state.status == RouteSelectionStatus.inactive) {
        return const SizedBox.shrink();
      }
      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF17283E), Color(0xFF234A57)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: Color(0x2417283E), blurRadius: 24, offset: Offset(0, 12)),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(color: Color(0x2968D7C9), shape: BoxShape.circle),
                  child: Padding(
                    padding: EdgeInsets.all(9),
                    child: Icon(Icons.alt_route_rounded, color: Color(0xFF68D7C9), size: 22),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Choose how you’re going', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                      SizedBox(height: 2),
                      Text('Your ETA follows only the route you select.', style: TextStyle(color: Color(0xFFB9CECF), fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (state.status == RouteSelectionStatus.loading)
              const Center(child: Padding(padding: EdgeInsets.all(18), child: CircularProgressIndicator(color: Color(0xFF68D7C9))))
            else if (state.options.isNotEmpty)
              ...state.options.map((option) => _option(context, state, option))
            else
              _recovery(state),
            if (state.message != null && state.options.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(state.message!, style: const TextStyle(color: Color(0xFFFFC9BE), fontSize: 12)),
            ],
          ],
        ),
      );
    },
  );

  Widget _option(BuildContext context, RouteSelectionState state, JourneyRouteOption option) {
    final selected = state.selected?.id == option.id;
    final busy = state.status == RouteSelectionStatus.selecting;
    final color = _color(option.mode);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? color.withValues(alpha: 0.22) : const Color(0x16FFFFFF),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: busy || selected ? null : () => controller.select(option.id),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: selected ? color : const Color(0x2EFFFFFF), width: selected ? 1.5 : 1),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(13)),
                      child: Icon(_icon(option.mode), color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(option.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 3),
                          Text('${_duration(option.durationSeconds)}  •  ${_distance(option.distanceMeters)}', style: const TextStyle(color: Color(0xFFDCE8E6), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    if (selected)
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF68D7C9))
                    else
                      const Icon(Icons.arrow_forward_rounded, color: Color(0xFFB9CECF)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 15, color: Color(0xFFB9CECF)),
                    const SizedBox(width: 6),
                    Expanded(child: Text(option.accuracyLabel, style: const TextStyle(color: Color(0xFFB9CECF), fontSize: 11, height: 1.35))),
                  ],
                ),
                if (selected && option.legs.isNotEmpty) ...[
                  const Divider(color: Color(0x2EFFFFFF), height: 22),
                  ...option.legs.take(4).map((leg) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(_icon(leg.mode), size: 15, color: _color(leg.mode)),
                        const SizedBox(width: 7),
                        Expanded(child: Text(leg.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12))),
                        Text(_duration(leg.durationSeconds), style: const TextStyle(color: Color(0xFFB9CECF), fontSize: 11)),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _recovery(RouteSelectionState state) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          const Icon(Icons.route_outlined, color: Color(0xFFB9CECF), size: 34),
          const SizedBox(height: 8),
          Text(state.message ?? 'No routes found.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, height: 1.4)),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: controller.load,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try routes again'),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF68D7C9)),
          ),
        ],
      ),
    ),
  );

  IconData _icon(JourneyMode mode) => switch (mode) {
    JourneyMode.walk => Icons.directions_walk_rounded,
    JourneyMode.road => Icons.directions_car_filled_rounded,
    JourneyMode.transit => Icons.directions_transit_filled_rounded,
  };

  Color _color(JourneyMode mode) => switch (mode) {
    JourneyMode.walk => const Color(0xFF2D9D78),
    JourneyMode.road => const Color(0xFFF27963),
    JourneyMode.transit => const Color(0xFF8F7BD8),
  };

  String _duration(int seconds) {
    final minutes = (seconds / 60).ceil();
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    return remainder == 0 ? '$hours hr' : '$hours hr $remainder min';
  }

  String _distance(int meters) => meters < 1000
      ? '$meters m'
      : '${(meters / 1000).toStringAsFixed(meters >= 10000 ? 0 : 1)} km';
}
