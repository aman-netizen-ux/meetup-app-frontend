import 'package:flutter/material.dart';

class DestinationMapMarker extends StatelessWidget {
  const DestinationMapMarker({super.key});

  @override
  Widget build(BuildContext context) => const Icon(
    Icons.location_pin,
    size: 52,
    color: Color(0xFFFF765E),
    shadows: [Shadow(color: Color(0x55000000), blurRadius: 8)],
  );
}
