import 'package:flutter/material.dart';

import 'meetup_splash_orbit_dot.dart';

class MeetupSplashScreen extends StatefulWidget {
  const MeetupSplashScreen({super.key});

  @override
  State<MeetupSplashScreen> createState() => _MeetupSplashScreenState();
}

class _MeetupSplashScreenState extends State<MeetupSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              colors.primaryContainer.withValues(alpha: 0.32),
            ],
          ),
        ),
        child: Center(
          child: Semantics(
            label: 'Loading Meetup',
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _motion,
                builder: (context, _) {
                  final phase = _motion.value;
                  final scale = 0.98 + (phase < 0.5 ? phase : 1 - phase) * 0.06;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.scale(
                        scale: scale,
                        child: SizedBox.square(
                          dimension: 168,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Transform.rotate(
                                angle: phase * 6.283185307,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 146,
                                      height: 146,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: colors.primary.withValues(alpha: 0.26),
                                        ),
                                      ),
                                    ),
                                    const Align(
                                      alignment: Alignment.topCenter,
                                      child: MeetupSplashOrbitDot(
                                        color: Color(0xFFFF765E),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: MeetupSplashOrbitDot(
                                        color: colors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ClipOval(
                                child: Image.asset(
                                  'assets/branding/meetup-logo-v1.png',
                                  width: 118,
                                  height: 118,
                                  filterQuality: FilterQuality.medium,
                                  excludeFromSemantics: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'meetup.',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Getting your plans ready',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
