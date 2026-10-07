import 'package:flutter_contacts/flutter_contacts.dart';

import '../contact_permission_denied.dart';
import '../models/device_contact.dart';

class ContactBookDataSource {
  Future<List<DeviceContact>> load() async {
    final permission = await FlutterContacts.permissions.request(
      PermissionType.read,
    );
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.limited) {
      throw ContactPermissionDenied(
        permanent:
            permission == PermissionStatus.permanentlyDenied ||
            permission == PermissionStatus.restricted,
      );
    }
    final contacts = await FlutterContacts.getAll(
      properties: const {ContactProperty.phone},
      limit: 1000,
    );
    final result = <DeviceContact>[];
    var localIndex = 0;
    for (final contact in contacts) {
      final phone = contact.phones
          .map((value) => value.normalizedNumber ?? value.number)
          .map(_normalizeE164)
          .whereType<String>()
          .firstOrNull;
      if (phone == null) continue;
      result.add(
        DeviceContact(
          localId: 'c${localIndex++}',
          displayName: (contact.displayName ?? '').trim().isEmpty
              ? 'Unnamed contact'
              : contact.displayName!.trim(),
          phoneE164: phone,
        ),
      );
      if (result.length == 200) break;
    }
    result.sort(
      (left, right) => left.displayName.toLowerCase().compareTo(
        right.displayName.toLowerCase(),
      ),
    );
    return result;
  }

  Future<void> openSettings() => FlutterContacts.permissions.openSettings();

  String? _normalizeE164(String value) {
    final trimmed = value.trim();
    if (!trimmed.startsWith('+')) return null;
    final digits = trimmed.substring(1).replaceAll(RegExp(r'\D'), '');
    return RegExp(r'^[1-9][0-9]{6,14}$').hasMatch(digits) ? '+$digits' : null;
  }
}
