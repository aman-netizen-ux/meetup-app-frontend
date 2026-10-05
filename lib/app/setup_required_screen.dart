import 'package:flutter/material.dart';

class SetupRequiredScreen extends StatelessWidget {
  const SetupRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
    home: Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Development setup is incomplete. Set API_BASE_URL and the Firebase platform configuration described in the project README.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}
