import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'state/invitation_link_controller.dart';
import 'state/invitation_link_state.dart';
import 'state/invitation_link_status.dart';

class InvitationLinkPanel extends StatelessWidget {
  const InvitationLinkPanel({
    super.key,
    required this.circleId,
    required this.controller,
  });

  final String circleId;
  final InvitationLinkController controller;

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<InvitationLinkState>(
        valueListenable: controller,
        builder: (context, state, _) {
          if (state.status == InvitationLinkStatus.ready) {
            final text = state.link!.url.toString();
            return Card(
              color: const Color(0xFFDBF3EE),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Invitation ready',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: text));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Invitation link copied'),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.copy_rounded),
                          label: const Text('Copy link'),
                        ),
                        TextButton(
                          onPressed: controller.reset,
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                onPressed: state.status == InvitationLinkStatus.loading
                    ? null
                    : () => controller.create(circleId),
                icon: state.status == InvitationLinkStatus.loading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.link_rounded),
                label: Text(
                  state.status == InvitationLinkStatus.loading
                      ? 'Creating invitation…'
                      : 'Invite with a link',
                ),
              ),
              if (state.message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    state.message!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          );
        },
      );
}
