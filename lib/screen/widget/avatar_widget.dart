
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ex_sdk_matrix/screen/widget/builder_widget.dart';
import 'package:ex_sdk_matrix/ultis/utils.dart';
import 'package:flutter/material.dart';

import '../../ultis/color_resources.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    required this.size,
    required this.avatarUrl,
    required this.displayName,
    this.onTap,
    this.heroTag,
  });

  final double size;
  final String avatarUrl;
  final String displayName;
  final String? heroTag;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
  return GestureDetector(
    onTap: (){
      if(onTap != null) onTap!();
    },
    child: BuilderWidget(
      builder: (context, child) {
        if(heroTag != null && heroTag!.isNotEmpty){
          return Hero(
            tag: heroTag!,
            child: child,
          );
        }else{
          return child;
        }
      },
      child: Container(
      width: size,
      height: size,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
          color: ColorResources.primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(100))
      ),
      child: avatarUrl != "null" && avatarUrl.isNotEmpty ? CachedNetworkImage(
        imageUrl: avatarUrl,
        fit: BoxFit.fitWidth,
        errorWidget: (_, __, ___){
          return errorAvatar;
        },
      ) : errorAvatar,
    ),
    ),
  );
  }

  Widget get errorAvatar => Align(
    alignment: Alignment.center,
    child: Text(displayName.firstDisplayName,
      style: TextStyle(color: Colors.white, fontSize: size * 0.75, fontWeight: FontWeight.w500),
    ),
  );
}
