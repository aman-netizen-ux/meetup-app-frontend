import 'package:firebase_core/firebase_core.dart';

class FirebaseAppConfig {
  const FirebaseAppConfig._();

  static FirebaseOptions? get options {
    const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
    const appId = String.fromEnvironment('FIREBASE_APP_ID');
    const senderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
    const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
    if ([
      apiKey,
      appId,
      senderId,
      projectId,
    ].every((value) => value.isNotEmpty)) {
      return const FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: senderId,
        projectId: projectId,
      );
    }
    return null;
  }
}
