
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ex_sdk_matrix/screen/widget/builder_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageWidget extends StatefulWidget {
  const ImageWidget({
    super.key,
    required this.url,
    this.hero,
    this.child,
  });

  final String url;
  final String? hero;
  final Widget? child;

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  bool isZoom = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BuilderWidget(
      builder: (context, child){
        if(widget.hero != null && widget.hero!.isNotEmpty){
          return Hero(
              tag: widget.hero!,
              child: child
          );
        }
        return child;
      },
      child: widget.url.isNotEmpty
       ? CachedNetworkImage(
        imageUrl: widget.url,
        fit: BoxFit.fitWidth,
        errorWidget: (_, __, ___){
          return errorWidget;
        },
      ) : errorWidget,
    );
  }

  Widget get errorWidget => const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(height: 100,),
      Icon(Icons.error_outline, color: Colors.redAccent,),
      Text("Lỗi tải tài nguyên", style: TextStyle(color: Colors.redAccent, fontSize: 10,)),
      SizedBox(height: 100,),
    ],
  );
}
