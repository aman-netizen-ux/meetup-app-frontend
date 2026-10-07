import 'package:flutter/material.dart';

import '../../circles/domain/repositories/circle_repository.dart';
import '../domain/repositories/contact_repository.dart';
import '../domain/repositories/share_service.dart';
import 'contact_invite_screen_state.dart';

class ContactInviteScreen extends StatefulWidget {
  const ContactInviteScreen({
    super.key,
    required this.circleId,
    required this.contacts,
    required this.circles,
    required this.share,
  });

  final String circleId;
  final ContactRepository contacts;
  final CircleRepository circles;
  final ShareService share;

  @override
  State<ContactInviteScreen> createState() => ContactInviteScreenState();
}
