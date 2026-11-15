import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/providers.dart';
import '../l10n/generated/app_localizations.dart';
import '../main.dart' show LanguagePicker;

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
    } catch (_) {
      if (mounted) {
        setState(() => _message = AppLocalizations.of(context)!.authFailed);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final auth = ref.read(firebaseAuthProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elora'),
        actions: const [LanguagePicker()],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _register ? t.createAccount : t.signIn,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _email,
                    enabled: !_busy,
                    decoration: InputDecoration(labelText: t.email),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    validator: (value) => value == null || value.trim().isEmpty
                        ? t.requiredField
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    enabled: !_busy,
                    obscureText: true,
                    decoration: InputDecoration(labelText: t.password),
                    autofillHints: [
                      _register
                          ? AutofillHints.newPassword
                          : AutofillHints.password,
                    ],
                    validator: (value) =>
                        value == null || value.isEmpty ? t.requiredField : null,
                  ),
                  const SizedBox(height: 16),
                  if (_message != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_message!, semanticsLabel: _message),
                    ),
                  if (_busy) const LinearProgressIndicator(),
                  FilledButton(
                    onPressed: _busy
                        ? null
                        : () {
                            if (!_form.currentState!.validate()) return;
                            run(() async {
                              if (_register) {
                                final result = await auth
                                    .createUserWithEmailAndPassword(
                                      email: _email.text.trim(),
                                      password: _password.text,
                                    );
                                await result.user!.sendEmailVerification();
                              } else {
                                await auth.signInWithEmailAndPassword(
                                  email: _email.text.trim(),
                                  password: _password.text,
                                );
                              }
                            });
                          },
                    child: Text(_register ? t.createAccount : t.signIn),
                  ),
                  OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => run(() async {
                            if (ref
                                .read(configProvider)
                                .googleWebClientId
                                .isEmpty) {
                              setState(() => _message = t.googleSetup);
                              return;
                            }
                            final google = await GoogleSignIn.instance
                                .authenticate();
                            await auth.signInWithCredential(
                              GoogleAuthProvider.credential(
                                idToken: google.authentication.idToken,
                              ),
                            );
                          }),
                    child: Text(t.google),
                  ),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                            _register = !_register;
                            _message = null;
                          }),
                    child: Text(_register ? t.signIn : t.createAccount),
                  ),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => run(() async {
                            if (_email.text.trim().isEmpty) {
                              setState(() => _message = t.requiredField);
                              return;
                            }
                            await auth.sendPasswordResetEmail(
                              email: _email.text.trim(),
                            );
                            if (mounted) setState(() => _message = t.resetSent);
                          }),
                    child: Text(t.resetPassword),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({super.key});
  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  bool busy = false;
  String? message;
  Future<void> run(Future<void> Function() action) async {
    setState(() {
      busy = true;
      message = null;
    });
    try {
      await action();
    } catch (_) {
      if (mounted) {
        setState(() => message = AppLocalizations.of(context)!.actionFailed);
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final auth = ref.read(firebaseAuthProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.verifyEmail),
        actions: const [LanguagePicker()],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.verifyHelp, textAlign: TextAlign.center),
              if (message != null) Text(message!),
              if (busy) const CircularProgressIndicator(),
              FilledButton(
                onPressed: busy
                    ? null
                    : () => run(() async {
                        await auth.currentUser?.reload();
                        await auth.currentUser?.getIdToken(true);
                        ref.invalidate(authStateProvider);
                      }),
                child: Text(t.checkAgain),
              ),
              OutlinedButton(
                onPressed: busy
                    ? null
                    : () => run(() async {
                        await auth.currentUser?.sendEmailVerification();
                        if (mounted) {
                          setState(() => message = t.verificationSent);
                        }
                      }),
                child: Text(t.resend),
              ),
              TextButton(
                onPressed: busy ? null : () => run(auth.signOut),
                child: Text(t.signOut),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
