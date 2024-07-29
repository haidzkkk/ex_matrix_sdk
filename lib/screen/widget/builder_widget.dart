import 'package:flutter/cupertino.dart';

class BuilderWidget extends StatelessWidget {
  const BuilderWidget({
    super.key,
    required this.builder,
    required this.child,
  });

  final Widget Function(BuildContext context, Widget child) builder;
  final Widget child;


  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
