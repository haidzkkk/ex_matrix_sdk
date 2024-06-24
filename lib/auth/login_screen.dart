
import 'package:ex_sdk_matrix/auth/navigator_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:matrix/matrix_api_lite/generated/model.dart';
import 'package:matrix/matrix_api_lite/model/auth/authentication_user_identifier.dart';
import 'package:provider/provider.dart';

import '../example/main_example.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _homeserverTextField = TextEditingController(
    text: 'matrix.org',
  );
  final TextEditingController _usernameTextField = TextEditingController();
  final TextEditingController _passwordTextField = TextEditingController();

  bool _loading = false;

  void _login() async {

    setState(() {
      _loading = true;
    });

    try {
      final client = Provider.of<Client>(context, listen: false);
      await client
          .checkHomeserver(Uri.https(_homeserverTextField.text.trim(), ''));
      await client.login(
        LoginType.mLoginPassword,
        password: _passwordTextField.text,
        identifier: AuthenticationUserIdentifier(user: _usernameTextField.text),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const NavigatorScreen()),
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _homeserverTextField,
              readOnly: _loading,
              autocorrect: false,
              decoration: const InputDecoration(
                prefixText: 'https://',
                border: OutlineInputBorder(),
                labelText: 'Homeserver',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameTextField,
              readOnly: _loading,
              autocorrect: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordTextField,
              readOnly: _loading,
              autocorrect: false,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const LinearProgressIndicator()
                    : const Text('Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}