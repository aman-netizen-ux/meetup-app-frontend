import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class PushMessageController extends ValueNotifier<RemoteMessage?> {
  PushMessageController() : super(null);

  StreamSubscription<RemoteMessage>? _subscription;

  void start() {
    _subscription ??= FirebaseMessaging.onMessage.listen((message) => value = message);
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
