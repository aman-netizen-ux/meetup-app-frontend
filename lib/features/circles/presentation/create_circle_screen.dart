import 'package:flutter/material.dart';

import '../../places/domain/repositories/place_search_repository.dart';
import '../../places/presentation/place_picker_screen.dart';
import '../domain/entities/circle_snapshot.dart';
import '../domain/entities/destination.dart';
import '../domain/repositories/circle_repository.dart';
import 'state/circle_editor_controller.dart';
import 'state/circle_editor_state.dart';

class CreateCircleScreen extends StatefulWidget {
  const CreateCircleScreen({
    super.key,
    required this.repository,
    required this.places,
  });

  final CircleRepository repository;
  final PlaceSearchRepository places;

  @override
  State<CreateCircleScreen> createState() => _CreateCircleScreenState();
}

class _CreateCircleScreenState extends State<CreateCircleScreen> {
  late final CircleEditorController _controller = CircleEditorController(
    widget.repository,
  );

  Future<void> _pickPlace() async {
    final destination = await Navigator.of(context).push<Destination>(
      MaterialPageRoute(
        builder: (_) => PlacePickerScreen(repository: widget.places),
      ),
    );
    if (destination != null) _controller.setDestination(destination);
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final date = await showDatePicker(
      context: context,
      firstDate: today,
      lastDate: DateTime(today.year + 2),
      initialDate: _controller.value.date ?? today,
    );
    if (date != null) _controller.setDate(date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      _controller.setTime(
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      );
    }
  }

  Future<void> _create() async {
    final circle = await _controller.create();
    if (circle != null && mounted) {
      Navigator.of(context).pop<CircleSnapshot>(circle);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF7F4EE),
    appBar: AppBar(
      title: const Text('New circle'),
      backgroundColor: const Color(0xFFF7F4EE),
    ),
    body: ValueListenableBuilder<CircleEditorState>(
      valueListenable: _controller,
      builder: (context, state, _) => SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
                children: [
                  Text(
                    'Bring everyone together.',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF17283E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pick your meeting place and share the plan with your people.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF677381),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _sectionTitle('01', 'Where are we meeting?'),
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      leading: const CircleAvatar(
                        child: Icon(Icons.place_rounded),
                      ),
                      title: Text(
                        state.destination?.label ?? 'Choose a destination',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: const Text(
                        'Search by name or place a pin on the map',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _pickPlace,
                    ),
                  ),
                  const SizedBox(height: 26),
                  _sectionTitle('02', 'When?'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _choiceCard(
                          Icons.calendar_today_outlined,
                          state.date == null
                              ? 'Any day'
                              : '${state.date!.day}/${state.date!.month}/${state.date!.year}',
                          'Set a date',
                          _pickDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _choiceCard(
                          Icons.schedule_rounded,
                          state.time ?? 'Any time',
                          'Set a time',
                          _pickTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No date or time? Your circle starts now.',
                    style: TextStyle(color: Color(0xFF677381)),
                  ),
                  const SizedBox(height: 26),
                  _sectionTitle('03', 'Place type'),
                  const SizedBox(height: 10),
                  Card(
                    child: SwitchListTile.adaptive(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      title: const Text('Private place'),
                      subtitle: const Text(
                        'For a home or another private meeting spot',
                      ),
                      secondary: const Icon(Icons.lock_outline_rounded),
                      value: state.isPrivatePlace,
                      onChanged: _controller.setPrivatePlace,
                    ),
                  ),
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        state.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: state.saving ? null : _create,
                  icon: state.saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Create circle'),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _sectionTitle(String number, String title) => Row(
    children: [
      CircleAvatar(
        radius: 16,
        backgroundColor: const Color(0xFFDBF3EE),
        child: Text(
          number,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ),
      const SizedBox(width: 10),
      Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    ],
  );

  Widget _choiceCard(
    IconData icon,
    String value,
    String hint,
    VoidCallback onTap,
  ) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF168C83)),
            const SizedBox(height: 14),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              hint,
              style: const TextStyle(fontSize: 12, color: Color(0xFF677381)),
            ),
          ],
        ),
      ),
    ),
  );
}
