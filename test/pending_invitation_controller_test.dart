import 'package:flutter_test/flutter_test.dart';
import 'package:meetup_app_frontend/features/invitations/presentation/state/pending_invitation_controller.dart';

void main() {
  test('accepts validated custom and HTTPS invitation links', () {
    final controller = PendingInvitationController();
    const token = 'abcdefghijklmnopqrstuvwxyz9087654321ABCDEFGH';

    controller.open(Uri.parse('meetup://join/$token'));
    expect(controller.value, token);

    controller.clear();
    controller.open(Uri.parse('https://example.test/join/$token'));
    expect(controller.value, token);

    controller.clear();
    controller.open(Uri.parse('meetup://join/too-short'));
    expect(controller.value, isNull);

    controller.dispose();
  });
}
