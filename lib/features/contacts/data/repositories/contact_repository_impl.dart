import '../../domain/entities/contact_invite_candidate.dart';
import '../../domain/entities/contact_match_status.dart';
import '../../domain/repositories/contact_repository.dart';
import '../datasources/contact_book_data_source.dart';
import '../datasources/contact_remote_data_source.dart';

class ContactRepositoryImpl implements ContactRepository {
  const ContactRepositoryImpl(this._book, this._remote);

  final ContactBookDataSource _book;
  final ContactRemoteDataSource _remote;

  @override
  Future<List<ContactInviteCandidate>> loadAndMatch(String circleId) async {
    final contacts = await _book.load();
    if (contacts.isEmpty) return const [];
    final response = await _remote.match(
      circleId,
      contacts
          .map(
            (contact) => {
              'localId': contact.localId,
              'phoneE164': contact.phoneE164,
            },
          )
          .toList(growable: false),
    );
    final matches = <String, Map<String, dynamic>>{
      for (final value in response['items'] as List<dynamic>)
        (value as Map<String, dynamic>)['localId'] as String: value,
    };
    return contacts
        .map((contact) {
          final match = matches[contact.localId]!;
          return ContactInviteCandidate(
            localId: contact.localId,
            displayName: contact.displayName,
            status: match['status'] == 'mapped'
                ? ContactMatchStatus.mapped
                : ContactMatchStatus.unmapped,
            appDisplayName: match['displayName'] as String?,
            matchId: match['matchId'] as String?,
          );
        })
        .toList(growable: false);
  }

  @override
  Future<void> addMappedContact(
    String circleId,
    ContactInviteCandidate contact,
  ) async {
    await _remote.add(circleId, contact.matchId!);
  }

  @override
  Future<void> openSettings() => _book.openSettings();
}
