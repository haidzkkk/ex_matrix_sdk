import 'package:ex_sdk_matrix/my_app/home/home_screen.dart';
import 'package:ex_sdk_matrix/overlay_window/home/widget/avatar_widget.dart';
import 'package:ex_sdk_matrix/ulti/flutter_overlay.dart';
import 'package:flutter/material.dart';

import 'home/home_overlay_screen.dart';

class OverlayWindowScreen extends StatefulWidget {
  const OverlayWindowScreen({super.key});

  @override
  State<OverlayWindowScreen> createState() => _OverlayWindowScreenState();
}

class _OverlayWindowScreenState extends State<OverlayWindowScreen> {

  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    bool isExpanded = MediaQuery.of(context).size.width > 100;
    return Scaffold(
      backgroundColor: isExpanded ? Colors.black.withOpacity(0.5) : Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
              onTap: (){
                // isExpanded = !isExpanded;
                // setState(() {});
                // FlutterOverlay.changeSize(true);
              },
              child: const AvatarWidget()
          ),
          if(isExpanded)
            const Expanded(child: HomeOverlayScreen())
        ],
      ),
    );
  }
}
