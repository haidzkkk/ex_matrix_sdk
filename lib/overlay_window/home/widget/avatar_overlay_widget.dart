
import 'package:ex_sdk_matrix/data/provider/home_provider.dart';
import 'package:ex_sdk_matrix/ultis/client_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../screen/widget/avatar_widget.dart';

class AvatarOverlayWidget extends StatefulWidget {
  const AvatarOverlayWidget({super.key});

  @override
  State<AvatarOverlayWidget> createState() => _AvatarOverlayWidgetState();
}

class _AvatarOverlayWidgetState extends State<AvatarOverlayWidget> {
  late HomeProvider homeProvider = context.read<HomeProvider>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<HomeProvider>(
            builder: (context, _, child) {
              String avatarUrl = homeProvider.profile?.getAvatarUrl(homeProvider.client) ?? "";
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: avatarUrl.isEmpty
                  ? null
                  : AvatarWidget(
                     size: 60,
                     avatarUrl: homeProvider.profile?.getAvatarUrl(homeProvider.client) ?? "",
                     displayName: homeProvider.profile?.displayName ?? ""
                  ),
              );
          }
        ),
        Builder(builder: (context){
          int totalBadgets = 0;
          for (var room in homeProvider.client.rooms) {
            totalBadgets += room.notificationCount;
          }
          if(totalBadgets <= 0) return const SizedBox();
          return Positioned(
              right: 5,
              top: 5,
              child: Badge(
                label: Text(totalBadgets.toString()),
              )
          );
        })
      ],
    );
  }
}
