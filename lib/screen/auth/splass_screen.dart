import 'package:ex_sdk_matrix/data/provider/auth_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return context.read<AuthProvider>().client.isLogged()
        ? const HomeScreen()
        : const LoginPage();
  }
}
