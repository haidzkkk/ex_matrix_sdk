
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ButtonBorder extends StatefulWidget {
  const ButtonBorder({
    super.key,
    this.icon,
    required this.title,
    this.color,
    this.enable,
    this.onPress,
  });

  final Widget? icon;
  final String title;
  final Color? color;
  final bool? enable;
  final Function()? onPress;

  @override
  State<ButtonBorder> createState() => _ButtonBorderState();
}

class _ButtonBorderState extends State<ButtonBorder> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(
          color: widget.color ?? Colors.black
        )
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 10,
            child: widget.icon ?? const SizedBox()
          ),
          Text(widget.title, style: TextStyle(color: widget.color, fontSize: 13),)
        ],
      )
    );
  }
}
