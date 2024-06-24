
import 'package:ex_sdk_matrix/overlay_window/avatar_widget.dart';
import 'package:ex_sdk_matrix/overlay_window/chat_overlay_widget.dart';
import 'package:flutter/cupertino.dart';
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
            onTap: (){
              isExpanded = !isExpanded;
              setState(() {});
            },
            child: const AvatarWidget()),
        if(isExpanded)
          const Expanded(child: ChatWidget())
      ],
    );
  }
}
