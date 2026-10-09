import 'package:flutter/material.dart';

import 'sign_in_screen.dart';
import 'state/auth_state.dart';
import 'state/auth_status.dart';

class SignInScreenState extends State<SignInScreen> {
  final _phone = TextEditingController();
  final _code = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign in')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ValueListenableBuilder<AuthState>(
            valueListenable: widget.controller,
            builder: (context, state, _) {
              final codeStep =
                  state.status == AuthStatus.awaitingCode ||
                  state.status == AuthStatus.verifying;
              final busy =
                  state.status == AuthStatus.sendingCode ||
                  state.status == AuthStatus.verifying;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/branding/meetup-logo-v1.png',
                      width: 92,
                      height: 92,
                      semanticLabel: 'Meetup',
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    codeStep ? 'Enter your SMS code' : 'Your phone number',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    codeStep
                        ? 'We sent a code to ${state.phoneE164}.'
                        : 'Use your number with country code. Your number will be used to verify your account.',
                  ),
                  const SizedBox(height: 20),
                  if (codeStep)
                    TextField(
                      controller: _code,
                      keyboardType: TextInputType.number,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      decoration: const InputDecoration(
                        labelText: 'Verification code',
                      ),
                    )
                  else
                    TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      decoration: const InputDecoration(
                        labelText: 'Phone number',
                        hintText: '+919876543210',
                      ),
                    ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: busy
                        ? null
                        : codeStep
                        ? () => widget.controller.verifyCode(_code.text)
                        : () => widget.controller.sendCode(_phone.text),
                    child: Text(
                      busy
                          ? 'Please wait…'
                          : codeStep
                          ? 'Verify and sign in'
                          : 'Send code',
                    ),
                  ),
                  if (codeStep)
                    TextButton(
                      onPressed: busy
                          ? null
                          : () => widget.controller.resetSignIn(),
                      child: const Text('Use a different number'),
                    ),
                  const SizedBox(height: 12),
                  const Text(
                    'By continuing, an SMS may be sent. Your number is processed by Firebase Authentication for verification.',
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}
