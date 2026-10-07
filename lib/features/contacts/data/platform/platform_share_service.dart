import 'package:share_plus/share_plus.dart';

import '../../domain/repositories/share_service.dart';

class PlatformShareService implements ShareService {
  const PlatformShareService();

  @override
  Future<void> shareInvitation({
    required String contactName,
    required Uri invitationUrl,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        subject: 'Join my meetup circle',
        text: 'Hi $contactName, join my meetup circle: $invitationUrl',
      ),
    );
  }
}
