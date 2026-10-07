import 'package:flutter/material.dart';

import '../domain/entities/circle_snapshot.dart';
import '../domain/entities/circle_state.dart';
import '../domain/entities/circle_summary.dart';
import 'circle_detail_screen.dart';
import 'circles_dashboard_screen.dart';
import 'create_circle_screen.dart';
import 'state/circles_home_state.dart';
import 'state/circles_home_status.dart';

class CirclesDashboardScreenState extends State<CirclesDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.controller.load(widget.repository),
    );
  }

  Future<void> _create() async {
    final circle = await Navigator.of(context).push<CircleSnapshot>(
      MaterialPageRoute(
        builder: (_) => CreateCircleScreen(
          repository: widget.repository,
          places: widget.places,
        ),
      ),
    );
    if (!mounted) return;
    await widget.controller.load(widget.repository);
    if (circle != null && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CircleDetailScreen(
            initial: circle,
            repository: widget.repository,
            isOrganizer: true,
          ),
        ),
      );
    }
    if (mounted) widget.controller.load(widget.repository);
  }

  Future<void> _open(CircleSummary summary) async {
    try {
      final circle = await widget.repository.getCircle(summary.id);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CircleDetailScreen(
            initial: circle,
            repository: widget.repository,
            isOrganizer: summary.isOrganizer,
          ),
        ),
      );
      if (mounted) widget.controller.load(widget.repository);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open this circle. Try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF7F4EE),
    appBar: AppBar(
      backgroundColor: const Color(0xFFF7F4EE),
      title: const Text(
        'meetup.',
        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1.5),
      ),
      actions: [
        PopupMenuButton<String>(
          tooltip: 'Account',
          icon: CircleAvatar(
            child: Text(
              widget.displayName.isEmpty
                  ? 'M'
                  : widget.displayName[0].toUpperCase(),
            ),
          ),
          onSelected: (value) {
            if (value == 'signOut') widget.onSignOut();
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'name',
              enabled: false,
              child: Text(widget.displayName),
            ),
            const PopupMenuItem(value: 'signOut', child: Text('Sign out')),
          ],
        ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: () => widget.controller.load(widget.repository),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 110),
        children: [
          Text(
            'Your plans, together.',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF17283E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'See where everyone is headed.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF677381)),
          ),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF17283E), Color(0xFF244B59)],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MAKE A PLAN',
                        style: TextStyle(
                          color: Color(0xFF69D7CA),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'The best moments start somewhere.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: _create,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Create a circle'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.groups_2_rounded,
                  color: Color(0xFF69D7CA),
                  size: 64,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'YOUR CIRCLES',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: Color(0xFF677381),
            ),
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<CirclesHomeState>(
            valueListenable: widget.controller,
            builder: (context, state, _) => switch (state.status) {
              CirclesHomeStatus.loading => const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              ),
              CirclesHomeStatus.failure => _messageCard(
                state.errorMessage ?? 'Could not load circles.',
                Icons.wifi_off_rounded,
                'Retry',
                () => widget.controller.load(widget.repository),
              ),
              CirclesHomeStatus.empty => _messageCard(
                'No circles yet. Create one to bring your people together.',
                Icons.explore_outlined,
                'Create a circle',
                _create,
              ),
              CirclesHomeStatus.loaded => Column(
                children: state.circles.map(_circleCard).toList(),
              ),
            },
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _create,
      icon: const Icon(Icons.add),
      label: const Text('New circle'),
    ),
  );

  Widget _circleCard(CircleSummary circle) {
    final label = switch (circle.state) {
      CircleState.active => 'LIVE',
      CircleState.scheduled => 'UPCOMING',
      CircleState.ended => 'ENDED',
    };
    final when = [
      if (circle.meetupDate != null) circle.meetupDate!,
      if (circle.meetupTime != null) circle.meetupTime!,
    ].join(' · ');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _open(circle),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: Color(0xFFDBF3EE),
                child: Icon(Icons.place_rounded, color: Color(0xFF168C83)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF168C83),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      circle.destinationLabel,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      when.isEmpty
                          ? '${circle.memberCount} ${circle.memberCount == 1 ? 'person' : 'people'} · Starting now'
                          : '${circle.memberCount} ${circle.memberCount == 1 ? 'person' : 'people'} · $when',
                      style: const TextStyle(color: Color(0xFF677381)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _messageCard(
    String message,
    IconData icon,
    String action,
    VoidCallback onTap,
  ) => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(icon, size: 42, color: const Color(0xFF168C83)),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          TextButton(onPressed: onTap, child: Text(action)),
        ],
      ),
    ),
  );
}
