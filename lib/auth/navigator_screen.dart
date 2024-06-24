
import 'package:ex_sdk_matrix/my_app/home/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../example/main_example.dart';

class NavigatorScreen extends StatefulWidget {
  const NavigatorScreen({super.key});

  @override
  State<NavigatorScreen> createState() => _NavigatorScreenState();
}

class _NavigatorScreenState extends State<NavigatorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Select the example"),
            const SizedBox(height: 10,),
            ElevatedButton(
              onPressed: (){
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HomeDartSdkScreen()));
              },
              child: const Text('Example dart sdk')
            ),
            const SizedBox(height: 10,),
            ElevatedButton(
              onPressed: (){
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HomeScreen()));
              },
              child: const Text('Example elemoment')
            ),
          ],
        ),
      ),
    );
  }
}
