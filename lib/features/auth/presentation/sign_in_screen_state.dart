import 'package:flutter/material.dart';

import 'phone_country.dart';
import 'sign_in_screen.dart';
import 'state/auth_state.dart';
import 'state/auth_status.dart';

class SignInScreenState extends State<SignInScreen> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  PhoneCountry _country = PhoneCountry.india;

  String get _phoneE164 {
    final input = _phone.text.trim();
    if (input.startsWith('+')) {
      return input.replaceAll(RegExp(r'[^+0-9]'), '');
    }
    final localDigits = input
        .replaceAll(RegExp(r'[^0-9]'), '')
        .replaceFirst(RegExp(r'^0+'), '');
    return '${_country.dialCode}$localDigits';
  }

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
                        ? 'We sent a code to ${state.phoneE164}. It may appear above your keyboard.'
                        : 'Choose your country, then enter your mobile number.',
                  ),
                  const SizedBox(height: 20),
                  AutofillGroup(
                    child: codeStep
                        ? TextField(
                            controller: _code,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.oneTimeCode],
                            enableSuggestions: true,
                            autocorrect: false,
                            onSubmitted: busy
                                ? null
                                : (value) => widget.controller.verifyCode(value),
                            decoration: const InputDecoration(
                              labelText: 'Verification code',
                              hintText: 'Enter the 6-digit code',
                            ),
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 166,
                                child: DropdownButtonFormField<PhoneCountry>(
                                  initialValue: _country,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Country',
                                  ),
                                  items: PhoneCountry.supported
                                      .map(
                                        (country) => DropdownMenuItem(
                                          value: country,
                                          child: Text(
                                            country.label,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: busy
                                      ? null
                                      : (country) {
                                          if (country == null) return;
                                          setState(() => _country = country);
                                        },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _phone,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [
                                    AutofillHints.telephoneNumber,
                                  ],
                                  onSubmitted: busy
                                      ? null
                                      : (_) => widget.controller.sendCode(
                                          _phoneE164,
                                        ),
                                  decoration: const InputDecoration(
                                    labelText: 'Mobile number',
                                    hintText: '98765 43210',
                                  ),
                                ),
                              ),
                            ],
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
                        : () => widget.controller.sendCode(_phoneE164),
                    child: Text(
                      busy
                          ? codeStep
                                ? 'Verifying code…'
                                : 'Sending secure code…'
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
