import 'package:flutter/material.dart';

import 'state/auth_controller.dart';
import 'sign_in_screen_state.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.controller});

  final AuthController controller;

  @override
  State<SignInScreen> createState() => SignInScreenState();
}
