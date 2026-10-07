abstract class ShareService {
  Future<void> shareInvitation({
    required String contactName,
    required Uri invitationUrl,
  });
}
