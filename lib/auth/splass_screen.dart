
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

import '../example/main_example.dart';
import '../my_app/home/home_screen.dart';
import 'login_screen.dart';
import 'navigator_screen.dart';

class SplashScreen extends StatelessWidget {
  final Client client;
  const SplashScreen({required this.client, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matrix Example Chat',
      builder: (context, child) => Provider<Client>(
        create: (context) => client,
        child: child,
      ),
      debugShowCheckedModeBanner: false,
      home: client.isLogged() ? const HomeScreen() : const LoginPage(),
    );
  }
}
