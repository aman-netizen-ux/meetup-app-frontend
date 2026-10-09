import 'package:flutter/material.dart';

import '../../../core/presentation/shimmer_block.dart';
import '../../circles/domain/entities/travel_role.dart';
import 'join_circle_screen.dart';
import 'state/join_circle_controller.dart';
import 'state/join_circle_state.dart';
import 'state/join_circle_status.dart';

class JoinCircleScreenState extends State<JoinCircleScreen> {
  late final JoinCircleController _controller = JoinCircleController(
    widget.repository,
    widget.token,
  );
  final ValueNotifier<TravelRole> _role = ValueNotifier(TravelRole.mover);

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _role.dispose();
    super.dispose();
  }

  Future<void> _accept() async {
    final circle = await _controller.accept(_role.value);
    if (circle != null && mounted) widget.onJoined(circle);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Join this circle'),
      leading: IconButton(
        onPressed: widget.onClose,
        icon: const Icon(Icons.close_rounded),
      ),
    ),
    body: ValueListenableBuilder<JoinCircleState>(
      valueListenable: _controller,
      builder: (context, state, _) => switch (state.status) {
        JoinCircleStatus.loading => const Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBlock(width: 88, height: 14),
              SizedBox(height: 16),
              ShimmerBlock(height: 34),
              SizedBox(height: 12),
              ShimmerBlock(width: 240, height: 16),
              SizedBox(height: 28),
              ShimmerBlock(height: 190),
            ],
          ),
        ),
        JoinCircleStatus.expired || JoinCircleStatus.failure => _failure(state),
        _ => _preview(state),
      },
    ),
  );

  Widget _failure(JoinCircleState state) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.link_off_rounded,
            size: 64,
            color: Color(0xFFFF765E),
          ),
          const SizedBox(height: 18),
          Text(
            state.message ?? 'This invitation is not available.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 18),
          FilledButton.tonal(
            onPressed: widget.onClose,
            child: const Text('Back to circles'),
          ),
        ],
      ),
    ),
  );

  Widget _preview(JoinCircleState state) {
    final preview = state.preview!;
    final accepting = state.status == JoinCircleStatus.accepting;
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              colors: [Color(0xFF17283E), Color(0xFF245966)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'YOU’RE INVITED',
                style: TextStyle(
                  color: Color(0xFF69D7CA),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                preview.destination.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${preview.memberNames.length} ${preview.memberNames.length == 1 ? 'person' : 'people'} already in',
                style: const TextStyle(color: Color(0xFFC7D7E4)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Who’s going?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: preview.memberNames
              .map(
                (name) => Chip(
                  avatar: const Icon(Icons.person_outline, size: 18),
                  label: Text(name),
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: 28),
        const Text(
          'How will you join?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        ValueListenableBuilder<TravelRole>(
          valueListenable: _role,
          builder: (context, role, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedButton<TravelRole>(
                segments: [
                  const ButtonSegment(
                    value: TravelRole.mover,
                    icon: Icon(Icons.directions_walk_rounded),
                    label: Text('Mover'),
                  ),
                  if (preview.isPrivatePlace)
                    const ButtonSegment(
                      value: TravelRole.anchor,
                      icon: Icon(Icons.home_rounded),
                      label: Text('Anchor'),
                    ),
                ],
                selected: {role},
                onSelectionChanged: accepting
                    ? null
                    : (values) => _role.value = values.first,
              ),
              const SizedBox(height: 10),
              Text(
                role == TravelRole.mover
                    ? 'You’re heading to the destination. Location permission comes later, when the circle is ready to track.'
                    : 'You’re already at this private destination.',
                style: const TextStyle(color: Color(0xFF677381)),
              ),
            ],
          ),
        ),
        if (state.message != null) ...[
          const SizedBox(height: 14),
          Text(
            state.message!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: accepting ? null : _accept,
          icon: accepting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.group_add_rounded),
          label: Text(accepting ? 'Joining…' : 'Join circle'),
        ),
      ],
    );
  }
}
