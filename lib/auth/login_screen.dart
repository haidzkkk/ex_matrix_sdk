
import 'package:ex_sdk_matrix/auth/navigator_screen.dart';
import 'package:ex_sdk_matrix/auth/widget/button_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:matrix/matrix.dart';
import 'package:matrix/matrix_api_lite/generated/model.dart';
import 'package:matrix/matrix_api_lite/model/auth/authentication_user_identifier.dart';
import 'package:provider/provider.dart';

import '../example/main_example.dart';
import '../my_app/home/home_screen.dart';

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

  final FocusNode _homeserverFocusNode = FocusNode();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _loading = false;
  bool _showPass = false;

  void _login() async {
    _homeserverFocusNode.unfocus();
    _usernameFocusNode.unfocus();
    _passwordFocusNode.unfocus();

    setState(() {
      _loading = true;
    });

    try {
      final client = Provider.of<Client>(context, listen: false);
      await client.checkHomeserver(Uri.https(_homeserverTextField.text.trim(), ''));
      await client.login(
        LoginType.mLoginPassword,
        password: _passwordTextField.text,
        identifier: AuthenticationUserIdentifier(user: _usernameTextField.text),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false,);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()),),);
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _homeserverTextField.dispose();
    _usernameTextField.dispose();
    _passwordTextField.dispose();
    _homeserverFocusNode.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView(
              children: [
                const SizedBox(height: 30,),
                const Align(
                  alignment: Alignment.center,
                  child: Text("Welcome back!", style: TextStyle(letterSpacing: 2, color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),)
                ),
                const SizedBox(height: 30,),
                TextFormField(
                  controller: _homeserverTextField,
                  focusNode: _homeserverFocusNode,
                  readOnly: _loading,
                  autocorrect: false,
                  cursorColor: Colors.teal,
                  decoration: const InputDecoration(
                      prefixText: 'https://',
                      label: Text("Where your conversatios live"),
                      labelStyle: TextStyle(color: Colors.teal),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal, width: 2, strokeAlign: 10),
                      )

                  ),
                ),
                const SizedBox(height: 20,),
                TextFormField(
                  controller: _usernameTextField,
                  focusNode: _usernameFocusNode,
                  readOnly: _loading,
                  cursorColor: Colors.teal,
                  decoration: const InputDecoration(
                    label: Text("Username/Email/Phone"),
                    floatingLabelStyle: TextStyle(color: Colors.teal),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal, width: 2, strokeAlign: 10),
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20,),
                TextFormField(
                  controller: _passwordTextField,
                  focusNode: _passwordFocusNode,
                  readOnly: _loading,
                  obscureText: !_showPass,
                  cursorColor: Colors.teal,
                  decoration: InputDecoration(
                    label: const Text("Password"),
                    suffixIcon: GestureDetector(
                        onTap: (){
                          setState(() {_showPass = !_showPass;});
                        },
                        child: Icon(_showPass ? Icons.visibility : Icons.visibility_off,)
                    ),
                    floatingLabelStyle: const TextStyle(color: Colors.teal),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal, width: 2, strokeAlign: 10),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20,),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text("FORGOT PASSWORD", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w400, fontSize: 12),),
                ),
                const SizedBox(height: 20,),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.teal,
                    ),
                    onPressed: _login,
                    child: const Text("Continue", style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2),)
                ),
                const SizedBox(height: 20,),
                const Align(
                  alignment: Alignment.center,
                  child: Text("Or", style: TextStyle(fontSize: 16, color: Colors.grey),)
                ),
                const SizedBox(height: 20,),
                ButtonBorder(
                  icon: const FaIcon(FontAwesomeIcons.google, size: 20,),
                  title: "Continue with Google",
                  color: Colors.grey,
                  onPress: (){
                  },
                ),
                const SizedBox(height: 10,),
                ButtonBorder(
                  icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.blue, size: 20,),
                  title: "Continue with Facebook",
                  color: Colors.grey,
                  onPress: (){
                  },
                ),
                const SizedBox(height: 10,),
                ButtonBorder(
                  icon: const FaIcon(FontAwesomeIcons.github, size: 20,),
                  title: "Continue with Github",
                  color: Colors.grey,
                  onPress: (){
                  },
                ),
                const SizedBox(height: 10,),
                ButtonBorder(
                  icon: const FaIcon(FontAwesomeIcons.gitlab, color: Colors.orange, size: 20,),
                  title: "Continue with Gitlab",
                  color: Colors.grey,
                  onPress: (){
                  },
                ),
                const SizedBox(height: 10,),
                ButtonBorder(
                  icon: const FaIcon(FontAwesomeIcons.apple, size: 20,),
                  title: "Continue with Apple",
                  color: Colors.grey,
                  onPress: (){
                  },
                ),
                const SizedBox(height: 30,),
              ],
            ),
          ),
          if(_loading)
            Container(
              color: Colors.white.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator(
                color: Colors.teal,
              )),
            ),
        ],
      ),
    );
  }
}