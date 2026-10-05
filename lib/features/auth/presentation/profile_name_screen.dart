import 'package:flutter/material.dart';

import 'state/auth_controller.dart';
import 'profile_name_screen_state.dart';

class ProfileNameScreen extends StatefulWidget {
  const ProfileNameScreen({super.key, required this.controller});

  final AuthController controller;

  @override
  State<ProfileNameScreen> createState() => ProfileNameScreenState();
}
