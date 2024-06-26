import 'package:ex_sdk_matrix/my_app/home/home_screen.dart';
import 'package:ex_sdk_matrix/overlay_window/avatar_widget.dart';
import 'package:ex_sdk_matrix/ulti/flutter_overlay.dart';
import 'package:flutter/material.dart';

class OverlayWindowScreen extends StatefulWidget {
  const OverlayWindowScreen({super.key});

  @override
  State<OverlayWindowScreen> createState() => _OverlayWindowScreenState();
}

class _OverlayWindowScreenState extends State<OverlayWindowScreen> {

  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black26,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
              onTap: (){
                // isExpanded = !isExpanded;
                // setState(() {});
                FlutterOverlay.changeSize(true);
              },
              child: const AvatarWidget()
          ),
          // if(isExpanded)
            const Expanded(child: HomeScreen())
        ],
      ),
    );
  }
}
