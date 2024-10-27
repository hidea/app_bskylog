import 'package:bluesky/core.dart' as bluesky_core;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'define.dart';
import 'model.dart';
import 'utils.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen(
      {super.key,
      required this.service,
      required this.identifier,
      required this.password});

  final String service;
  final String identifier;
  final String password;

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formKey = GlobalKey<FormState>();

  String _service = '';
  String _identifier = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.language),
                    labelText: 'Hosting provider',
                  ),
                  onSaved: (String? newValue) {
                    _service = newValue!;
                  },
                  initialValue: widget.service,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.alternate_email),
                    labelText: 'Username or email address',
                  ),
                  autofillHints: const [AutofillHints.username],
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a username or email address';
                    }
                    return null;
                  },
                  autofocus: true,
                  onSaved: (String? newValue) {
                    _identifier = newValue!.trim();
                  },
                  initialValue: widget.identifier,
                ),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.lock),
                    labelText: 'Password',
                  ),
                  autofillHints: const [AutofillHints.password],
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter password';
                    }
                    if (bluesky_core.isValidAppPassword(value.trim()) ==
                        false) {
                      return 'Enter "AppPassword"';
                    }
                    return null;
                  },
                  onSaved: (String? newValue) async {
                    _password = newValue!.trim();
                  },
                  initialValue: widget.password,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      const ListTile(
                        dense: true,
                        isThreeLine: true,
                        leading: Icon(Icons.info_outline),
                        title: Text('App Password'),
                        subtitle: Text(
                          'SkyThrow sign-in only accepts an `App Password` that can be generated in the official Bluesky app settings to keep your account secure.',
                          softWrap: true,
                        ),
                      ),
                      Wrap(
                        children: [
                          Align(
                            alignment: Alignment.bottomRight,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  padding: const EdgeInsets.only(
                                      right: 16, bottom: 8)),
                              child: const Text(
                                'Create App Password',
                                style: TextStyle(fontSize: 12),
                              ),
                              onPressed: () {
                                launchUrlPlus(Define.appPasswordUrl);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => progressDialog(
                    context: context,
                    future: _signin(context),
                  ),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signin(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    // blueskyサインイン処理
    try {
      if (kDebugMode) {
        debugPrint('service: $_service');
        debugPrint('identifier: $_identifier');
        debugPrint('password: $_password');
      }

      await context.read<Model>().signin(
            _service,
            _identifier,
            _password,
          );

      if (context.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/');
        });
      }
    } catch (e) {
      if (context.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.pop();
        });
      }
    }
  }
}
