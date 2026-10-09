import 'package:flutter/material.dart';

class MeetupSplashOrbitDot extends StatelessWidget {
  const MeetupSplashOrbitDot({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 12,
    height: 12,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(
        color: Theme.of(context).colorScheme.surface,
        width: 3,
      ),
    ),
  );
}
