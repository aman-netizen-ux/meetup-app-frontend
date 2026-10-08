import 'package:flutter/material.dart';

import 'state/push_message_controller.dart';

class PushMessageListener extends StatefulWidget {
  const PushMessageListener({super.key, required this.controller, required this.child});

  final PushMessageController controller;
  final Widget child;

  @override
  State<PushMessageListener> createState() => _PushMessageListenerState();
}

class _PushMessageListenerState extends State<PushMessageListener> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_show);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_show);
    super.dispose();
  }

  void _show() {
    final notification = widget.controller.value?.notification;
    if (!mounted || notification == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${notification.title ?? 'Meetup'} — ${notification.body ?? 'New circle update'}')),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
